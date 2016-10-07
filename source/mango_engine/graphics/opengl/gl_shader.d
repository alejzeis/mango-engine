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
module mango_engine.graphics.opengl.gl_shader;

import mango_engine.util;
import mango_engine.exception;
import mango_engine.graphics.shader;
import mango_engine.graphics.opengl.gl_backend;

import derelict.opengl3.gl3;

/// Converts a ShaderType enum to a GLuint for OpenGL.
GLuint shaderTypeToGL(in ShaderType type) @safe nothrow {
    final switch(type) {
        case ShaderType.SHADER_VERTEX:
            return GL_VERTEX_SHADER;
        case ShaderType.SHADER_FRAGMENT:
            return GL_FRAGMENT_SHADER;
        case ShaderType.SHADER_COMPUTE:
            return GL_COMPUTE_SHADER;
    }
}

class GLShaderProgram : ShaderProgram {
    private GLuint programId;

    this() @safe {
        gl_check();
        
        setup();
    }
    
    private void setup() @trusted {
        programId = glCreateProgram();
    }
    
    override {
        void prepareProgram() @system {
            glLinkProgram(programId);
        }
        
        void addShader_(shared Shader shader_) @system {
            GLShader shader = cast(GLShader) shader_;
            if(!shader) {
                throw new InvalidArgumentException("Shader must be instance of GLShader!");
            }
            glAttachShader(programId, shader.shaderId);
        }
        
        void removeShader_(shared Shader shader_) @system {
            GLShader shader = cast(GLShader) shader_;
            if(!shader) {
                throw new InvalidArgumentException("Shader must be instance of GLShader!");
            }
            glDetachShader(programId, shader.shaderId);
        }
    }
}

class GLShader : Shader {
    package GLuint shaderId;

    /// Please use Shader.shaderFactory()
    this(in string filename, in ShaderType type) @safe {
        super(filename, type);

        gl_check();

        setup();
    }

    private void setup() @trusted {
        import blocksound.util : toCString;

        shaderId = glCreateShader(shaderTypeToGL(this.type));
        char* source = toCString(readFileToString(filename));
        glShaderSource(shaderId, 1, &source, null);
    }

    override {
        shared protected void onShaderAdd() @system nothrow {
            glCompileShader(shaderId);
        }

        shared protected void cleanup() @system nothrow {
            glDeleteShader(shaderId);
        }
    }
}