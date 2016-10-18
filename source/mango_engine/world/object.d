module mango_engine.world.object;

import mango_engine.game;
import mango_engine.graphics.model;

/// Represents an object in the world.
class MangoObject {
    private shared Model _model;

    @property Model model() @trusted nothrow { return cast(Model) _model; }

    this(Model model) @trusted nothrow {
        this._model = cast(shared) model;
    }
}