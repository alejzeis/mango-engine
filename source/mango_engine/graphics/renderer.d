module mango_engine.graphics.renderer;

import mango_engine.graphics.scene;

/++
    The main class that handles rendering
    on the screen.
+/
abstract class Renderer {
    private shared Scene _scene;

    /// The scene that is currently being rendered.
    @property Scene scene() @trusted nothrow { return cast(Scene) _scene; }

    /// Render the scene
    final void render() @trusted {

    }

    protected abstract void render_() @system;
}