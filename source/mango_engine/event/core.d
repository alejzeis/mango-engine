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
module mango_engine.event.core;

import mango_engine.game;
import mango_engine.util;

import mango_stl.collections;

import std.conv;

/// Represents a callable event with properties.
abstract class Event {

}

/// Event that is fired each tick.
class TickEvent : Event {
    /// The current tick the GameManager is on.
    immutable ulong currentTick;

    this(in ulong currentTick) @safe nothrow pure {
        this.currentTick = currentTick;
    }
}

/// Event that is fired when the GameManager.run() method is called.
class GameManagerStartEvent : Event {

}

/// Event that is fired when the engine begins to clean up.
class EngineCleanupEvent : Event {

}

/// Alias for a delegate used for an event hook.
alias HookDelegate = void delegate(Event evt) @system;

/// Represents a hook that is called for a specific event.
struct EventHook {
    /// The function delegate to be ran.
    immutable HookDelegate hook;
    /// If the delegate can be ran in a separate worker thread.
    immutable bool runAsync = true;
}

/// Handles all Event related activities.
class EventManager {
	__gshared {
		private ThreadPool pool;
		private GameManager game;
		
		private Queue!Event eventQueue;
	}
	
	private shared SyncLock hookLock;
	private shared EventHook[][string] hooks;
	
	this(GameManager game) @trusted {
		import core.cpuid : coresPerCPU;
		
		this.game = game;
		this.game.logger.logInfo("This CPU has " ~ to!string(coresPerCPU()) ~ " cores avaliable. Assigning one worker thread to each.");
		this.pool = new ThreadPool(coresPerCPU());
		this.eventQueue = new Queue!Event();
		
		this.hookLock = new SyncLock();
		
		this.registerEventHook(EngineCleanupEvent.classinfo.name, EventHook(&this.stop, false));
	}
	
	
	private void stop(Event evt) @trusted {
        this.pool.stopImmediate();
    }

    /++
        Adds an event to the firing queue. The event
        will be fired on the next EventManager update
        pass.

        Params:
                event =  The Event to be fired.    
    +/
    void fireEvent(Event event) @trusted {
        this.eventQueue.add(event); // Queue is thread-safe
        debug {
            //this.eventQueue.debugDump();
        }
    }

    /++
        Registers an EventHook for a specific Event.
        This hook will be called when the event is fired.

        Params:
                eventType =     The event's full class name.
                                This is given by [EventClass].classinfo.name

                hook =          The EventHook to be called when
                                the Event is fired. 
    +/
    void registerEventHook(in string eventType, EventHook hook) @trusted {
        synchronized(this.hookLock) {
            this.hooks[eventType] ~= cast(shared) hook;
        }
    }

    /// Update function called by GameManager
    void update(size_t limit = 25) @trusted {
    	if(this.eventQueue.isEmpty()) return;
    	
    	if(limit == 0) {
    		limit = size_t.max;
    	}
        
    	while(!this.eventQueue.isEmpty() && (limit-- > 0)) {
    		Event event = this.eventQueue.pop();
            synchronized(this.hookLock) {
                if(event.classinfo.name in this.hooks) {
                    foreach(EventHook hook; this.hooks[event.classinfo.name]) {
                        if(hook.runAsync) { // Check if we can run this in a worker
                            pool.submitWork(() {
                                debug {
                                    import std.stdio;
                                    //writeln("Executing: ", event.classinfo.name);
                                }
                                hook.hook(cast(Event) event);
                            }, event.classinfo.name);
                        } else {
                            hook.hook(cast(Event) event);
                        }
                    }
                }
            }
    	}
    }
}