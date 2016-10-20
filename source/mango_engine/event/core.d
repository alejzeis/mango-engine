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
module mango_engine.event.core;

import mango_engine.game;
import mango_engine.exception;
import mango_engine.util;

import std.conv;

/// Represents a callable event with properties.
abstract class Event {

}

/// Event that is fired each tick.
class TickEvent : Event {
    string testString;
}

/// Event that is fired when the engine begins to clean up.
class EngineCleanupEvent : Event {

}

alias HookDelegate = void delegate(Event e) @system;

struct EventHook {
    /// The function delegate to be ran.
    immutable HookDelegate hook;
    /// If the delegate can be ran in a separate worker thread.
    immutable bool runAsync = true;
}

class EventManager {
    private ThreadPool pool;
    private GameManager game;

    private shared SyncLock hookLock;
    private shared EventHook[][string] hooks;

    private shared SyncLock evtQueueLock;
    private shared size_t evtQueueCounter = 0;
    private shared Event[size_t] evtQueue;

    this(GameManager game) @safe {
        import core.cpuid;
        this.game = game;
        game.logger.logDebug("Thread Pool created with " ~ to!string(coresPerCPU()) ~ " threads.");
        this.pool = new ThreadPool(coresPerCPU()); 

        this.evtQueueLock = new shared SyncLock();
        this.hookLock = new shared SyncLock();
    }

    /++
        Adds an event to the firing queue. The event
        will be fired on the next EventManager update
        pass.
    +/
    void fireEvent(Event event) @trusted {
        import core.atomic : atomicOp;
        synchronized(this.evtQueueLock) {
            this.evtQueue[atomicOp!"+="(this.evtQueueCounter, 1)] = cast(shared) event;
        }
    }

    void registerEventHook(in string eventType, EventHook hook) @trusted {
        synchronized(this.hookLock) {
            hooks[eventType] ~= cast(shared) hook;
        }
    }

    /// Update function called by GameManager
    void update() @trusted {
        synchronized(this.evtQueueLock) {
            if(this.evtQueue.length < 1) return; // If the queue is empty, return

            size_t[] toRemove;
            foreach(size_t key, shared(Event) event; this.evtQueue) {
                if(event.classinfo.name in hooks) { // Check if there is a hook(s) for the event type
                    foreach(EventHook hook; hooks[event.classinfo.name]) {
                        if(hook.runAsync) { // Check if we can run this in a worker
                            pool.submitWork(() {
                                hook.hook(cast(Event) event);
                            });
                        } else {
                            hook.hook(cast(Event) event);
                        }
                    }
                } else {
                    debug {
                        import std.stdio;
                        writeln("Not found: ", event.classinfo.name);
                    }
                }
                toRemove ~= key; // Add the event's key to the remove list.
            }

            foreach(size_t key; toRemove) { // Remove all the processed events
                this.evtQueue.remove(key);
            }
        }
    }
}