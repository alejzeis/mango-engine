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

version(mango_GLBackend) {
    import mango_engine.opengl.gl_backend;
    
    private shared GLBackend glBackend;
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
void mango_init() @system {
    debug(mango_debug_sysInfo) {
        import std.stdio : writeln;
        writeln("[DEBUG/MangoEngine]: Initalizing engine...");
    }

    version(mango_GLBackend) {
        glBackend = new GLBackend();
        glBackend.loadLibraries(); // TODO: ARGS

        glBackend.doInit();
    }
}

/++
    Destroy the engine. This will
    free resources used by the library.
+/
void mango_destroy() @system {
    version(mango_GLBackend) {
        glBackend.doDestroy();
    }
}