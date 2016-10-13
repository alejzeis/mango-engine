module mango_engine.event.graphics;
// Graphics related Events

import mango_engine.mango;
import mango_engine.event.core;
import mango_engine.graphics.model;

/// Base class for all Graphics Events
abstract class GraphicsEvent : Event {

}

/// This event is fired when a Model is about to be rendered.
class ModelRenderBeginEvent : GraphicsEvent {
    private shared Model _model;

    @property Model model() @trusted nothrow { return cast(Model) _model; }

    this(shared Model model) @safe nothrow {
        this._model = model;
    }
}