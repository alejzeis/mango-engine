module mango_engine.event.core;

import mango_engine.game;
import mango_engine.exception;
import mango_engine.util;

/// Represents a callable event with properties.
abstract class Event {

}

/// Event that is fired each tick.
class TickEvent : Event {
    string testString;
}

alias HookDelegate = void delegate(Event e) @system;

struct EventHook {
    /// The function delegate to be ran.
    HookDelegate hook;
    /// If the delegate can be ran in a separate worker thread.
    bool runAsync = true;
}

class EventManager {
    private ThreadPool pool;
    private GameManager game;

    private shared SyncLock hookLock;
    private shared EventHook[][string] hooks;

    private shared SyncLock evtQueueLock;
    private shared size_t evtQueueCounter = 0;
    private shared Event[size_t] evtQueue;

    this(GameManager game) @safe {
        this.game = game;
        this.pool = new ThreadPool(4); //TODO: Modify worker number on CPU cores/configManager

        this.evtQueueLock = new shared SyncLock();
        this.hookLock = new shared SyncLock();
    }

    /++
        Adds an event to the firing queue. The event
        will be fired on the next EventManager update
        pass.
    +/
    void fireEvent(Event event) @trusted {
        import core.atomic : atomicOp;
        synchronized(this.evtQueueLock) {
            this.evtQueue[atomicOp!"+="(this.evtQueueCounter, 1)] = cast(shared) event;
        }
    }

    void registerEventHook(in string eventType, EventHook hook) @trusted {
        synchronized(this.hookLock) {
            hooks[eventType] ~= cast(shared) hook;
        }
    }

    /// Update function called by GameManager
    void update() @trusted {
        synchronized(this.evtQueueLock) {
            if(this.evtQueue.length < 1) return; // If the queue is empty, return

            size_t[] toRemove;
            foreach(size_t key, shared(Event) event; this.evtQueue) {
                if(event.classinfo.name in hooks) { // Check if there is a hook(s) for the event type
                    foreach(EventHook hook; hooks[event.classinfo.name]) {
                        if(hook.runAsync) { // Check if we can run this in a worker
                            pool.submitWork(() {
                                hook.hook(cast(Event) event);
                            });
                        } else {
                            hook.hook(cast(Event) event);
                        }
                    }
                } else {
                    debug {
                        import std.stdio;
                        writeln("Not found: ", event.classinfo.name);
                    }
                }
                toRemove ~= key; // Add the event's key to the remove list.
            }

            foreach(size_t key; toRemove) { // Remove all the processed events
                this.evtQueue.remove(key);
                debug {
                    import std.stdio;
                    writeln("Removed: ", key);
                }
            }
        }
    }
}