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
    import mango_engine.event.core;
    import mango_engine.event.graphics;
    import mango_engine.graphics.renderer;
    import mango_engine.graphics.opengl.gl_backend;
    import mango_engine.graphics.opengl.gl_renderer;

    import blocksound.util : toCString, toDString; // TODO: move to mango_stl
    import mango_stl.collections;

    import derelict.glfw3.glfw3;
    import derelict.opengl3.gl3 : glViewport, glGetString, GL_VERSION, GL_RENDERER, GL_VENDOR;

    import std.conv;

    private struct KeyEvent {
        GLFWwindow* window;
        int key;
        int scancode;
        int action;
        int mods;
    }

    private __gshared UnsafeQueue!KeyEvent keyEventQueue;

    extern(C) private void glfw_windowSizeCallback(GLFWwindow* window, int width, int height) @system nothrow {
        glViewport(0, 0, width, height); // Tell OpenGL the window was resized
    }
    
    extern(C) private void glfw_keyEventCallback(GLFWwindow* window, int key, int scancode, int action, int mods) @system nothrow {
        keyEventQueue.add(KeyEvent(window, key, scancode, action, mods)); // Add the keyEvent to the queue
    }

    class GLWindow : Window {
        __gshared {
            private GLFWwindow* window;
        }

        this(Renderer renderer, in string title, in uint width, in uint height, SyncType syncType) @trusted {
            super(renderer, title, width, height, syncType);

            if(keyEventQueue is null) {
                keyEventQueue = new UnsafeQueue!KeyEvent();
            } else keyEventQueue.clear();

            renderer.submitOperation(&this.setupWindow);
        }

        private void setupWindow() @trusted 
        in {
            assert((cast(GLRenderer) this.renderer) !is null, "renderer not instanceof GLRenderer!");
        } body {
            glfwWindowHint(GLFW_CLIENT_API, GLFW_OPENGL_API);
            glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, MANGO_GL_VERSION_MAJOR);
            glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, MANGO_GL_VERSION_MINOR);

            this.window = glfwCreateWindow(this.width, this.height, toCString(this.title), null, null);
            if(!window) {
                throw new Exception("Failed to create window! Does the host machine support OpenGL " ~ MANGO_GL_VERSION ~ "?");
            }

            glfwMakeContextCurrent(this.window);

            glbackend_loadCoreMethods();

            glfwSetWindowSizeCallback(this.window, &glfw_windowSizeCallback);
            glfwSetKeyCallback(this.window, &glfw_keyEventCallback);

            string glVersion = toDString(glGetString(GL_VERSION));
        
            GLOBAL_LOGGER.logInfo("GL_VERSION: " ~ glVersion);
            GLOBAL_LOGGER.logInfo("GL_RENDERER: " ~ toDString(glGetString(GL_RENDERER)));
            GLOBAL_LOGGER.logInfo("GL_VENDOR: " ~ toDString(glGetString(GL_VENDOR)));

            (cast(GLRenderer) this.renderer).registerWindowId(this.window);
        }

        override {
            protected void setTitle_(in string title) @system {
                this.renderer.submitOperation(() {
                    this.game.logger.logDebug("Window title changed to " ~ title);
                    glfwSetWindowTitle(this.window, toCString(title));
                });
            }

            protected void setVisible_(in bool visible) @system {
                this.renderer.submitOperation(() {
                    this.game.logger.logDebug("Window set visible: " ~ to!string(visible));
                    if(visible) {
                        glfwShowWindow(this.window);
                    } else {
                        glfwHideWindow(this.window);
                    }
                });
            }

            protected void resize_(in uint width, in uint height) @system {
                this.renderer.submitOperation(() {
                    this.game.logger.logDebug("Window manually resized to " ~ to!string(width) ~ "x" ~ to!string(height));
                    glfwSetWindowSize(this.window, width, height);
                });
            }

            protected void onGamemanager_notify() @system {
                this.game.eventManager.registerEventHook(TickEvent.classinfo.name, EventHook((Event e) {
                    if(!keyEventQueue.isEmpty()) {
                        KeyEvent keyEvent = keyEventQueue.pop();
                        this.game.eventManager.fireEvent(new WindowKeyPressedEvent(keyEvent.key, this));
                    }
                }, false)); // TODO: get to work on it's own thread?

                this.game.eventManager.registerEventHook(TickEvent.classinfo.name, EventHook((Event e) {
                    if(this.window is null) return;
                    
                    if(glfwWindowShouldClose(this.window)) {
                        this.game.logger.logDebug("Window closing.");
                        this.game.stop();
                    }
                }));
            }
        }
    }
}