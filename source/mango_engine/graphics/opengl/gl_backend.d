module mango_engine.graphics.opengl.gl_backend;

version(mango_GLBackend) {
    import mango_engine.game;

    import mango_engine.mango;
    import mango_engine.logging;

    class GLInitalizer : EngineInitalizer { 
        this(Logger logger) @safe nothrow {
            super(logger);
        }

        override {
            protected GameManager doInit() @trusted {
                return null; // Placeholder
            }

            protected void doDestroy() @trusted {

            }
        }
    }
}