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
module mango_engine.graphics.window;

import mango_engine.util;
import mango_engine.graphics.renderer;

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

    private shared Renderer _renderer;

    private shared string _title;
    private shared uint _width;
    private shared uint _height;
    private shared bool _visible = false;

    @property protected Renderer renderer() @trusted nothrow { return cast(Renderer) _renderer; }

    /// The title of the Window.
    @property string title() @safe nothrow { return _title; }
    /// The title of the Window.
    @property void title(in string title) @trusted {
        _title = title; // TODO: concurrency fixes!
        setTitle_(title);
    }

    /// The width of the window in pixels.
    @property uint width() @safe nothrow { return _width; }
    /// The height of the window in pixels.
    @property uint height() @safe nothrow { return _height; }
    /// If the window is currently being displayed.
    @property bool visible() @safe nothrow { return _visible; }
    /// Show or hide the window.
    @property void visible(bool visible) @trusted { 
        _visible = visible;
        setVisible_(visible);
    }

    protected this(Renderer renderer, in string title, in uint width, in uint height, SyncType syncType) @trusted nothrow {
        this._renderer = cast(shared) renderer;
        this.syncType = syncType;

        this._title = title;
        this._width = width;
        this._height = height;
    }

    static Window factoryBuild(Renderer renderer, in string title, in uint width, in uint height, SyncType syncType) {
        mixin(InterfaceClassFactory!("window", "Window", "renderer, title, width, height, syncType"));
    }

    protected abstract void setTitle_(in string title) @system;
    protected abstract void setVisible_(in bool visible) @system;
    protected abstract void resize_(in uint width, in uint height) @system;
}