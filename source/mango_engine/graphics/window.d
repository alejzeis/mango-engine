module mango_engine.graphics.window;

import mango_engine.mango;

/++
    Represents a surface that the backend
    renders on.
+/
abstract class Window {
    private shared string _title;
    private shared uint _width;
    private shared uint _height;

    this(in string title, in uint width, in uint height) @safe nothrow {
        this._title = title;
        this._width = width;
        this._height = height;
    }

    /++
    +/
    static Window windowFactory(in string title, in uint width, in uint height, GraphicsBackendType backend) @safe {
        version(mango_GLBackend) {
            import mango_engine.graphics.opengl.gl_window;
            
            if(backend == GraphicsBackendType.API_OPENGL)
                return new GLWindow(title, width, height);
        }
        /*
        version(mango_VKBackend) {
            import mango_engine.graphics.vulkan.vk_window;
            if(backend == GraphicsBackendType.API_VULKAN)
                return new VKWindow(title, width, height);
        }
        */
        throw new Exception("No backends avaliable!");
    }

    /// The title of the Window.
    @property string title() @safe nothrow { return _title; }
    /// The title of the Window.
    @property void title(in string title) @trusted {
        _title = title;
        setTitle_(title);
    }

    /// The width of the window in pixels.
    @property uint width() @safe nothrow { return _width; }
    /// The height of the window in pixels.
    @property uint height() @safe nothrow { return _height; }

    final void resize(in uint width, in uint height) @trusted {
        _width = width;
        _height = height;
        resize_(width, height);
    }

    protected abstract void setTitle_(in string title) @system;
    protected abstract void resize_(in uint width, in uint height) @system;
}