module mango_engine.input;

import mango_engine.game;

import std.concurrency;

immutable size_t INPUT_TYPE_KEY;
immutable size_t INPUT_TYPE_MOUSE;

/// Represents data for a given input type.
abstract class InputData {

} 

/// The InputHook delegate, which is called when input is received.
public alias InputHook = void delegate(size_t type, InputData data) @system;

/++
    Handles input and processes them in
    InputHooks.
+/
class InputManager {
    private shared GameManager _game;

    @property GameManager game() @trusted nothrow { return cast(GameManager) _game; }

    this(GameManager game) @system {
        this._game = cast(shared) game;
        
        
    }
}

private void spawnInputThread(shared InputManager manager) @system {
    import core.thread;

    Thread.getThis().name = "InputManager";

    (cast(InputManager) manager).run();
}