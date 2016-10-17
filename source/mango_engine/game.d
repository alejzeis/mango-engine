module mango_engine.game;

import mango_engine.mango;
import mango_engine.exception;
import mango_engine.util;
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

    private shared SyncLock loadedScenesLock;
    private shared SyncLock sceneLock;

    private shared Scene[string] loadedScenes;

    private shared EventManager _eventManager;

    @property Window window() @trusted nothrow { return cast(Window) _window; }
    @property Renderer renderer() @trusted nothrow { return cast(Renderer) _renderer; }
    @property Scene scene() @trusted nothrow { return cast(Scene) _scene; }

    @property EventManager eventManager() @trusted nothrow { return cast(EventManager) _eventManager; }

    private shared bool running = false;

    this(Window window, GraphicsBackendType backend) @trusted {
        this._window = cast(shared) window;

        this._eventManager = cast(shared) new EventManager(this);
        this._renderer = cast(shared) Renderer.rendererFactory(this, backend);

        loadedScenesLock = new SyncLock();
        sceneLock = new SyncLock();
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

    void loadScene(Scene scene) @trusted {
        string sceneName = scene.name;
        enforce(!(sceneName in loadedScenes), new InvalidArgumentException("Scene \"" ~ sceneName ~ "\" is already loaded!"));

        synchronized(loadedScenesLock) {
            loadedScenes[sceneName] = cast(shared) scene;
        }
    }

    void unloadScene(Scene scene) @trusted {
        string sceneName = scene.name;
        enforce(sceneName in loadedScenes, new InvalidArgumentException("Scene \"" ~ sceneName ~ "\" is not loaded!"));
        enforce(this._scene.name != sceneName, new InvalidArgumentException("Can't unload the current scene being rendered!"));

        synchronized(loadedScenesLock) {
            loadedScenes.remove(sceneName);
        }
    }

    void setCurrentScene(Scene scene) @trusted {
        enforce(scene.name in loadedScenes, new InvalidArgumentException("Scene is not loaded!"));

        synchronized(sceneLock) {
            _scene = cast(shared) scene;
            renderer.setScene(scene);
        }
    }
}