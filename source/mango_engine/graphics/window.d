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
module mango_engine.graphics.window;

import mango_engine.mango;

/// Represents different screen sync types
enum SyncType {
    /// No sync
    SYNC_NONE,
    /// Vertical Sync (double/triple buffering)
    SYNC_VSYNC,
    /// Adaptive Sync (G-Sync, FreeSync)
    SYNC_ADAPTIVE
}

/++
    Represents a surface that the backend
    renders on.
+/
abstract class Window {
    private shared string _title;
    private shared uint _width;
    private shared uint _height;
    private SyncType _syncType;

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
    /// The type of synchronization the window is using.
    @property SyncType syncType() @safe nothrow { return _syncType; }

    protected this(in string title, in uint width, in uint height, SyncType syncType) @safe nothrow {
        this._title = title;
        this._width = width;
        this._height = height;
        this._syncType = syncType;
    }

    /++
        Create a new window based on the GraphicsBackendType.
        If the backend has not been compiled into mango-engine,
        an exception will be thrown.

        Params:
                title =     The title of the Window.
                width =     The width of the window (in pixels)
                height =    The height of the window (in pixels)
                syncType =  The SyncType used by the window.
                backend =   The Backend to use for rendering. This needs
                            to be consistent across your application,
                            or else there will be strange bugs.
                            
        Throws: Exception if no backends are avaliable.
    +/
    static Window windowFactory(in string title, in uint width, in uint height, SyncType syncType, GraphicsBackendType backend) @safe {
        version(mango_GLBackend) {
            import mango_engine.graphics.opengl.gl_window : GLWindow;
            
            if(backend == GraphicsBackendType.API_OPENGL)
                return new GLWindow(title, width, height, syncType);
        }
        /*
        version(mango_VKBackend) {
            import mango_engine.graphics.vulkan.vk_window : VKWindow;
            if(backend == GraphicsBackendType.API_VULKAN)
                return new VKWindow(title, width, height);
        }
        */
        throw new Exception("No backends avaliable, was it compiled in?");
    }

    final void resize(in uint width, in uint height) @trusted {
        _width = width;
        _height = height;
        resize_(width, height);
    }

    abstract void updateBuffers() @system;
    protected abstract void setSync_(in SyncType syncType) @system;
    protected abstract void setTitle_(in string title) @system;
    protected abstract void resize_(in uint width, in uint height) @system;
}