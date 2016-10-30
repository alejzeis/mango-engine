module mango_engine.mango;

import mango_engine.game;
import mango_engine.logging;

/// The Global logger for Mango-Engine. This is statically initalized.
__gshared Logger GLOBAL_LOGGER;
/// The Version of the library.
immutable string VERSION = "v2.0.0-SNAPSHOT";

static this() {
    GLOBAL_LOGGER = new ConsoleLogger("Mango-Global");
}

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

    abstract protected GameManagerFactory doInit() @trusted;

    abstract protected void doDestroy() @trusted;
}

/++
    Initalizes the engine. This will return a GameManagerFactory
    instance, which can be used to construct a GameManager
    instance.
+/
GameManagerFactory mango_init(BackendType type) @trusted {
    GLOBAL_LOGGER.logInfo("Mango-Engine version " ~ VERSION ~ ", built with " ~ __VENDOR__ ~ " on " ~ __TIMESTAMP__);
    
    version(mango_GLBackend) {
        import mango_engine.graphics.opengl.gl_backend : GLInitalizer;

        if(type == BackendType.BACKEND_OPENGL) {
            EngineInitalizer initalizer = new GLInitalizer(new ConsoleLogger("GLBackendInitalizer"));
            return initalizer.doInit();
        }
    }

    throw new Exception("No backend has been compiled in!");
}