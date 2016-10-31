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
module mango_engine.graphics.opengl.gl_window;

version(mango_GLBackend) {
    import mango_engine.graphics.window;
    import mango_engine.mango;
    import mango_engine.graphics.opengl.gl_backend;

    import blocksound.util : toCString, toDString; // TODO: move to mango_stl

    import derelict.glfw3.glfw3;
    import derelict.opengl3.gl3 : glGetString, GL_VERSION, GL_RENDERER, GL_VENDOR;

    class GLWindow : Window {
        __gshared {
            private GLFWwindow* window;
        }

        this(in string title, in uint width, in uint height, SyncType syncType) @safe {
            super(title, width, height, syncType);

            setupWindow();
        }

        private void setupWindow() @trusted {
            glfwWindowHint(GLFW_CLIENT_API, GLFW_OPENGL_API);
            glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, MANGO_GL_VERSION_MAJOR);
            glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, MANGO_GL_VERSION_MINOR);

            window = glfwCreateWindow(width, height, toCString(title), null, null);

            // TODO: check context

            glfwMakeContextCurrent(window);

            glbackend_loadCoreMethods();

            string glVersion = toDString(glGetString(GL_VERSION));
        
            GLOBAL_LOGGER.logInfo("GL_VERSION: " ~ glVersion);
            GLOBAL_LOGGER.logInfo("GL_RENDERER: " ~ toDString(glGetString(GL_RENDERER)));
            GLOBAL_LOGGER.logInfo("GL_VENDOR: " ~ toDString(glGetString(GL_VENDOR)));
        }

        override {
            void updateBuffers() @system {

            }

            protected void setTitle_(in string title) @system {

            }

            protected void setVisible_(in bool visible) @system {

            }

            protected void resize_(in uint width, in uint height) @system {

            }
        }
    }
}