module mango_engine.graphics.model;

import gl3n.linalg;

/// Struct that represents a Vertex with a vec3 (position)
class Vertex {
    /// Vector containing the Vertex's coordinates (3D).
    vec3 position;

    this(vec3 position) @safe nothrow {
        this.position = position;
    }
}

class Model {
    private Vertex[] vertices;
}