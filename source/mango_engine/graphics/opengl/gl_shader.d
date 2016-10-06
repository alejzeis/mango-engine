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