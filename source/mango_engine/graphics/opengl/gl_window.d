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

import mango_engine.graphics.opengl.gl_backend;
import mango_engine.graphics.window;
import mango_engine.logging;
import mango_engine.game;
import mango_engine.event.core;
import mango_engine.event.input;

import blocksound.util : toCString, toDString;

import derelict.glfw3;
import derelict.opengl3.gl3 : glGetString, GL_VERSION, GL_RENDERER, GL_VENDOR;

import std.conv;

package __gshared GLWindow[GLFWwindow*] windows;

extern(C) void glwindow_glfwKeyCallback(GLFWwindow* window, int key, int scancode, int action, int mods) @system nothrow {
    windows[window].onKey(key, scancode);
}

class GLWindow : Window {
    private GLFWwindow* window;
    private shared size_t keyEventCounter;
    private shared KeyPressEvent[size_t] keyEvents;

    this(in string title, in uint width, in uint height, SyncType syncType) @safe {
        super(title, width, height, syncType);
        gl_check();

        createWindow();
    }

    private void createWindow() @trusted {
        // Set OpenGL Information
        glfwWindowHint(GLFW_CLIENT_API, GLFW_OPENGL_API);
        glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, MANGO_GL_VERSION_MAJOR);
        glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, MANGO_GL_VERSION_MINOR);

        window = glfwCreateWindow(width, height, toCString(title), null, null);
        if(!window) {
            if(failedContext) { // From gl_backend
                throw new WindowContextFailedException("Context Failed! Does the host machine support OpenGL " ~ MANGO_GL_VERSION_STRING ~ "?");
            } else 
                throw new Exception("Failed to create window!");
        }

        glfwMakeContextCurrent(window); // Set our main OpenGL context

        GLBackend.loadCoreMethods(); // Load the non-deprecated methods (core)

        string glVersion = toDString(glGetString(GL_VERSION));
        // getBackendLogger: from gl_backend.d
        getBackendLogger().logInfo("GL_VERSION: " ~ glVersion);
        getBackendLogger().logInfo("GL_RENDERER: " ~ toDString(glGetString(GL_RENDERER)));
        getBackendLogger().logInfo("GL_VENDOR: " ~ toDString(glGetString(GL_VENDOR)));

        glfwSetKeyCallback(window, &glwindow_glfwKeyCallback);
    }

    package void onKey(int key, int scancode) @system nothrow {
        import core.atomic;
        keyEvents[atomicOp!"+="(keyEventCounter, 1)] = cast(shared) new KeyPressEvent(key, scancode);
    }

    private void evtHook_processInput(Event e) @system {
        glfwPollEvents();

        size_t[] toRemove;
        foreach(key, event; keyEvents) {
            game.eventManager.fireEvent(cast(KeyPressEvent) event);
        }

        foreach(t; toRemove)
            keyEvents.remove(t);

        if(glfwWindowShouldClose(window)) {
            game.stop();
        }
    }
    
    override {
        protected void setGame_() @system {
            game.eventManager.registerEventHook(TickEvent.classinfo.name,
                EventHook(&this.evtHook_processInput, false)
            );
        }

        shared void updateBuffers() @system {
            glfwSwapBuffers(cast(GLFWwindow*) window);
        }

        protected void setSync_(in SyncType syncType) @system {
            final switch(syncType) {
                case SyncType.SYNC_NONE:
                    glfwSwapInterval(0);
                    break;
                case SyncType.SYNC_VSYNC:
                    glfwSwapInterval(1);
                    break;
                case SyncType.SYNC_ADAPTIVE:
                    throw new Exception("Adaptive Sync not implemented!");
            }
        }

        protected void setTitle_(in string title) @system {
            glfwSetWindowTitle(window, toCString(title));
        }

        protected void resize_(in uint width, in uint height) @system {
            glfwSetWindowSize(window, width, height);
        }
    }
}