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

private void checkTextureJSON(ZipArchive archive, JSONValue root) @trusted {
    enforce(root["file"].str in archive.directory, new MArchiveParseException("Invalid Archive! Texture file could not be found in archive!"));
    enforce(root["useAlpha"].type == JSON_TYPE.TRUE || root["useAlpha"].type == JSON_TYPE.FALSE, new MArchiveParseException("Invalid Archive! useAlpha must be true or false!"));
}

class ResourceManager {
    private shared GameManager _game;

    private shared Texture[string] loadedTextures;

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
                zip.expand(am); // Uncompress the JSON information

                string data = cast(string) am.expandedData; // the contents of the JSON file
                
                JSONValue root = parseJSON(data);
                checkTextureJSON(zip, root); // Check the texture JSON for correct elements

                string textureName = root["name"].str;
                string textureFile = root["file"].str;
                bool useAlpha;
                switch(root["useAlpha"].type) {
                    case JSON_TYPE.TRUE:
                        useAlpha = true;
                        break;
                    case JSON_TYPE.FALSE:
                        useAlpha = false;
                        break;
                    default:
                        break;
                }

                enforce(!(textureName in loadedTextures), new Exception("Texture is already loaded!"));

                zip.expand(zip.directory[textureFile]); // Uncompress the texture file

                // The path in mango-engine's temp directory which will contain the uncompressed texture
                auto uncompressedPath = getTempDirectoryPath() ~ PATH_SEPERATOR ~ "mango-engine" ~ PATH_SEPERATOR ~ "texture-" ~ split(location, ".")[0];

                write(uncompressedPath, zip.directory[textureFile].expandedData); // Write the uncompressed texture to disk
                
                Texture texture = Texture.build(game, textureName, uncompressedPath, useAlpha);

                loadedTextures[textureName] = cast(shared) texture;

                return texture;
            }
        }

        throw new MArchiveParseException("Invalid Archive! Failed to find texture.json!");
    }

    Texture getLoadedTexture(in string name) @trusted {
        enforce(name in loadedTextures, new Exception("The texture is not loaded!"));

        return cast(Texture) loadedTextures[name];
    }

    void unloadTexture(in string name) @trusted {
        enforce(name in loadedTextures, new Exception("The texture is not loaded!"));

        Texture t = cast(Texture) loadedTextures[name];
        t.cleanup();

        loadedTextures.remove(name);
    }

    bool isTextureLoaded(in string name) @safe {
        return name in loadedTextures ? true : false;
    }
}

class MArchiveParseException : Exception {

    this(in string message) @safe nothrow {
        super(message);
    }
}