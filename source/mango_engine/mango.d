/*
 *  Copyright 2016 Mango-Engine Team
 *  
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *  
 *  	http://www.apache.org/licenses/LICENSE-2.0
 *  
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
*/
module mango_engine.mango;

import mango_engine.logging;

import std.conv;

version(mango_GLBackend) {
    import mango_engine.graphics.opengl.gl_backend;
    
    private shared GLBackend glBackend;
}

version(mango_VKBackend) {
    import mango_engine.graphics.vulkan.vk_backend;

    private shared VKBackend vkBackend;
}

immutable string MANGO_VERSION = "v1.0.0-SNAPSHOT";

/// Enum to represent different Graphics APIs used by the backend.
enum GraphicsBackendType {
    /// The OpenGL API.
    API_OPENGL,
    /// The Vulkan API.
    API_VULKAN
}

/++
    Determine if the engine has compiled with
    OpenGL support enabled.

    Returns: If the engine has support for
             OpenGL.
+/
bool mango_hasGLSupport() @safe nothrow {
    version(mango_GLBackend) {
        return true;
    } else return false;
}

/++
    Determine if the engine has compiled with
    Vulkan support enabled.

    Returns: If the engine has support for
             Vulkan.
+/
bool mango_hasVKSupport() @safe nothrow {
    version(mango_VKBackend) {
        return true;
    } else return false;
}

private shared bool hasInit = false;

/++
    Determine if the engine has been initalized.

    Returns: If the engine has been initalized.
+/
bool mango_hasInitialized() @safe nothrow {
    return hasInit;
}

/++
    Initalize the engine. This will
    load system libraries and set up
    the engine for usage.
+/
void mango_init(GraphicsBackendType backendType) @system {
    Logger logger = new ConsoleLogger("BackendInit");

    logger.logInfo("Mango Engine version " ~ MANGO_VERSION ~ " built on \"" ~ __DATE__ ~ " " ~ __TIME__ ~ "\"");
    logger.logDebug("Compiled with OpenGL support: " ~ to!string(mango_hasGLSupport()));
    logger.logDebug("Compiled with Vulkan support: " ~ to!string(mango_hasVKSupport()));

    debug(mango_debug_sysInfo) {
        import std.stdio : writeln;
        logger.logDebug("Initializing engine...");
    }

    final switch(backendType) {
        case GraphicsBackendType.API_OPENGL:
            version(mango_GLBackend) {
                logger.logInfo("Initializing OpenGL backend.");
                GLBackend _glBackend = new GLBackend(logger);
                _glBackend.loadLibraries(); // TODO: ARGS
                logger.logDebug("Loaded libraries.");

                _glBackend.doInit();
                glBackend = cast(shared) _glBackend;
            } else throw new Exception("Mango-Engine was not compiled with OpenGL support!");
            break;
        case GraphicsBackendType.API_VULKAN:
            version(mango_VKBackend) {
                logger.logInfo("Initializing Vulkan backend.");
                vkBackend = new VKBackend();
                vkBackend.loadLibraries();
                logger.logDebug("Loaded libraries.");

                vkBackend.doInit();
            } else throw new Exception("Mango-Engine was not compiled with Vulkan support!");
    }
}

/++
    Destroy the engine. This will
    free resources used by the library.
+/
void mango_destroy() @system {
    version(mango_GLBackend) {
        if(glBackend !is null)
            (cast(GLBackend) glBackend).doDestroy();
    }

    version(mango_VKBackend) {
        if(vkBackend !is null)
            vkBackend.doDestroy();
    }
}