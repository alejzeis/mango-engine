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
module mango_engine.graphics.opengl.gl_texture;

import mango_engine.graphics.texture;
import mango_engine.graphics.opengl.gl_backend;

import derelict.opengl3.gl3;
import derelict.freeimage.freeimage;

class GLTexture : Texture {
    private GLuint textureId;

    /// Use Texture.textureFactory()
    this(in string name, in string filename, in bool useAlpha = true) @safe {
        super(name, filename, useAlpha);

        gl_check();

        load();
    }

    /// Binds the texture for OpenGL use
    void bind() @system nothrow {
        glBindTexture(GL_TEXTURE_2D, textureId);
    }

    private void load() @trusted {
        FIBITMAP* bitmap = loadBitMap(filename);
        if(!bitmap) {
            throw new Exception("Failed to load texture \"" ~ filename ~ "\": null");
        }

        _width = FreeImage_GetWidth(bitmap);
        _height = FreeImage_GetHeight(bitmap);

        glGenTextures(1, &textureId);
        bind();

        setOptions();

        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, useAlpha ? GL_BGRA : GL_BGR, GL_UNSIGNED_BYTE, FreeImage_GetBits(bitmap));
        glGenerateMipmap(GL_TEXTURE_2D);

        FreeImage_Unload(bitmap);
    }

    private void setOptions() @system {
        // TODO: adjustable
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    }

    private FIBITMAP* loadBitMap(in string filename) @system {
        import blocksound.util : toCString;

        FIBITMAP* bitmap;
        FREE_IMAGE_FORMAT format;

        format = FreeImage_GetFileType(toCString(filename), 0);
        if(format == FIF_UNKNOWN) {
            throw new Exception("Invalid format!");
        }
        if(!FreeImage_FIFSupportsReading(format)) {
            throw new Exception("FreeImage does not support reading file \"" ~ filename ~ "\"");
        }
        
        bitmap = FreeImage_Load(format, toCString(filename));
        return bitmap;
    }

    override void cleanup() @system nothrow {
        glDeleteTextures(1, &textureId);
    }
}