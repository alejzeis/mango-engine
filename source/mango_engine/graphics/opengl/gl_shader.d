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
        __gshared package GLuint programId;

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
                    glLinkProgram(programId);

                    glValidateProgram(programId);
                });
            }

            protected void onShaderAdd(Shader shader) @system 
            in {
                assert((cast(GLShader) shader) !is null, "Shader instance must be of GLShader!");
            } body {
                shared GLShader shader_ = cast(shared GLShader) shader;

                this.game.renderer.submitOperation(() {
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
        __gshared package GLuint shaderId;

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
                glCompileShader(this.shaderId);
            }

            protected void cleanup() @system {
                glDeleteShader(this.shaderId);
            }
        }
    }
}