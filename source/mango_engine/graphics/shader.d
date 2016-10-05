module mango_engine.graphics.shader;

import mango_engine.mango;
import mango_engine.graphics.backend;

/++
    Base class for a ShaderProgram. Implemented
    by backends.
    
    This represents multiple shaders linked into a
    program. Each shader is of a different type,
    such as a Vertex Shader and Fragment Shader.
+/
abstract class ShaderProgram {
    private Shader[ShaderType] shaders;
    
    protected this() {
        
    }
}

enum ShaderType {
    SHADER_VERTEX,
    SHADER_FRAGMENT,
    SHADER_COMPUTE
}

/++
    The base shader class. All implementations
    will extend this.
+/
abstract class Shader {
    private immutable string _filename;
    private immutable ShaderType _type;
    
    /// The shader's filename.
    @property string filename() @safe const nothrow { return _filename; }
    /// The shader's type
    @property ShaderType type() @safe const nothrow { return _type; }
    
    protected this(in string filename, in ShaderType type) @safe nothrow {
        this._filename = filename;
        this._type = type;
    }
    
    static Shader shaderFactory(in string filename, in ShaderType type, GraphicsBackendType backend) @safe {
        import mango_engine.graphics.opengl.gl_shader;
        mixin(GenFactory!("Shader", "filename, type"));
    }
}