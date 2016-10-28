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
module mango_engine.graphics.opengl.gl_backend;

import mango_engine.mango;
import mango_engine.logging;
import mango_engine.graphics.backend;

import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;
import derelict.freeimage.freeimage;
import derelict.util.exception;

import std.conv : to;

/// The Major OpenGL version used by mango-engine.
immutable uint MANGO_GL_VERSION_MAJOR = 3;
/// The Minor OpenGL version used by mango-engine.
immutable uint MANGO_GL_VERSION_MINOR = 3;
/// The Whole OpenGL version used by mango-engine.
immutable GLVersion MANGO_GL_VERSION = GLVersion.GL33;
/// The OpenGL version used by mango-engine (string)
immutable string MANGO_GL_VERSION_STRING = "GL 3.3";

private alias checkSupport = gl_check;

package shared bool failedContext = false;

package shared Logger _backendLogger;
package shared GLExecutor _executor;

Logger getBackendLogger() @trusted nothrow {
    return cast(Logger) _backendLogger;
}

GLExecutor getExecutor() @trusted nothrow {
    return cast(GLExecutor) _executor;
} 

void gl_check() @safe { // Check if we were compiled with OpenGL support.
    if(!mango_hasGLSupport()) {
        throw new Exception("Mango-Engine was not compiled with OpenGL backend support!");
    }
}

extern(C) private void glfwErrorCallback(int error, const char* description) @system {
    import std.stdio : writeln;
    import blocksound.util : toDString;

    if(error == 65543) {
        failedContext = true;
    }

    getBackendLogger().logError("GLFW ERROR " ~ to!string(error) ~ ", " ~ toDString(description));
}

/++
    The OpenGL Backend implementation for mango_engine.

    Loads the following libraries:
        OpenGL
        GLFW 3
        FreeImage
    On Windows libraries will be loaded
    from the "lib" directory (should be placed in current directory),
    with the exception of OpenGL (see below).
    
    loadLibraries() accepts the following keys, values:
        "gl_useProvided" =  ONLY ON WINDOWS:
                                Attempts to load opengl32.dll from the
                                DLL library folder "lib" (by default it is loaded from the system). 
                                Set to "true" if you want to load the OpenGL DLL from here.
                                Useful for using a software renderer such as LLVMpipe.
+/
class GLBackend : Backend {

    this(Logger logger) @trusted {
        super(logger);
        // TODO: init logger based on logger class provided
        _backendLogger = cast(shared) new ConsoleLogger("GLBackend");
    }

    /// Loads the core methods of OpenGL (1.1+)
    static void loadCoreMethods() @system {
        DerelictGL3.reload();
    }

    override {
        void loadLibraries(in string[string] args = null) @system {
            checkSupport();

            if("gl_useProvided" in args && to!bool(args["gl_useProvided"]) == true) {
                loadGL(true);
            } else loadGL(false);

            loadGLFW();
            loadFI();
        }

        void doInit() @system {
            glfwSetErrorCallback(cast(GLFWerrorfun) &glfwErrorCallback);

            if(!glfwInit()) {
                // GLFW failed to initalize
                throw new LibraryLoadException("GLFW", "glfwInit() Failed!");
            }
        }

        void doDestroy() @system {
            glfwTerminate();
        }
    }

    ShouldThrow derelictShouldThrow(string symbolName) {
        // For now we will ignore missing symbols, TODO: FIX!
        logger.logWarn("Missing symbol: " ~ symbolName ~ " !");
        return ShouldThrow.No;
    }

    private void loadGL(bool useProvided) @system { // Load code for OpenGL
        logger.logDebug("Loading OpenGL...");
        version(mango_GLBackend) {
            version(Windows) {
                //------------------------------- Windows Load Code
                try {
                    if(useProvided) {
                        DerelictGL3.load("lib\\opengl32.dll"); // Use provided DLL
                        logger.logDebug("Loaded Provided opengl32.dll");
                    } else {
                        DerelictGL3.load();
                    }

                } catch(Exception e) {
                    throw new LibraryLoadException("OpenGL", e.toString());
                }
                //------------------------------- End Windows Load Code
            } else { // All other OS
                try {
                    DerelictGL3.load();
                } catch(Exception e) {
                    throw new LibraryLoadException("OpenGL", e.toString());
                }
            }
        }
    }

    private void loadGLFW() @system { // Load code for GLFW
        logger.logDebug("Loadng GLFW...");
        version(Windows) {
            //------------------------------- Windows Load Code
            try {
                DerelictGLFW3.load("lib\\glfw3.dll");
            } catch(Exception e) {
                throw new LibraryLoadException("GLFW", e.toString());
            }
            //------------------------------- End Windows Load Code
        } else { // All other OS
            DerelictGLFW3.missingSymbolCallback = &this.derelictShouldThrow;
            try {
                DerelictGLFW3.load();
            } catch(Exception e) {
                throw new LibraryLoadException("GLFW", e.toString());
            }
        }
    }

    private void loadFI() @system { // Load code for FreeImage
        logger.logDebug("Loading FreeImage...");
        version(Windows) {
            //------------------------------- Windows Load Code
            try {
                DerelictFI.load("lib\\FreeImage.dll");
            } catch(Exception e) {
                throw new LibraryLoadException("FreeImage", e.toString());
            }
            //------------------------------- End Windows Load Code
        } else { // All other OS
            DerelictFI.missingSymbolCallback = &derelictShouldThrow;
            try {
                DerelictFI.load();
            } catch(Exception e) {
                throw new LibraryLoadException("FreeImage", e.toString());
            }
        }
    }
}

import mango_engine.graphics.opengl.gl_renderer;

import std.concurrency;
import std.datetime;

alias GLExecuteOrder = void delegate() @system;

package struct GLExecuteOrderMessage {
    shared GLExecuteOrder order;
}

/++
    This class handles all OpenGL operations
    in it's own thread. This is due to the fact
    that OpenGL does not support multi-threading well.

    Any operations that call OpenGL context methods are
    routed to this thread using message passing.
+/
class GLExecutor {
    private shared Tid _threadTid;
    private shared bool _running = false;
    private shared GLRenderer _renderer;

    @property protected GLRenderer renderer() @trusted nothrow { return cast(GLRenderer) _renderer; }

    @property protected Tid threadTid() @trusted nothrow { return cast(Tid) _threadTid; }

    this() @trusted {
        _running = true;
        _threadTid = cast(shared) spawn(&startExecutorThread, cast(shared) this);
    }

    package void doRun() @system {
        getBackendLogger().logDebug("Entering GLExecutor thread.");

        do {
            uint counter = 0;
            while(processOrder() != false && counter < 15) {
                counter++;
            }

            if(_renderer !is null) {
                renderer.executor_render();
            }
        } while(_running);

        getBackendLogger().logDebug("Exiting GLExecutor thread.");
    }

    private bool processOrder() @system {
        return receiveTimeout(0.msecs,
            (GLExecuteOrderMessage m) {
                m.order();
            }
        );
    }

    package void stopExecutor() @safe nothrow {
        _running = false;
    }

    package void setRenderer(GLRenderer renderer) @trusted nothrow {
        _renderer = cast(shared) renderer;
    }
}

private void startExecutorThread(shared GLExecutor executor) @system {
    (cast(GLExecutor) executor).doRun();
}