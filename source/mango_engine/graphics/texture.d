module mango_engine.graphics.texture;

import mango_engine.mango;
import mango_engine.graphics.backend;
import mango_engine.graphics.opengl.gl_backend;

class Texture {
    immutable string filename;
    immutable bool useAlpha;

    protected uint _width;
    protected uint _height;

    /// The width of the texture in pixels.
    @property uint width() @safe nothrow { return _width; }
    /// The height of the texture in pixels.
    @property uint height() @safe nothrow { return _height; }

    protected this(in string filename, in bool useAlpha = true) @safe nothrow {
        this.filename = filename;
        this.useAlpha = useAlpha;
    }

    static Texture textureFactory(in string filename, in bool useAlpha, GraphicsBackendType backend) @safe {
        import mango_engine.graphics.opengl.gl_texture : GLTexture;

        mixin(GenFactory!("Texture", "filename, useAlpha"));
    }

    abstract void cleanup() @system;
}