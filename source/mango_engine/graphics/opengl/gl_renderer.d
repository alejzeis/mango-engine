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
    this(GameManager game) @safe {
        super(game);

        gl_check();

        setup();
    }

    private void setup() @trusted {
        glEnable(GL_TEXTURE_2D);
    }

    override {
        protected void prepareRender() @system {
            super.prepareRender();
            glClear(GL_COLOR_BUFFER_BIT);
        }

        protected void renderModel(shared Model model_) @system {
            shared GLModel model = cast(shared GLModel) model_;
            if(model is null) {
                throw new InvalidArgumentException("Cannot render Model not of type GLModel.");
            }

            (cast(GLModel) model_).render(this);
        }

        protected void finishRender() @system {
            super.finishRender();
            (cast(shared) this.game.window).updateBuffers();
        }
    }
}