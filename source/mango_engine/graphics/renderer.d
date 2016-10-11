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
module mango_engine.graphics.renderer;

import mango_engine.mango;
import mango_engine.game;
import mango_engine.event.core;
import mango_engine.graphics.backend;
import mango_engine.graphics.model;
import mango_engine.graphics.scene;

/++
    The main class that handles rendering
    on the screen.
+/
abstract class Renderer {
    private GameManager _game;
    private shared Scene _scene;

    @property GameManager game() @trusted nothrow { return cast(GameManager) _game; }

    /// The scene that is currently being rendered.
    @property Scene scene() @trusted nothrow { return cast(Scene) _scene; }
    /// The scene that is currently being rendered.
    void setScene(Scene scene) @trusted nothrow {
        scene.isRendering = true;
        if(_scene !is null)
            _scene.isRendering = false;
         
        _scene = cast(shared) scene; 
    }

    protected this(GameManager game) @safe {
        this._game = game;

        game.eventManager.registerEventHook(TickEvent.classinfo.name,
            EventHook(&this.evtHook_render, false)
        );
    }

    static Renderer rendererFactory(GameManager game, GraphicsBackendType backend) @safe {
        import mango_engine.graphics.opengl.gl_renderer : GLRenderer;

        mixin(GenFactory!("Renderer", "game"));
    }

    private void evtHook_render(Event e) @system {
        debug {
            import std.stdio;
            writeln("Event caught!");
        }
        render();
    }

    /// Render the scene
    final void render() @trusted {
        prepareRender();
        foreach(model; scene.models) {
            renderModel(cast(shared) model); //TODO: synchronization
        }
        finishRender();
    }

    protected void prepareRender() @system {

    }
    protected void finishRender() @system {

    }

    protected abstract void renderModel(shared Model model) @system;
}