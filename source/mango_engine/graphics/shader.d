module mango_engine.graphics.shader;

import mango_engine.mango;
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
synchronized abstract class ShaderProgram {
    private shared Shader[ShaderType] shaders;

    static ShaderProgram shaderProgramFactory(GraphicsBackendType backend) @safe {
        import mango_engine.graphics.opengl.gl_shader : GLShaderProgram;

        mixin(GenFactory!("ShaderProgram"));
    }

    void addShader(shared Shader shader) @trusted {
        enforce(!(shader.type in shaders), new InvalidArgumentException("Attempted to add multiple shaders of same type."));

        shader.onShaderAdd();
        shaders[shader.type] = shader;
    }

    void removeShader(in ShaderType shaderType) @trusted {
        enforce(shaderType in shaders, new InvalidArgumentException("Attempted to remove Shader that was not added."));

        shaders[shaderType].onShaderRemove();
        shaders.remove(shaderType);
    }
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
    
    shared protected void onShaderRemove() @system {
        cleanup();
    }

    shared protected abstract void onShaderAdd() @system;
    shared protected abstract void cleanup() @system;
}