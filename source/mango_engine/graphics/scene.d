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
module mango_engine.graphics.scene;

import mango_engine.exception;
import mango_engine.graphics.model;
import mango_engine.graphics.texture;
import mango_engine.graphics.shader;

import std.exception : enforce;

/// Represents a Scene with Models
synchronized class Scene {
    protected immutable string _name;

    @property string name() const @safe nothrow { return _name; } 

    private size_t modelCounter = 0;

    package Model[size_t] models;
    package Texture[string] textures;
    package ShaderProgram[string] shaders;

    package bool isRendering = false;

    this(in string name) @safe nothrow {
        this._name = name;
    }

    size_t addModel(shared Model model) @trusted nothrow {
        import core.atomic : atomicOp;

        this.models[atomicOp!"+="(modelCounter, 1)] = model;
        return modelCounter;
    }

    void addTexture(in string textureName, shared Texture texture) @safe nothrow {
        this.textures[textureName] = texture;
    }

    void addShader(in string shaderName, shared ShaderProgram shader) @safe nothrow {
        this.shaders[shaderName] = shader;
    }

    void removeModel(in size_t modelId) @safe {
        enforce(modelId in this.models, new InvalidArgumentException("Invalid modelId! (not a valid key)"));

        this.models.remove(modelId);
    }

    void removeTexture(in string textureName) @safe {
        enforce(textureName in this.textures, new InvalidArgumentException("Invalid textureName (not a valid key)"));

        this.textures.remove(textureName);
    }

    void removeShader(in string shaderName) @safe {
        enforce(shaderName in this.shaders, new InvalidArgumentException("Invalid shaderName (not a valid key)"));

        this.shaders.remove(shaderName);
    }
}