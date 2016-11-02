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

class WindowKeyPressedEvent : WindowEvent {
    immutable int key;
    
    this(in int key, Window window) @safe nothrow {
        super(window);
        
        this.key = key;
    }
}