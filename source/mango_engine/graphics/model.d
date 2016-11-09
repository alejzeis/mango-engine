module mango_engine.graphics.model;

import mango_engine.game;
import mango_engine.util;
import mango_engine.graphics.renderer;
import mango_engine.graphics.texture;
import mango_engine.graphics.shader;

import mango_stl.misc;

import gl3n.linalg;

/// Struct that represents a Vertex with a vec3 (position)
class Vertex {
    /// Vector containing the Vertex's coordinates (3D).
    vec3 position;

    this(vec3 position) @trusted nothrow {
        position = cast(shared) position;
    }
}

/++
    Struct that represents a Vertex with
    a position vector(vec3), and a texture
    vector (vec2).
+/
class TexturedVertex : Vertex {
    /// Vector containing the texture coordinates.
    vec2 texture;

    this(vec3 position, vec2 texture) @trusted nothrow {
        super(position);
        this.texture = cast(shared) texture;
    }
}

/// Represents a Model which can be rendered. A Model has a Shader and a Texture
class Model {
    private shared GameManager _game;
    private shared Lock lock;

    protected shared Vertex[] vertices;
    protected shared uint[] _indices;

    protected shared Texture _texture;
    protected shared ShaderProgram _shader;

    @property uint[] indices() @trusted nothrow { return cast(uint[]) _indices; }
    
    @property Texture texture() @trusted nothrow { return cast(Texture) _texture; }
    @property shared void texture(shared Texture texture) @safe {
        synchronized(lock) {
            this._texture = texture;
        }
    }
    
    @property ShaderProgram shader() @trusted nothrow { return cast(ShaderProgram) _shader; }

    protected this(GameManager game, Vertex[] vertices, uint[] indices, Texture texture, ShaderProgram shader) @trusted nothrow {
        this._game = cast(shared) game;
        this.lock = new Lock();

        this.vertices = cast(shared) vertices;
        this._indices = cast(shared) indices;

        this._texture = cast(shared) texture;
        this._shader = cast(shared) shader;
    }

    static Model build(GameManager game, Vertex[] vertices, uint[] indices, Texture texture, ShaderProgram shader) @safe {
        mixin(InterfaceClassFactory!("model", "Model", "game, vertices, indices, texture, shader"));
    }

    void render(Renderer renderer) @system {
        //game.eventManager.fireEvent(new ModelRenderBeginEvent(cast(shared) this));
        synchronized(lock) {
            render_(renderer);
        }
    }
    
    abstract void cleanup() @system;
    
    abstract protected void render_(Renderer renderer) @system;
}