module mango_engine.graphics.opengl.gl_renderer;

import mango_engine.game;
import mango_engine.exception;
import mango_engine.graphics.model;
import mango_engine.graphics.renderer;
import mango_engine.graphics.opengl.gl_model;
import mango_engine.graphics.opengl.gl_backend;

import derelict.opengl3.gl3;

class GLRenderer : Renderer {
    // TODO: Remove renderer class?

    /// Use Renderer.rendererFactory()
    this(shared GameManager game) @safe {
        super(game);

        gl_check();

        setup();
    }

    private void setup() @trusted {
        glEnable(GL_TEXTURE_2D);
    }

    override protected void renderModel(shared Model model_) @system {
        shared GLModel model = cast(shared GLModel) model_;
        if(model is null) {
            throw new InvalidArgumentException("Cannot render Model not of type GLModel.");
        }

        model_.render(this);
    } 
}