module mango_engine.graphics.opengl.gl_texture;

import mango_engine.graphics.texture;
import mango_engine.graphics.opengl.gl_backend;

import derelict.opengl3.gl3;
import derelict.freeimage.freeimage;

class GLTexture : Texture {
    private GLuint textureId;

    /// Use Texture.textureFactory()
    this(in string filename, in bool useAlpha = true) @safe {
        super(filename, useAlpha);

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