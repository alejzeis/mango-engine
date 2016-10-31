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
module mango_engine.graphics.renderer;

import mango_engine.util;

import std.concurrency;
import std.datetime;

alias RendererOperation = void delegate() @system;

struct RendererOperationMessage {
    shared RendererOperation operation;
}

/// Backend interface class: represents a Renderer.
abstract class Renderer {
    private __gshared Tid threadTid;
    private shared bool _running;

    @property bool running() @trusted nothrow { return _running; }
    
    protected this() @trusted {
        _running = true;
        threadTid = spawn(&startRendererThread, cast(shared) this);
    }

    static Renderer factoryBuild() @safe {
        mixin(InterfaceClassFactory!("renderer", "Renderer", ""));
    }

    void submitOperation(RendererOperation operation) @trusted {
        send(threadTid, RendererOperationMessage(operation));
    }

    private void doRun() @system {
        do {
            uint counter = 0;
            while(processOperation() != false && counter < 15) {
                counter++;
            }

            render();
        } while(running);
    }

    private bool processOperation() @system {
        return receiveTimeout(0.msecs,
            (RendererOperationMessage m) {
                m.operation();
            }
        );
    }

    void stop() @safe nothrow {
        _running = false;
    }
    
    abstract void render() @system;
}

private void startRendererThread(shared Renderer renderer) @system {
    import core.thread : Thread;

    Thread.getThis().name = "Renderer";
    (cast(Renderer) renderer).doRun();
}