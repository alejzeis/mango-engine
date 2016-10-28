module mango_engine.graphics.opengl.gl_window;

import mango_engine.graphics.window;

class GLWindow : Window {

    this(in string title, in uint width, in uint height, SyncType syncType) @safe nothrow {
        super(title, width, height, syncType);
    }

    override {
        void updateBuffers() @system {

        }

        protected void setTitle_(in string title) @system {

        }

        protected void resize_(in uint width, in uint height) @system {

        }
    }
}