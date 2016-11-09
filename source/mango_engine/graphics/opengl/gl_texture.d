module mango_engine.graphics.opengl.gl_texture;

version(mango_GLBackend) {
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
        __gshared package GLuint textureId;

        this(in string filename, in bool useAlpha = true) @safe {
            super(filename, useAlpha);

            doLoad();
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

            glGenTextures(1, &this.textureId);
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
            glDeleteTextures(1, &this.textureId);
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