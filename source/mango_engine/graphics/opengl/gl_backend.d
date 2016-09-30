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
module mango_engine.graphics.opengl.gl_backend;

import mango_engine.graphics.backend;

version(mango_GLBackend) import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;
import derelict.freeimage.freeimage;

import std.conv : to;

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

    override {
        shared void loadLibraries(in string[string] args = null) @system {
            checkSupport();

            if("gl_useProvided" in args && to!bool(args["gl_useProvided"]) == true) {
                loadGL(true);
            } else loadGL(false);

            loadGLFW();
            loadFI();
        }

        shared void doInit() @system {
            if(!glfwInit()) {
                // GLFW failed to initalize
                throw new LibraryLoadException("GLFW", "glfwInit() Failed!");
            }
        }

        shared void doDestroy() @system {
            glfwTerminate();
        }
    }

    private shared void loadGL(bool useProvided) @system { // Load code for OpenGL
        version(mango_GLBackend) {
            version(Windows) {
                //------------------------------- Windows Load Code
                try {
                    if(useProvided) {
                        DerelictGL3.load("lib\\opengl32.dll"); // Use provided DLL
                    } else DerelictGL3.load();

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

    private shared void loadGLFW() @system { // Load code for GLFW
        version(Windows) {
            //------------------------------- Windows Load Code
            try {
                DerelictGLFW3.load("lib\\glfw3.dll");
            } catch(Exception e) {
                throw new LibraryLoadException("GLFW", e.toString());
            }
            //------------------------------- End Windows Load Code
        } else { // All other OS
            try {
                DerelictGLFW3.load();
            } catch(Exception e) {
                throw new LibraryLoadException("GLFW", e.toString());
            }
        }
    }

    private shared void loadFI() @system { // Load code for FreeImage
        version(Windows) {
            //------------------------------- Windows Load Code
            try {
                DerelictFI.load("lib\\FreeImage.dll");
            } catch(Exception e) {
                throw new LibraryLoadException("FreeImage", e.toString());
            }
            //------------------------------- End Windows Load Code
        } else { // All other OS
            try {
                DerelictFI.load();
            } catch(Exception e) {
                throw new LibraryLoadException("FreeImage", e.toString());
            }
        }
    }

    private shared void checkSupport() @system { // Check if we were compiled with OpenGL support.
        version(mango_GLBackend) {

        } else throw new Exception("Mango-Engine was not compiled with OpenGL backend support!");
    }
}