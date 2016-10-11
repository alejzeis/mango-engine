module mango_engine.game;

import mango_engine.mango;
import mango_engine.event.core;
import mango_engine.graphics.window;
import mango_engine.graphics.renderer;
import mango_engine.graphics.scene;

import std.exception : enforce;

class GameManager {
    private shared Window _window;
    private shared Renderer _renderer;
    private shared Scene _scene;

    private shared EventManager _eventManager;

    @property Window window() @trusted nothrow { return cast(Window) _window; }
    @property Renderer renderer() @trusted nothrow { return cast(Renderer) _renderer; }

    @property EventManager eventManager() @trusted nothrow { return cast(EventManager) _eventManager; }

    private shared bool running = false;

    this(Window window, GraphicsBackendType backend) @trusted {
        this._window = cast(shared) window;

        this._eventManager = cast(shared) new EventManager(this);
        this._scene = new shared Scene("TestScene");

        this._renderer = cast(shared) Renderer.rendererFactory(this, backend);
        (cast(Renderer) this._renderer).setScene(cast(Scene) _scene);
    }

    void run() {
        enforce(!running, new Exception("Game is already running!"));

        running = true;

        while(running) {
            // TODO: load balancing (sleep)?
            TickEvent te = new TickEvent();
            te.testString = "this is a tick event.";

            eventManager.fireEvent(te);
            eventManager.update();
        }
    }
}