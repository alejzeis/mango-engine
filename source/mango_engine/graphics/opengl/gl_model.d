module mango_engine.graphics.opengl.gl_model;

version(mango_GLBackend) {
    import mango_engine.game;
    import mango_engine.graphics.renderer;
    import mango_engine.graphics.texture;
    import mango_engine.graphics.shader;
    import mango_engine.graphics.model;

    import derelict.opengl3.gl3;

    class GLModel : Model {

        this(GameManager game, Vertex[] vertices, uint[] indices, Texture texture, ShaderProgram shader) @safe nothrow {
            super(game, vertices, indices, texture, shader);
        }

        override {
            void cleanup() @system {

            }
        
            protected void render_(Renderer renderer) @system {

            }
        }
    }
}