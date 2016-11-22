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
/// Graphics related events
module mango_engine.event.graphics;

import mango_engine.event.core;

import mango_engine.graphics.window;

/// Base class for an event related to graphics.
abstract class GraphicsEvent : Event {

}

/// Base class for an event related to a Window.
class WindowEvent : GraphicsEvent {
    private shared Window _window;

    @property Window window() @trusted nothrow { return cast(Window) this._window; }

    this(Window window) @trusted nothrow {
        this._window = cast(shared) window;
    }
}

class WindowShowEvent : WindowEvent {
    this(Window window) @safe nothrow {
        super(window);
    }
}

class WindowHideEvent : WindowEvent {
    this(Window window) @safe nothrow {
        super(window);
    }
}

class WindowTitleChangeEvent : WindowEvent {
    immutable string name;

    this(in string name, Window window) @safe nothrow {
        super(window);
        
        this.name = name;
    }
}

deprecated("Had too much latency. Use Window.registerInputHook()") 
class WindowKeyPressedEvent : WindowEvent {
    /++
        The key which was pressed. The values
        are found in derelict.glfw3.glfw3.

        For example, the A key's value is
        GLFW_KEY_A.
    +/
    immutable int key;
    
    this(in int key, Window window) @safe nothrow {
        super(window);
        
        this.key = key;
    }
}