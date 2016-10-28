module mango_engine.graphics.renderer;

import mango_engine.util;

import std.concurrency;

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
        threadTid = spawn(&startRendererThread, cast(shared) this);
    }

    private void doRun() @system {
        do {
            receive(
                (RendererOperationMessage m) {
                    m.operation();
                }
            );
        } while(running);
    }

    static Renderer factoryBuild() @safe {
        mixin(InterfaceClassFactory!("renderer", "Renderer", ""));
    }
    
    abstract void render() @system;
}

private void startRendererThread(shared Renderer renderer) @system {
    (cast(Renderer) renderer).doRun();
}