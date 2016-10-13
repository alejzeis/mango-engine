module mango_engine.logging;

abstract class Logger {
    /// The name of the logger.
    immutable string name;

    this(in string name) @safe nothrow {
        this.name = name;
    }

    void logDebug(in string message) @safe {
        debug {
            logDebug_(message);
        }
    }

    abstract void logDebug_(in string message) @safe;

    abstract void logInfo(in string message) @safe;

    abstract void logWarn(in string message) @safe;

    abstract void logError(in string message) @safe;
}

class ConsoleLogger : Logger {
    import std.stdio;

    this(in string name) @safe nothrow {
        super(name);
    }

    override {
        void logDebug_(in string message) @safe {
            
        }

        void logInfo(in string message) @safe {

        }

        void logWarn(in string message) @safe {

        }

        void logError(in string message) @safe {

        }
    }
}