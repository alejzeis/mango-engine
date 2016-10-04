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
module mango_engine.graphics.vulkan.vk_backend;

import mango_engine.mango;
import mango_engine.graphics.backend;

version(mango_VKBackend) import erupted;

import derelict.glfw3;
import derelict.freeimage.freeimage;

version(mango_VKBackend) mixin DerelictGLFW3_VulkanBind;

package void checkSupport() @safe { // Check if we were compiled with Vulkan support.
    if(!mango_hasVKSupport()) {
        throw new Exception("Mango-Engine was not compiled with Vulkan Support!");
    }
}

class VKBackend : Backend {
    override {
        shared void loadLibraries(in string[string] args = null) @system {
            checkSupport();
            
            loadGLFW();
            loadFI();
        }

        shared void doInit() @system {
            if(!glfwInit()) {
                // GLFW failed to initalize
                throw new LibraryLoadException("GLFW", "glfwInit() Failed!");
            }

            if(!glfwVulkanSupported()) {
                throw new BackendException("GLFW: Vulkan is not supported on this system!");
            }
        }
    }
    
    private shared void loadVulkan() @system {
        try {
            
        } catch(Exception e) {
            throw new LibraryLoadException("Vulkan", e.toString());
        }
    }
    
    private shared void loadGLFW() @system { // Load code for GLFW
        version(Windows) {
            //------------------------------- Windows Load Code
            try {
                DerelictGLFW3.load("lib\\glfw3.dll");
                DerelictGLFW3_loadVulkan();
            } catch(Exception e) {
                throw new LibraryLoadException("GLFW", e.toString());
            }
            //------------------------------- End Windows Load Code
        } else { // All other OS
            try {
                DerelictGLFW3.load();
                version(mango_VKBackend) DerelictGLFW3_loadVulkan();
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
}