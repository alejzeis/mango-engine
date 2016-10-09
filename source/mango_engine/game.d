module mango_engine.game;

import mango_engine.mango;
import mango_engine.graphics.window;
import mango_engine.graphics.renderer;
import mango_engine.graphics.scene;

import std.exception : enforce;

class GameManager {
    private shared Window _window;
    private shared Renderer _renderer;
    private shared Scene _scene;

    private shared bool running = false;

    this(Window window, GraphicsBackendType backend) @trusted {
        this._window = cast(shared) window;
        this._renderer = cast(shared) Renderer.rendererFactory(backend);
    }

    void run() {
        
        enforce(!running, new Exception("Game is already running!"));

        running = true;

        while(running) {
            _window.updateBuffers();
        }
    }
}