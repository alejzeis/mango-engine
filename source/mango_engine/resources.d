module mango_engine.resources;

import mango_engine.game;
import mango_engine.graphics.texture;
import mango_engine.graphics.shader;

import std.file;
import std.exception;

/++
    Manages the application's resources, such as
    textures, shaders, configuration files, etc.
+/
class ResourceManager {
    private shared GameManager _game;

    private shared Texture[string] _loadedTextures;
    private shared ShaderProgram[string] _loadedShaders;

    @property GameManager game() @trusted nothrow { return cast(GameManager) _game; }

    /// Creates a new ResourceManager. Automatically created by the GameManager class.
    this(GameManager game) @trusted nothrow {
        this._game = cast(shared) _game;
    }

    void loadTexture(in string textureName, in string textureFile, bool useAlpha = true) @safe {
        enforce(exists(textureFile), new Exception("Texture \"" ~ textureFile ~ "\" does not exist!"));

        Texture texture = Texture.textureFactory(textureName, textureFile, useAlpha, game.backendType);
        
    }
}