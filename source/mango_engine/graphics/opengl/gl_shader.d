module mango_engine.graphics.opengl.gl_shader;

import mango_engine.util;
import mango_engine.graphics.shader;
import mango_engine.graphics.opengl.gl_backend;

import derelict.opengl3.gl3;

/// Converts a ShaderType enum to a GLuint for OpenGL.
GLuint shaderTypeToGL(in ShaderType type) {
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
    
}

class GLShader : Shader {
    private GLuint shaderId;

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
        shared protected void onShaderAdd() @system {
            glCompileShader(shaderId);
        }

        shared protected void cleanup() @system {
            glDeleteShader(shaderId);
        }
    }
}