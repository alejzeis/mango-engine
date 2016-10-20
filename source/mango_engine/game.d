/*
 *  BSD 3-Clause License
 *  
 *  Copyright (c) 2016, Mango-Engine Team
 *  All rights reserved.
 *  
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are met:
 *  
 *  * Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 *  
 *  * Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *  
 *  * Neither the name of the copyright holder nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *  
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 *  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 *  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 *  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 *  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 *  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 *  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 *  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 *  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
module mango_engine.game;

import mango_engine.mango;
import mango_engine.exception;
import mango_engine.util;
import mango_engine.audio;
import mango_engine.logging;
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
    private shared AudioManager _audioManager;
    private shared Logger _logger;

    @property Window window() @trusted nothrow { return cast(Window) _window; }
    @property Renderer renderer() @trusted nothrow { return cast(Renderer) _renderer; }
    @property Scene scene() @trusted nothrow { return cast(Scene) _scene; }


    @property EventManager eventManager() @trusted nothrow { return cast(EventManager) _eventManager; }
    @property AudioManager audioManager() @trusted nothrow { return cast(AudioManager) _audioManager; }
    @property Logger logger() @trusted nothrow { return cast(Logger) _logger; }

    private shared bool running = false;

    this(Window window, GraphicsBackendType backend) @trusted {
        this._window = cast(shared) window;
        initLogger();

        this._eventManager = cast(shared) new EventManager(this);
        this._audioManager = cast(shared) new AudioManager(this);
        if(window !is null) 
            this._renderer = cast(shared) Renderer.rendererFactory(this, backend);

        loadedScenesLock = new SyncLock();
        sceneLock = new SyncLock();
    }
    
    private void initLogger() @trusted {
        // TODO: make changable
        this._logger = cast(shared) new ConsoleLogger("Game");
    }

    void run() {
        import core.thread : Thread;

        enforce(!running, new Exception("Game is already running!"));

        running = true;

        size_t fps = 300; // TODO: allow configuration
        long time = 1000 / fps;
        StopWatch sw = StopWatch();

        logger.logDebug("Starting main loop...");

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
            } else {
                version(mango_warnOvertime) {
                    logger.logWarn("Can't keep up! (" ~ to!string(sw.peek.msecs) ~ " > " ~ to!string(time) ~ ")");
                }
            }
        }

        logger.logDebug("Cleaning up...");

        eventManager.fireEvent(new EngineCleanupEvent());
        eventManager.update();
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