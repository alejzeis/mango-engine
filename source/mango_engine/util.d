/*
 *  BSD 3-Clause License
 *  
 *  Copyright (c) 2016, Mango-Engine Team
 *  All rights reserved.
 *  
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are met:
 *  
 *  * Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 *  
 *  * Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *  
 *  * Neither the name of the copyright holder nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *  
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 *  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 *  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 *  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 *  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 *  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 *  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 *  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 *  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
module mango_engine.util;

import std.concurrency;
import core.atomic;

/// Dummy class used for locks.
class SyncLock {

}

/// Utility class to manage a group of threads.
class ThreadPool {
    immutable size_t workerNumber;

    private struct Worker {
        private shared Tid _tid;
        private shared bool _busy = false;

        @property shared Tid tid() @trusted nothrow { return cast(Tid) _tid; }

        @property shared bool busy() @trusted nothrow { return cast(bool) _busy; }
        @property shared void busy(bool busy) @trusted nothrow { _busy = cast(shared) busy; }
 
        this(Tid tid, bool busy = false) @trusted nothrow {
            this._tid = cast(shared) tid;
            this._busy = cast(shared) busy;
        }
    }

    private SyncLock workerLock;

    private shared size_t workerCounter = 0;
    private shared Worker[size_t] workers;

    this(in size_t workerNumber) @trusted {
        this.workerNumber = workerNumber;

        for(size_t i = 0; i < workerNumber; i++) {
            this.workers[i] = cast(shared) Worker(spawn(&spawnWorker, cast(shared) i, cast(shared) this));
        }

        workerLock = new SyncLock();
    }

    void submitWork(WorkDelegate work) @trusted {
        synchronized(workerLock) {
            foreach(id, ref worker; this.workers) {
                // Prioritize sending work to free workers
                if(!worker.busy) {
                    send(worker.tid, Work(work));
                    worker.busy = true;
                    return;
                }
            }
            // All workers busy
            if(workerCounter > workerNumber) {
                workerCounter = 0;
            }
        }

        // Send to the next worker. workerCounter distributes evenly work among the busy workers.
        send(workers[atomicOp!"+="(this.workerCounter, 1)].tid, Work(work));
    }

    shared package void notifyBusy(in size_t id, in bool busy) @safe {
        synchronized(workerLock) {
            if(id > this.workers.length) return;
            this.workers[id].busy = busy;
        }
    }
}

alias WorkDelegate = void delegate() @system;

package shared struct Work {
    WorkDelegate work;
}

class ThreadWorker {
    immutable size_t id;

    private shared(ThreadPool) pool;

    private bool running = true;

    this(in size_t id, shared(ThreadPool) pool) @safe nothrow {
        this.id = id;
        this.pool = pool;
    }

    void doRun() @trusted {
        import std.datetime;
        import core.thread;

        do {
            receive(
                (Work work) {
                    pool.notifyBusy(id, true);
                    debug(mango_concurrencyInfo) {
                        import std.stdio;
                        writeln("Executing work in thread, ", id);
                    }
                    work.work();
                    pool.notifyBusy(id, false);
                    debug(mango_concurrencyInfo) {
                        import std.stdio;
                        writeln("Executing work complete in thread, ", id);
                    }
                },
                (string s) {
                    if(s == "stop") {
                        running = false;
                    }
                }
            );
        } while(running);

        debug(mango_concurrencyInfo) {
            import std.stdio;
            writeln("Worker ", id, " exiting");
        }
    }
}

private void spawnWorker(shared(size_t) id, shared(ThreadPool) pool) @system {
    ThreadWorker worker = new ThreadWorker(id, pool);
    worker.doRun();
}

/++
    Reads a whole file into a string.

    Params:
            filename =  The file to be read.

    Returns: The file's contents.
    Throws: Exception if the file does not exist.
+/
string readFileToString(in string filename) @safe {
    import std.file : exists, readText;
    if(exists(filename)) {
        auto text = readText(filename);
        return text;
    } else throw new Exception("File does not exist!"); 
}