module mango_engine.mango;

import mango_engine.logging;

/// The type of backend that the engine can/will use.
enum BackendType {
    BACKEND_OPENGL,
    BACKEND_VULKAN
}

/// Class used to initalize the engine depending on the backend.
abstract class EngineInitalizer {
    private Logger logger;

    package this(Logger logger) @safe nothrow {
        this.logger = logger;
    }

    abstract protected void doInit() @trusted;

    abstract protected void doDestroy() @trusted;
}

/++
    Initalizes the engine.
+/
void mango_init(BackendType type) @safe {
    version(mango_GLBackend) {
        import mango_engine.graphics.opengl.gl_backend : GLInitalizer;

        if(type == BackendType.BACKEND_OPENGL) {
            EngineInitalizer initalizer = new GLInitalizer(new ConsoleLogger("GLBackendInitalizer"));
            initalizer.doInit();
        }
    }
}