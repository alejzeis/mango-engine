module mango_engine.graphics.opengl.gl_backend;

version(mango_GLBackend) {
    import mango_engine.game;
    import mango_engine.mango;
    import mango_engine.logging;
    import mango_engine.graphics.renderer;

    class GLInitalizer : EngineInitalizer { 
        this(Logger logger) @safe nothrow {
            super(logger);
        }

        override {
            protected GameManagerFactory doInit() @trusted {
                // TODO: load libraries

                GameManagerFactory factory = new GameManagerFactory(BackendType.BACKEND_OPENGL);
                factory.setRenderer(Renderer.factoryBuild());
                return factory;
            }

            protected void doDestroy() @trusted {

            }
        }
    }
}