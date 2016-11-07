module mango_engine.graphics.shader;

import mango_engine.game;
import mango_engine.util;

import mango_stl.misc;

import std.exception;

/// Represents a type of Shader.
enum ShaderType {
    /// A Vertex Shader that processes vertices.
    SHADER_VERTEX,
    /// A Fragment Shader that processes pixels.
    SHADER_FRAGMENT,
    /// A Compute Shader
    SHADER_COMPUTE
}

/// Represents a ShaderProgram that is executed
abstract class ShaderProgram {
    private shared GameManager _game;

    private shared Shader[ShaderType] shaders;
    private shared Lock lock;

    /// The GameManager this ShaderProgram belongs to.
    @property GameManager game() @trusted nothrow { return cast(GameManager) _game; }

    protected this(GameManager game) @trusted nothrow {
        this._game = cast(shared) game;
        this.lock = new Lock();
    }

    static ShaderProgram build(GameManager game) @safe {
        mixin(InterfaceClassFactory!("shader", "ShaderProgram", "game"));
    }

    void addShader(Shader shader) @trusted {
        synchronized(lock) {
            enforce(!(shader.type in shaders), new Exception("Attempted to add multiple shaders of same type."));
    
            shader.onShaderAdd();
            onShaderAdd(shader);
            shaders[shader.type] = cast(shared) shader;
        }
    }

    void removeShader(in ShaderType shaderType) @trusted {
        synchronized(lock) {
            enforce(shaderType in shaders, new Exception("Attempted to remove Shader that was not added."));
    
            onShaderRemove((cast(Shader)shaders[shaderType]));
            (cast(Shader) shaders[shaderType]).onShaderRemove();
            shaders.remove(shaderType);
        }
    }

    /++
        Prepares the ShaderProgram for use. Make
        sure to call after adding all the shaders
        to be used.
    +/
    abstract void prepareForUse() @trusted;

    protected abstract void onShaderAdd(Shader shader) @system;
    protected abstract void onShaderRemove(Shader shader) @system;
}

/// Represents an individual Shader which can be added to a ShaderProgram.
abstract class Shader {
    private shared GameManager _game;

    immutable ShaderType type;

    @property GameManager game() @trusted nothrow { return cast(GameManager) _game; }

    this(GameManager game, in string source, in ShaderType type) @trusted nothrow {
        this._game = cast(shared) game;
        this.type = type;
    }

    static Shader build(GameManager game, in string source, in ShaderType type) @safe {
        mixin(InterfaceClassFactory!("shader", "Shader", "game, source, type"));
    }

    protected abstract void onShaderAdd() @system;

    protected void onShaderRemove() @system {
        cleanup();
    }

    protected abstract void cleanup() @system;
}