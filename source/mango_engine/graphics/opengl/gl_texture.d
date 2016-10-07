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

    private void load() @trusted {
        FIBITMAP* bitmap = loadBitMap(filename);
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
}