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
import mango_engine.logging;
import mango_engine.event.core;
import mango_engine.graphics.window;
import mango_engine.graphics.renderer;

import std.exception;
import std.datetime;

import core.thread;

/// Used to create a GameManager instance. DO NOT SHARE ACROSS THREADS.
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

    Window getWindow() @safe nothrow { 
        return window;
    }

    Renderer getRenderer() @safe nothrow {
        return renderer;
    }

    GameManager build() @safe {
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
    
    private shared EventManager _eventManager;
    private shared Logger _logger;

    @property Window window() @trusted nothrow { return cast(Window) _window; }
    @property Renderer renderer() @trusted nothrow { return cast(Renderer) _renderer; }
    @property EventManager eventManager() @trusted nothrow { return cast(EventManager) _eventManager; }
    @property Logger logger() @trusted nothrow { return cast(Logger) _logger; }

    private shared bool running = false;

    package this(Logger logger, Window window, Renderer renderer, BackendType type) @trusted {
        this.backendType = type;

        window.gamemanager_notify(this);

		this._logger = cast(shared) logger;
        this._renderer = cast(shared) renderer;
        this._window = cast(shared) window;
        
        this._eventManager = cast(shared) new EventManager(this);
    }

    void run() @trusted {
        enforce(!this.running, new Exception("Game is already running!"));

        this.running = true;

        ulong ticks = 0;

        size_t fps = 300; // TODO: allow configuration
        long time = 1000 / fps;
        StopWatch sw = StopWatch();

        this.eventManager.fireEvent(new GameManagerStartEvent());

        this.logger.logDebug("Entering main loop.");

        do {
			sw.reset();
            sw.start();

            TickEvent te = new TickEvent(ticks);

            this.eventManager.fireEvent(te);
            this.eventManager.update();

            if(!renderer.running) {
                this.logger.logError("It appears the renderer thread has crashed! Exiting...");
                this.running = false;
                break;
            }

            sw.stop();
            if(sw.peek.msecs < time) {
                Thread.sleep((time - sw.peek.msecs).msecs);
            } else {
                version(mango_warnOvertime) {
                    this.logger.logWarn("Can't keep up! (" ~ to!string(sw.peek.msecs) ~ " > " ~ to!string(time) ~ ")");
                }
            }
            ticks++;
        } while(this.running);
        
        this.logger.logDebug("Cleaning up...");
        
        this.eventManager.fireEvent(new EngineCleanupEvent());
        this.eventManager.update(0);
    }
}