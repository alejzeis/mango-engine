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
    private SyncLock lock = new SyncLock();

    static ShaderProgram shaderProgramFactory(GraphicsBackendType backend) @safe {
        import mango_engine.graphics.opengl.gl_shader : GLShaderProgram;

        mixin(GenFactory!("ShaderProgram"));
    }

    void addShader(shared Shader shader) @trusted {
        synchronized(lock) {
            enforce(!(shader.type in shaders), new InvalidArgumentException("Attempted to add multiple shaders of same type."));
    
            shader.onShaderAdd();
            addShader_(shader);
            shaders[shader.type] = shader;
        }
    }

    void removeShader(in ShaderType shaderType) @trusted {
        synchronized(lock) {
            enforce(shaderType in shaders, new InvalidArgumentException("Attempted to remove Shader that was not added."));
    
            removeShader_(shaders[shaderType]);
            shaders[shaderType].onShaderRemove();
            shaders.remove(shaderType);
        }
    }
    
    /// This is called after all the shaders have been added.
    abstract void prepareProgram() @system;
    
    abstract void addShader_(shared Shader shader) @system;
    abstract void removeShader_(shared Shader shader) @system;
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