module mango_engine.resource;

import mango_engine.game;

class ResourceManager {
    private shared GameManager _game;

    @property GameManager game() @trusted nothrow { return cast(GameManager) _game; }

    this(GameManager game) @trusted nothrow {
        this._game = cast(shared) game;
    }

    
}