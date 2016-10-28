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
module mango_engine.graphics.texture;

import mango_engine.mango;
import mango_engine.graphics.backend;
import mango_engine.graphics.opengl.gl_backend;

class Texture {
    /// The name of the texture that helps identify it.
    immutable string name;
    /// The filename which the texture is located in. THIS IS DIFFERENT FROM THE name!
    immutable string filename;
    immutable bool useAlpha;

    protected uint _width;
    protected uint _height;

    /// The width of the texture in pixels.
    @property uint width() @safe nothrow { return _width; }
    /// The height of the texture in pixels.
    @property uint height() @safe nothrow { return _height; }

    protected this(in string name, in string filename, in bool useAlpha = true) @safe nothrow {
        this.name = name;
        this.filename = filename;
        this.useAlpha = useAlpha;
    }

    static Texture textureFactory(in string name, in string filename, in bool useAlpha, GraphicsBackendType backend) @safe {
        import mango_engine.graphics.opengl.gl_texture : GLTexture;

        mixin(GenFactory!("Texture", "name, filename, useAlpha"));
    }

    abstract void cleanup() @system;
}