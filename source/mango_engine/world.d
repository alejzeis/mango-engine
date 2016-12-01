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
module mango_engine.world;

import mango_engine.game;
import mango_engine.event.core;
import mango_engine.graphics.model;

/// Represents an object in the world.
class WorldObject {
    private shared GameManager _game;

    private shared Model _model;

    private shared float _velocityX = 0f;
    private shared float _velocityY = 0f;

    @property GameManager game() @trusted nothrow { return cast(GameManager) this._game; }

    @property Model model() @trusted nothrow { return cast(Model) this._model; }

    /// Get this object's X velocity.
    @property float velocityX() @safe nothrow { return this._velocityX; }
    /// Set this object's X velocity.
    @property void velocityX(float vx) @safe nothrow { this._velocityX = vx; }
    /// Get this object's Y velocity.
    @property float velocityY() @safe nothrow { return this._velocityY; }
    /// Set this object's Y velocity.
    @property void velocityY(float vy) @safe nothrow { this._velocityY = vy; }

    this(GameManager game, Model model) @trusted {
        this._game = cast(shared) game;
        this._model = cast(shared) model;
        this.game.eventManager.registerEventHook(TickEvent.classinfo.name, EventHook(&this.update, false));
    }

    private void update(Event e) @system {
        debug {
            import std.stdio;
            //writeln("ive been called 2");
        }
        Vertex[] newVerticies = new Vertex[this.model.getVertices().length];
        for(size_t i = 0; i < this.model.getVertices().length; i++) {
            newVerticies[i] = this.model.getVertex(i); // getVertex duplicates the vertex

            newVerticies[i].x += velocityX;
            newVerticies[i].y += velocityY;
        }

        this.model.replaceVertices(newVerticies);
    }
}