module mango_engine.graphics.opengl.gl_window;

import mango_engine.graphics.opengl.gl_backend;
import mango_engine.graphics.window;

import blocksound.util : toCString, toDString;

import derelict.glfw3;
import derelict.opengl3.gl3 : glGetString, GL_VERSION;

alias gl_check = checkSupport;

class GLWindow : Window {
    private GLFWwindow* window;

    this(in string title, in uint width, in uint height) @safe {
        super(title, width, height);
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
            throw new Exception("Failed to create window!");
        }

        string glVersion = toDString(glGetString(GL_VERSION));
        debug {
            import std.stdio;
            writeln(glVersion);
        }
    }
    
    override {
        protected void setTitle_(in string title) @system {
            glfwSetWindowTitle(window, toCString(title));
        }

        protected void resize_(in uint width, in uint height) @system {
            glfwSetWindowSize(window, width, height);
        }
    }
}