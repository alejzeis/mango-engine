module mango_engine.graphics.texture;

import mango_engine.game;
import mango_engine.util;

/// Interface Class: Represents a Texture (an image)
abstract class Texture {
    /// The file path of where the texture is located.
    immutable string filename;
    /// If to use alpha when reading.
    immutable bool useAlpha;

    private shared GameManager _game;

    protected shared uint _width;
    protected shared uint _height;

    /// The width of the texture in pixels.
    @property uint width() @safe nothrow { return _width; }
    /// The height of the texture in pixels.
    @property uint height() @safe nothrow { return _height; }

    @property GameManager game() @trusted nothrow { return cast(GameManager) _game; }

    protected this(GameManager game, in string filename, in bool useAlpha = true) @trusted nothrow {
        this._game = cast(shared) game;
        this.filename = filename;
        this.useAlpha = useAlpha;
    }

    /++
        Use this method to build the correct Texture based on
        the Backend being used.

        Params:
                filename =  The location where the texture file is.
                
                useAlpha =  Defaults to true. If the image's colors
                            or other features look strange, try tweaking
                            this value.
                            
        Returns: A new loaded Texture instance using the selected backend.
    +/
    static Texture build(GameManager game, in string filename, in bool useAlpha = true) @safe {
        mixin(InterfaceClassFactory!("texture", "Texture", "game, filename, useAlpha"));
    }

    /// Cleans up resources used by the Texture.
    abstract void cleanup() @system;
}