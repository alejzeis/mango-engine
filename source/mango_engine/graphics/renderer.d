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
    (cast(Renderer) renderer).doRun();
}