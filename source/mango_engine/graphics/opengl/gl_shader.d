module mango_engine.graphics.opengl.gl_shader;

version(mango_GLBackend) {
    import mango_engine.game;
    import mango_engine.graphics.shader;

    import derelict.opengl3.gl3;

    class GLShaderProgram : ShaderProgram {
        __gshared package GLuint programId;

        this(GameManager game) @safe {
            super(game);

            game.renderer.submitOperation(&this.setup);
        }

        private void setup() @trusted nothrow {
            this.programId = glCreateProgram();
        }

        package void use() @system nothrow {
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
        __gshared package GLuint shaderId;

        this(GameManager game, in string source, in ShaderType type) @safe {
            super(game, source, type);

            game.renderer.submitOperation(&this.setup);
        }

        private void setup() @system nothrow {
            
        }

        override {
            protected void onShaderAdd() @system {

            }

            protected void cleanup() @system {

            }
        }
    }
}