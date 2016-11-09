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
module mango_engine.mango;

import mango_engine.game;
import mango_engine.logging;

/// The Global logger for Mango-Engine. This is statically initalized.
__gshared Logger GLOBAL_LOGGER;
/// The Version of the library.
immutable string VERSION = "v2.0.0-SNAPSHOT";

shared BackendType currentBackendType;

static this() {
    GLOBAL_LOGGER = new ConsoleLogger("Mango-Global");
}

/// The type of backend that the engine can/will use.
enum BackendType {
    BACKEND_OPENGL,
    BACKEND_VULKAN
}

/// Class used to initalize the engine depending on the backend.
abstract class EngineInitalizer {
    protected Logger logger;

    package this(Logger logger) @safe nothrow {
        this.logger = logger;
    }

    abstract protected GameManagerFactory doInit() @trusted;

    abstract protected void doDestroy() @trusted;
}

/++
    Initalizes the engine. This will return a GameManagerFactory
    instance, which can be used to construct a GameManager
    instance.
+/
GameManagerFactory mango_init(BackendType type) @trusted {
    GLOBAL_LOGGER.logInfo("Mango-Engine version " ~ VERSION ~ ", built with " ~ __VENDOR__ ~ " on " ~ __TIMESTAMP__);
    
    version(mango_GLBackend) {
        import mango_engine.graphics.opengl.gl_backend : GLInitalizer;

        currentBackendType = type;

        if(type == BackendType.BACKEND_OPENGL) {
            EngineInitalizer initalizer = new GLInitalizer(new ConsoleLogger("GLBackendInitalizer"));
            return initalizer.doInit();
        }
    }

    throw new Exception("No backend has been compiled in!");
}