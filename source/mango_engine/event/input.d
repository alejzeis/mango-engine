module mango_engine.event.input;

import mango_engine.event.core;

class KeyPressEvent : Event {
    private int _key;
    private int _scancode;

    @property int key() @safe nothrow { return _key; }
    @property int scancode() @safe nothrow { return _scancode; }

    this(in int key, in int scancode) @safe nothrow {
        this._key = key;
        this._scancode = scancode;
    }
}