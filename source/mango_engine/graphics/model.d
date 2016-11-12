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
module mango_engine.graphics.model;

import mango_engine.game;
import mango_engine.util;
import mango_engine.graphics.renderer;
import mango_engine.graphics.texture;
import mango_engine.graphics.shader;

import mango_stl.misc;

import gl3n.linalg;

/// Struct that represents a Vertex with a vec3 (position)
class Vertex {
    /// Vector containing the Vertex's coordinates (3D).
    vec3 position;

    this(vec3 position) @trusted nothrow {
        position = cast(shared) position;
    }
}

/++
    Struct that represents a Vertex with
    a position vector(vec3), and a texture
    vector (vec2).
+/
class TexturedVertex : Vertex {
    /// Vector containing the texture coordinates.
    vec2 texture;

    this(vec3 position, vec2 texture) @trusted nothrow {
        super(position);
        this.texture = cast(shared) texture;
    }
}

/// Represents a Model which can be rendered. A Model has a Shader and a Texture
class Model {
    immutable string name;

    private shared GameManager _game;
    private shared Lock lock;

    protected shared Vertex[] vertices;
    protected shared uint[] _indices;

    protected shared Texture _texture;
    protected shared ShaderProgram _shader;

    @property uint[] indices() @trusted nothrow { return cast(uint[]) _indices; }
    
    @property Texture texture() @trusted nothrow { return cast(Texture) _texture; }
    @property shared void texture(shared Texture texture) @safe {
        synchronized(lock) {
            this._texture = texture;
        }
    }
    
    @property ShaderProgram shader() @trusted nothrow { return cast(ShaderProgram) _shader; }

    @property GameManager game() @trusted nothrow { return cast(GameManager) _game; }

    protected this(in string name, GameManager game, Vertex[] vertices, uint[] indices, Texture texture, ShaderProgram shader) @trusted nothrow {
        this.name = name;
        this._game = cast(shared) game;
        this.lock = new Lock();

        this.vertices = cast(shared) vertices;
        this._indices = cast(shared) indices;

        this._texture = cast(shared) texture;
        this._shader = cast(shared) shader;
    }

    static Model build(in string name, GameManager game, Vertex[] vertices, uint[] indices, Texture texture, ShaderProgram shader) @safe {
        mixin(InterfaceClassFactory!("model", "Model", "name, game, vertices, indices, texture, shader"));
    }

    void render(Renderer renderer) @system {
        //game.eventManager.fireEvent(new ModelRenderBeginEvent(cast(shared) this));
        synchronized(lock) {
            render_(renderer);
        }
    }
    
    abstract void cleanup() @system;
    
    abstract protected void render_(Renderer renderer) @system;
}