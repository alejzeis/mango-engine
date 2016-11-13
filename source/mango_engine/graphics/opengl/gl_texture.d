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

version(mango_GLBackend) {
    import mango_engine.game;
    import mango_engine.graphics.texture;

    import blocksound.util : toCString;

    import derelict.opengl3.gl3;
    import derelict.freeimage.freeimage;

    /// Uses FreeImage to load a BitMap.
    FIBITMAP* loadImageBitMap(in string file) @system {
        FIBITMAP* map;
        FREE_IMAGE_FORMAT format;

        format = FreeImage_GetFileType(toCString(file), 0);

        if(format == FIF_UNKNOWN) {
            throw new ImageLoadException(file ~ " has an unknown format!");
        }
        if(!FreeImage_FIFSupportsReading(format)) {
            throw new ImageLoadException(file ~ " is not supported for reading!");
        }

        map = FreeImage_Load(format, toCString(file));
        return map;
    }

    class GLTexture : Texture {
        package shared GLuint textureId;

        this(GameManager game, in string filename, in bool useAlpha = true) @safe {
            super(game, filename, useAlpha);

            this.game.renderer.submitOperation(&this.doLoad);
        }

        void use() @system nothrow {
            glBindTexture(GL_TEXTURE_2D, this.textureId);
        }

        private void doLoad() @trusted {
            FIBITMAP* map = loadImageBitMap(this.filename);
            if(!map) {
                throw new ImageLoadException("Failed to load Texture: " ~ filename);
            }

            _width = FreeImage_GetWidth(map);
            _height = FreeImage_GetHeight(map);

            GLuint id;

            glGenTextures(1, &id);
            this.textureId = id;
            use();

            setOptions();

            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, useAlpha ? GL_BGRA : GL_BGR, GL_UNSIGNED_BYTE, FreeImage_GetBits(map));
            glGenerateMipmap(GL_TEXTURE_2D);

            FreeImage_Unload(map);
        }

        protected void setOptions() @system nothrow {
            // TODO: adjustable
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        }

        override void cleanup() @system {
            this.game.renderer.submitOperation(() {
                GLuint id = this.textureId;
                
                glDeleteTextures(1, &id);
            });
        }
    }
}

/// Exception related to loading images.
class ImageLoadException : Exception {
    /// Default constructor.
    this(in string message) @safe nothrow {
        super(message);
    }
}