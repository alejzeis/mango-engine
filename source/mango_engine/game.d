module mango_engine.game;

import mango_engine.mango;
import mango_engine.event.core;
import mango_engine.graphics.window;
import mango_engine.graphics.renderer;
import mango_engine.graphics.scene;

import std.exception : enforce;
import std.datetime;

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
        import core.thread : Thread;

        enforce(!running, new Exception("Game is already running!"));

        running = true;

        size_t fps = 300; // TODO: allow configuration
        long time = 1000 / fps;
        StopWatch sw = StopWatch();

        while(running) {
            sw.reset();
            sw.start();

            TickEvent te = new TickEvent();
            te.testString = "this is a tick event.";

            eventManager.fireEvent(te);
            eventManager.update();

            sw.stop();
            if(sw.peek.msecs < time) {
                Thread.sleep((time - sw.peek.msecs).msecs);
            }
        }
    }
}