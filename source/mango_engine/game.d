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
import mango_engine.resource;
import mango_engine.input;
import mango_engine.event.core;
import mango_engine.graphics.window;
import mango_engine.graphics.renderer;

import std.exception;
import std.datetime;

import core.thread;

/// Used to create a GameManager instance. DO NOT SHARE ACROSS THREADS.
class GameManagerFactory {
    /// The Backend that will be used by the GameManager
    immutable BackendType backendType;

    private Window window;
    private Renderer renderer;

    /++
        Internal Constructor used by the Backend's Initializer
        class.
    +/
    this(BackendType type) @safe nothrow {
        this.backendType = backendType;
    }

    /++
        Sets the Window that this GameManager will render
        to.

        Params:
                window =    The Window which will be rendered to.
    +/
    void setWindow(Window window) @safe nothrow {
        this.window = window;
    }

    /++
        Sets the Renderer that this GameManager will
        use to render scenes. This is already set by
        the Backend's Initalizer, there is no need
        to reset it.

        Params:
                renderer =  The Renderer which will render
                            scenes for the GameManager.
    +/
    void setRenderer(Renderer renderer) @safe nothrow {
        this.renderer = renderer;
    }

    /++
        Gets the Window the GameManager will use
        for rendering. If it was not set, will return
        null.

        Returns: The Window the GameManager will use for
                 rendering.
    +/
    Window getWindow() @safe nothrow { 
        return window;
    }

    /++
        Gets the Renderer the GameManager will
        use to render.

        Returns: The Renderer the GameMAnager will
                 use to render scenes.
    +/
    Renderer getRenderer() @safe nothrow {
        return renderer;
    }

    /++
        Build the GameManager using all the values
        set by the set_ methods. 
        
        Make sure you have set all values before building, 
        this is checked in debug mode using assert()
        but in release you could end up with a nasty suprise!

        Returns: A new GameManager instance.
    +/
    GameManager build() @safe 
    in {
        assert(window !is null, "Window is null: please set all values before building!");
        assert(renderer !is null, "Renderer is null: please set all values before building!");
    } body {
        return new GameManager(
            new ConsoleLogger("Game"),
            window,
            renderer,
            backendType
        );
    }
}

/// Main class that handles the Game.
class GameManager {
    /// The Backend the GameManager is using for graphics output.
    immutable BackendType backendType;

    private shared Window _window;
    private shared Renderer _renderer;
    
    private shared EventManager _eventManager;
    private shared InputManager _inputManager;
    private shared ResourceManager _resourceManager;
    private shared Logger _logger;

    /// Returns: The Window this GameManager is rendering to.
    @property Window window() @trusted nothrow { return cast(Window) _window; }
    /// Returns: The Renderer this GameManager is using to render.
    @property Renderer renderer() @trusted nothrow { return cast(Renderer) _renderer; }
    /// Returns: The EventManager this GameManager is using to handle events.
    @property EventManager eventManager() @trusted nothrow { return cast(EventManager) _eventManager; }
    /// Returns: The InputManager which handles input for the Game.
    @property InputManager inputManager() @trusted nothrow { return cast(InputManager) _inputManager; }
    /// Returns: The ResourceManager used to load and manage resources from the disk (such as textures).
    @property ResourceManager resourceManager() @trusted nothrow { return cast(ResourceManager) _resourceManager; }
    /// Returns: The Logger this GameManager is using for Logging.
    @property Logger logger() @trusted nothrow { return cast(Logger) _logger; }

    private shared bool running = false;

    /// Internal constructor used by GameManagerFactory
    package this(Logger logger, Window window, Renderer renderer, BackendType type) @trusted {
        this.backendType = type;

		this._logger = cast(shared) logger;
        this._renderer = cast(shared) renderer;
        this._window = cast(shared) window;
        
        this._eventManager = cast(shared) new EventManager(this);
        this._inputManager = cast(shared) new InputManager(this);
        this._resourceManager = cast(shared) new ResourceManager(this);

        window.gamemanager_notify(this); // Tell Window that we have been created
    }

    /++
        Main run method. This will block
        until the Game has finished running.
    +/
    void run() @trusted {
        enforce(!this.running, new Exception("Game is already running!"));

        this.running = true;

        ulong ticks = 0;

        size_t fps = 144; // TODO: allow configuration
        long time = 1000 / fps;
        StopWatch sw = StopWatch();

        this.eventManager.fireEvent(new GameManagerStartEvent());

        this.logger.logDebug("Entering main loop.");

        do {
			sw.reset();
            sw.start();

            TickEvent te = new TickEvent(ticks);

            this.eventManager.update(te);

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

        if(this.renderer.running) {
            this.renderer.stop();
        }
        
        this.eventManager.fireEvent(new EngineCleanupEvent());
        this.eventManager.update(null, 0);
    }

    /++
        Tell the GameManager to stop running and quit.
        The GameManager will then cleanup resources and exit
        the run() method.
    +/
    void stop() @safe nothrow {
        this.running = false;
    }

    /// Returns: If the GameManager is currently running.
    bool isRunning() @safe nothrow {
        return this.running;
    }
}