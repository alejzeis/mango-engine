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

    void cleanup() @trusted {
        foreach(type, shader; shaders) {
            (cast(Shader) shader).cleanup();
        }
        shaders.clear();
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

    protected this(GameManager game, in string source, in ShaderType type) @trusted nothrow {
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