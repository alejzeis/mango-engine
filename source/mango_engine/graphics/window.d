module mango_engine.graphics.window;

/++
    Represents a surface that the backend
    renders on.
+/
abstract class Window {
    private string _title;
    private uint width;
    private uint height;

    /// The title of the Window.
    @property string title() @safe nothrow { return _title; }
    /// The title of the Window.
    @property void title(in string title) @trusted {
        _title = title;
        setTitle_(title);
    }

    protected abstract string setTitle_(in string title) @system;
    protected abstract void resize_(in uint width, in uint height) @system;
}