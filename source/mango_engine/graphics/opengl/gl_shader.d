module mango_engine.graphics.opengl.gl_shader;

import mango_engine.graphics.shader;

class GLShader : Shader {
    /// Please use Shader.shaderFactory()
    this(in string filename, in ShaderType type) @safe nothrow {
        super(filename, type);
    }
}