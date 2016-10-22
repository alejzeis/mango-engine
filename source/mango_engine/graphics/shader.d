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
module mango_engine.graphics.shader;

import mango_engine.mango;
import mango_engine.util;
import mango_engine.exception;
import mango_engine.graphics.backend;

import std.exception : enforce;

/++
    Base class for a ShaderProgram. Implemented
    by backends.
    
    This represents multiple shaders linked into a
    program. Each shader is of a different type,
    such as a Vertex Shader and Fragment Shader.
+/
abstract class ShaderProgram {
    private shared Shader[ShaderType] shaders;
    private SyncLock lock;

    this() @safe nothrow {
        lock = new SyncLock();
    }

    static ShaderProgram shaderProgramFactory(GraphicsBackendType backend) @safe {
        import mango_engine.graphics.opengl.gl_shader : GLShaderProgram;

        mixin(GenFactory!("ShaderProgram"));
    }

    void addShader(Shader shader) @trusted {
        synchronized(lock) {
            enforce(!(shader.type in shaders), new InvalidArgumentException("Attempted to add multiple shaders of same type."));
    
            shader.onShaderAdd();
            addShader_(shader);
            shaders[shader.type] = cast(shared) shader;
        }
    }

    void removeShader(in ShaderType shaderType) @trusted {
        synchronized(lock) {
            enforce(shaderType in shaders, new InvalidArgumentException("Attempted to remove Shader that was not added."));
    
            removeShader_((cast(Shader)shaders[shaderType]));
            (cast(Shader) shaders[shaderType]).onShaderRemove();
            shaders.remove(shaderType);
        }
    }
    
    /// This is called after all the shaders have been added.
    abstract void prepareProgram() @system;
    
    abstract void addShader_(Shader shader) @system;
    abstract void removeShader_(Shader shader) @system;
}

/// Represents a type of Shader.
enum ShaderType {
    /// A Vertex Shader that processes vertices.
    SHADER_VERTEX,
    /// A Fragment Shader that processes pixels.
    SHADER_FRAGMENT,
    /// A Compute Shader
    SHADER_COMPUTE
}

/++
    The base shader class. All implementations
    will extend this.
+/
abstract class Shader {
    /// The shader's filename.
    immutable string filename;
    /// The shader's type
    immutable ShaderType type;
    
    protected this(in string filename, in ShaderType type) @safe nothrow {
        this.filename = filename;
        this.type = type;
    }
    
    static Shader shaderFactory(in string filename, in ShaderType type, GraphicsBackendType backend) @safe {
        import mango_engine.graphics.opengl.gl_shader : GLShader;

        mixin(GenFactory!("Shader", "filename, type"));
    }
    
    protected void onShaderRemove() @system {
        cleanup();
    }

    protected abstract void onShaderAdd() @system;
    protected abstract void cleanup() @system;
}