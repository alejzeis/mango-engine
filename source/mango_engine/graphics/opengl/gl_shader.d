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

version(mango_GLBackend) {
    import mango_engine.game;
    import mango_engine.graphics.shader;

    import blocksound.util : toCString;

    import derelict.opengl3.gl3;

    /// Gets the OpenGL constant for a specific ShaderType.
    GLuint shaderTypeToGL(ShaderType type) @safe nothrow {
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
        package GLuint programId;

        this(GameManager game) @safe {
            super(game);

            game.renderer.submitOperation(&this.setup);
        }

        private void setup() @trusted nothrow {
            this.programId = glCreateProgram();
        }

        void use() @system nothrow {
            glUseProgram(this.programId);
        }

        override {
            void prepareForUse() @trusted {
                this.game.renderer.submitOperation(() {
                    glLinkProgram(this.programId);

                    glValidateProgram(this.programId);
                });
            }

            protected void onShaderAdd(Shader shader) @system 
            in {
                assert((cast(GLShader) shader) !is null, "Shader instance must be of GLShader!");
            } body {
                shared GLShader shader_ = cast(shared GLShader) shader;

                this.game.renderer.submitOperation(() {
                    debug(mango_GLShaderInfo) {
                        import std.stdio;
                        writeln("Attaching: ", shader_.shaderId);
                    }
                    glAttachShader(this.programId, shader_.shaderId);
                });
            }

            protected void onShaderRemove(Shader shader) @system
            in {
                assert((cast(GLShader) shader) !is null, "Shader instance must be of GLShader!");
            } body {
                shared GLShader shader_ = cast(shared GLShader) shader;

                this.game.renderer.submitOperation(() {
                    glDetachShader(this.programId, shader_.shaderId);
                });
            }
        }
    }

    class GLShader : Shader {
        package immutable string source;
        package shared GLuint shaderId;

        this(GameManager game, in string source, in ShaderType type) @safe {
            super(game, source, type);
            this.source = source;

            game.renderer.submitOperation(&this.setup);
        }

        private void setup() @system {
            this.shaderId = glCreateShader(shaderTypeToGL(type));
            
            char* source = toCString(this.source);
            glShaderSource(this.shaderId, 1, &source, null);
        }

        override {
            protected void onShaderAdd() @system {
                this.game.renderer.submitOperation(() {
                    debug(mango_GLShaderInfo) {
                        import std.stdio;
                        writeln("Compiling Shader! ", this.shaderId);
                    }
                    glCompileShader(this.shaderId);
                });
            }

            protected void cleanup() @system {
                this.game.renderer.submitOperation(() {
                    glDeleteShader(this.shaderId);
                });
            }
        }
    }
}