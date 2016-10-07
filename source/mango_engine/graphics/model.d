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

import mango_engine.mango;
import mango_engine.util;
import mango_engine.graphics.backend;
import mango_engine.graphics.renderer;
import mango_engine.graphics.texture;
import mango_engine.graphics.shader;

import gl3n.linalg;

/// Struct that represents a Vertex with a vec3 (position)
class Vertex {
    /// Vector containing the Vertex's coordinates (3D).
    vec3 position;

    this(vec3 position) @safe nothrow {
        this.position = position;
    }
}

abstract class Model {
    private SyncLock lock = new SyncLock();

    protected shared Vertex[] vertices;
    protected uint[] indices;

    protected shared Texture _texture;
    protected ShaderProgram _shader;
    
    @property shared Texture texture() @trusted nothrow { return cast(Texture) _texture; }
    @property shared void texture(shared Texture texture) @safe {
        synchronized(lock) {
            this._texture = texture;
        }
    }
    
    @property ShaderProgram shader() @safe nothrow { return _shader; }

    protected this(Vertex[] vertices, uint[] indices, Texture texture, ShaderProgram shader) @trusted nothrow {
        this.vertices = cast(shared) vertices; //TODO: stop these hacks
        this.indices = indices;

        this._texture = cast(shared) texture; //TODO: !
        this._shader = shader;
    }

    static Model modelFactory(Vertex[] vertices, uint[] indices, Texture texture, ShaderProgram shader, GraphicsBackendType backend) @safe {
        import mango_engine.graphics.opengl.gl_model : GLModel;

        mixin(GenFactory!("Model", "vertices, indices, texture, shader"));
    }

    shared void render(Renderer renderer) @system {
        synchronized(lock) {
            render_(renderer);
        }
    }
    abstract shared void cleanup() @system;
    
    abstract protected shared void render_(Renderer renderer) @system;
}