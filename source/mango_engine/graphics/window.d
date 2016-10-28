module mango_engine.graphics.window;

import mango_engine.util;

/// Represents different screen sync types
enum SyncType {
    /// No sync
    SYNC_NONE,
    /// Vertical Sync (double/triple buffering)
    SYNC_VSYNC,
    /// Adaptive Sync (G-Sync, FreeSync)
    SYNC_ADAPTIVE
}

/// Thrown when there is an error creating the Window context.
class WindowContextFailedException : Exception {
    this(in string message) {
        super(message);
    }   
}

/// Backend interface class: represents a window.
abstract class Window {
    immutable SyncType syncType;

    private shared string _title;
    private shared uint _width;
    private shared uint _height;

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

    protected this(in string title, in uint width, in uint height, SyncType syncType) @safe nothrow {
        this.syncType = syncType;

        this._title = title;
        this._width = width;
        this._height = height;
    }

    static Window factoryBuild(in string title, in uint width, in uint height, SyncType syncType) {
        mixin(InterfaceClassFactory!("window", "Window", "title, width, height, syncType"));
    }

    abstract void updateBuffers() @system;
    protected abstract void setTitle_(in string title) @system;
    protected abstract void resize_(in uint width, in uint height) @system;
}