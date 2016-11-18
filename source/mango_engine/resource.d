module mango_engine.resource;

import mango_engine.game;
import mango_engine.world;
import mango_engine.util;
import mango_engine.graphics.texture;
import mango_engine.graphics.shader;

import std.zip;
import std.file;
import std.json;
import std.array;
import std.exception;

class ResourceManager {
    private shared GameManager _game;

    @property GameManager game() @trusted nothrow { return cast(GameManager) _game; }

    this(GameManager game) @trusted nothrow {
        this._game = cast(shared) game;
    }

    Texture loadTexture(in string location) {
        enforce(exists(location), "File " ~ location ~ " does not exist!");
        enforce(split(location, ".")[1] == "marchive", "File " ~ location ~ " is not a valid .marchive file!");

        auto zip = new ZipArchive(read(location));
        foreach(name, am; zip.directory) {
            // TODO finish
        }

        return null;
    }
}