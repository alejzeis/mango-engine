module mango_engine.graphics.opengl.gl_window;

import mango_engine.graphics.window;

import derelict.glfw3;

class GLWindow : Window {
    private GLFWwindow* window;
    
    override {
        protected string setTitle_(in string title) @system {
            
        }
    }
}