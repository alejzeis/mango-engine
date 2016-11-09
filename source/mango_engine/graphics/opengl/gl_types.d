module mango_engine.graphics.opengl.gl_types;

import mango_engine.graphics.model;

import derelict.opengl3.gl3;

import gl3n.linalg;

/++ 
    Converts an array of Vertexs (vertices) to a raw float array that
    contains just the vertex coordinates.
+/
float[] positionVerticesToFloats(Vertex[] vertices) @safe {
    // TODO: Will have to adapt when more vectors are added
    float[] data;
    foreach(vertex; vertices) {
        data ~= vertex.position.x;
        data ~= vertex.position.y;
        data ~= vertex.position.z;
    }
    return data;
}

/++
    Converts an array of Vertexs (vertices) to a raw float array
    containing just the texture coordinates.
+/
float[] textureVerticesToFloats(Vertex[] vertices) @trusted {
    float[] data;
    if(!(cast(TexturedVertex[]) vertices)) {
        throw new Exception("Vertices not type of TexturedVertex!");
    }
    foreach(vertex; (cast(TexturedVertex[]) vertices)) {
        data ~= vertex.texture.x;
        data ~= vertex.texture.y;
    }
    return data;
}

/// Represents an OpenGL VAO.
class VAO {
    private GLuint _vao;

    /// GLuint id for the VAO.
    @property GLuint vao() @safe nothrow { return _vao; }

    private this(GLuint vao) @safe nothrow {
        _vao = vao;
    }

    /++
        Generate a new VAO.
        (glGenVertexArrays)
        Returns: A new, empty VAO.
    +/
    static VAO generateNew() @trusted {
        GLuint id;
        glGenVertexArrays(1, &id);

        return new VAO(id);
    }

    /// Bind the VAO and make it ready for use from OpenGL.
    void bind() @system nothrow {
        glBindVertexArray(vao);
    }

    /// Unbind the VAO.
    void unbind() @system nothrow {
        glBindVertexArray(0);
    }

    /++
        Cleans up resources used by the VAO.
        Make sure to cleanup() on VBOs aswell.
    +/
    void cleanup() @system nothrow {
        glDeleteVertexArrays(1, &_vao);
    }
}

/// Represents an OpenGL VBO.
class VBO {
    private GLenum _type;
    private GLuint _vbo;

    /// The VBO's GLuint id.
    @property GLuint vbo() @safe nothrow { return _vbo; }
    /// The VBO Type, ex. GL_ARRAY_BUFFER.
    @property GLenum type() @safe nothrow { return _type; }

    /++
        Create a new VBO with the specified type.
        (glGenBuffers)
        Params:
                type =  The type (or target) of the buffer,
                        ex. GL_ARRAY_BUFFER.
    +/
    this(GLenum type) @trusted {
        _type = type;

        glGenBuffers(1, &_vbo);
    }

    /// Binds the buffer for OpenGL use.
    void bind() @system nothrow {
        glBindBuffer(type, vbo);
    }

    /++
        Sets the data of the buffer (raw).
        Params:
                data   =    The data to be placed in the buffer.
                length =    The length in bytes of the data.
                usage  =    See OpenGL docs on usage parameter in
                            glBufferData.
    +/
    void setDataRaw(GLvoid* data, GLsizei length, GLenum usage = GL_STATIC_DRAW) @system {
        bind();

        glBufferData(type, length, data, usage);
    }

    /++
        Set the data of the buffer.
        Uses glBufferData.
        Params:
                data =      The Data to be placed in the buffer.
                usage =     See OpenGL docs on usage parameter in
                            glBufferData.
    +/
    void setData(float[] data, GLenum usage = GL_STATIC_DRAW) @system {
        bind();

        glBufferData(type, cast(size_t) (data.length * float.sizeof), data.ptr, usage);
    }

    /++
        Set the data of the buffer.
        Uses glBufferData.
        Params:
                data =      The Data to be placed in the buffer.
                usage =     See OpenGL docs on usage parameter in
                            glBufferData.
    +/
    void setData(uint[] data, GLenum usage = GL_STATIC_DRAW) @system {
        bind();

        glBufferData(type, cast(size_t) (data.length * uint.sizeof), data.ptr, usage);
    }

    /// Frees resources used by the buffer (deletes it).
    void cleanup() @system nothrow {
        glDeleteBuffers(1, &_vbo);
    }
}