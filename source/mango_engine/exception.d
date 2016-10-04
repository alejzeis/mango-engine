module mango_engine.exception;

/// An Exception called when an invalid argument is provided to a method.
class InvalidArgumentException : Exception {
    /++
        Exception Constructor

        Params:
                message =   The message for the exception.
    +/
    this(in string message) @safe {
        super(message);
    }
}