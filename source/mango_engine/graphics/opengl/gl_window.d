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
module mango_engine.graphics.opengl.gl_window;

import mango_engine.graphics.opengl.gl_backend;
import mango_engine.graphics.window;

import blocksound.util : toCString, toDString;

import derelict.glfw3;
import derelict.opengl3.gl3 : glGetString, GL_VERSION;

alias gl_check = checkSupport;

class GLWindow : Window {
    private GLFWwindow* window;

    this(in string title, in uint width, in uint height, SyncType syncType) @safe {
        super(title, width, height, syncType);
        gl_check();

        createWindow();
    }Untitled Folder

    private void createWindow() @trusted {
        // Set OpenGL Information
        glfwWindowHint(GLFW_CLIENT_API, GLFW_OPENGL_API);
        glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, MANGO_GL_VERSION_MAJOR);
        glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, MANGO_GL_VERSION_MINOR);

        window = glfwCreateWindow(width, height, toCString(title), null, null);
        if(!window) {
            throw new Exception("Failed to create window!");
        }

        glfwMakeContextCurrent(window); // Set our main OpenGL context

        GLBackend.loadCoreMethods(); // Load the non-deprecated methods (core)

        string glVersion = toDString(glGetString(GL_VERSION));
        debug {
            import std.stdio;
            writeln("GL_VERSION: ", glVersion);
        }
    }
    
    override {
        void updateBuffers() @system {
            glfwSwapBuffers(window);
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