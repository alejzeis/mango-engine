module mango_engine.resource;

import mango_engine.game;
import mango_engine.world;
import mango_engine.util;
import mango_engine.graphics.texture;
import mango_engine.graphics.shader;

import std.conv;
import std.zip;
import std.file;
import std.json;
import std.array;
import std.exception;

private void checkTextureJSON(ZipArchive archive, JSONValue root) @safe {
    enforce(root["file"].str in archive.directory, new MArchiveParseException("Invalid Archive! Texture file could not be found in archive!"));
    enforce(root["useAlpha"].type == JSON_TYPE.TRUE || root["useAlpha"].type == JSON_TYPE.FALSE, new MArchiveParseException("Invalid Archive! useAlpha must be true or false!"));
}

class ResourceManager {
    private shared GameManager _game;

    @property GameManager game() @trusted nothrow { return cast(GameManager) _game; }

    this(GameManager game) @trusted nothrow {
        this._game = cast(shared) game;
    }

    Texture loadTexture(in string location) @trusted {
        enforce(exists(location), "File " ~ location ~ " does not exist!");
        enforce(split(location, ".")[1] == "marchive", "File " ~ location ~ " is not a valid .marchive file!");

        auto zip = new ZipArchive(read(location));
        foreach(name, am; zip.directory) {
            if(name == "texture.json") {
                zip.expand(am);

                string data = cast(string) am.expandedData;
                
                JSONValue root = parseJSON(data);
                checkTextureJSON(zip, root);

                string textureName = root["name"].str;
                string textureFile = root["file"].str;
                bool useAlpha = to!bool(root["useAlpha"].str);

                zip.expand(zip.directory[textureFile]);

                auto uncompressedPath = getTempDirectoryPath() ~ PATH_SEPERATOR ~ "texture-" ~ split(location, ".")[0];

                write(uncompressedPath, zip.directory[textureFile].expandedData);
                
                return Texture.build(game, uncompressedPath, useAlpha);
            }
        }

        throw new MArchiveParseException("Invalid Archive! Failed to find texture.json!");
    }
}

class MArchiveParseException : Exception {

    this(in string message) @safe nothrow {
        super(message);
    }
}