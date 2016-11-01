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

immutable MANGO_GL_VERSION_MAJOR = 3;
immutable MANGO_GL_VERSION_MINOR = 3;
immutable MANGO_GL_VERSION = "3.3";

version(mango_GLBackend) {
    import mango_engine.game;
    import mango_engine.mango;
    import mango_engine.logging;
    import mango_engine.util;
    import mango_engine.graphics.renderer;

    import derelict.opengl3.gl3;
    import derelict.glfw3.glfw3;
    import derelict.freeimage.freeimage;
    import derelict.util.exception; 

    package void glbackend_loadCoreMethods() @system {
        DerelictGL3.reload();
    }

    class GLInitalizer : EngineInitalizer { 
        this(Logger logger) @safe nothrow {
            super(logger);
        }

        private void loadLibraries() @system {
            try {
                DerelictGL3.load();
            } catch(Exception e) {
                throw new Exception("Failed to load library OpenGL!");
            }

            mixin(LoadLibraryTemplate!("GLFW", "GLFW3", "glfw3"));
            DerelictFI.missingSymbolCallback = &this.fi_missingSymbolCB;
            mixin(LoadLibraryTemplate!("FreeImage", "FI", "FreeImage"));

            if(!glfwInit()) {
                throw new Exception("Failed to init GLFW (glfwInit)!");
            }
        }

        private ShouldThrow fi_missingSymbolCB(string symbolName) @safe {
            version(mango_warnOnMissingSymbol) {
                logger.logWarn("Missing FreeImage Symbol! " ~ symbolName);
            } else {
                logger.logDebug(" (WARNING) Missing FreeImage Symbol! " ~ symbolName);
            }
            return ShouldThrow.No;
        }

        override {
            protected GameManagerFactory doInit() @trusted {
                loadLibraries();

                GameManagerFactory factory = new GameManagerFactory(BackendType.BACKEND_OPENGL);
                factory.setRenderer(Renderer.factoryBuild());
                return factory;
            }

            protected void doDestroy() @trusted {

            }
        }
    }
}