module mango_engine.game;

import mango_engine.mango;
import mango_engine.logging;
import mango_engine.graphics.window;
import mango_engine.graphics.renderer;

import std.exception;
import std.datetime;

import core.thread;

/// Used to create a GameManager instance.
class GameManagerFactory {
    immutable BackendType backendType;

    private Window window;
    private Renderer renderer;

    this(BackendType type) @safe nothrow {
        this.backendType = backendType;
    }

    void setWindow(Window window) @safe nothrow {
        this.window = window;
    }

    void setRenderer(Renderer renderer) @safe nothrow {
        this.renderer = renderer;
    }

    GameManager build() @safe nothrow {
        return new GameManager(
            new ConsoleLogger("Game"),
            window,
            renderer,
            backendType
        );
    }
}

class GameManager {
    immutable BackendType backendType;

    private shared Window _window;
    private shared Renderer _renderer;
    private shared Logger _logger;

    @property Window window() @trusted nothrow { return cast(Window) _window; }
    @property Renderer renderer() @trusted nothrow { return cast(Renderer) _renderer; }
    @property Logger logger() @trusted nothrow { return cast(Logger) _logger; }

    private shared bool running = false;

    package this(Logger logger, Window window, Renderer renderer, BackendType type) @trusted nothrow {
        this.backendType = type;

        this._renderer = cast(shared) renderer;
        this._window = cast(shared) window;
    }

    void run() @safe {
        enforce(!running, new Exception("Game is already running!"));

        running = true;

        ulong ticks = 0;

        size_t fps = 300; // TODO: allow configuration
        long time = 1000 / fps;
        StopWatch sw = StopWatch();

        logger.logDebug("Entering main loop.");

        do {
            
        } while(running);
    }
}