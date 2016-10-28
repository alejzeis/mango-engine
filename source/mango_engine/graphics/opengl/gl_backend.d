module mango_engine.graphics.opengl.gl_backend;

version(mango_GLBackend) {
    import mango_engine.mango;
    import mango_engine.logging;

    class GLInitalizer : EngineInitalizer { 
        this(Logger logger) @safe nothrow {
            super(logger);
        }

        override {
            protected void doInit() @trusted {

            }

            protected void doDestroy() @trusted {

            }
        }
    }
}