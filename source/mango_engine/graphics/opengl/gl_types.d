/*
 *  Copyright 2016 Mango-Engine Team
 *  
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *  
 *  	http://www.apache.org/licenses/LICENSE-2.0
 *  
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
*/
module mango_engine.graphics.opengl.gl_types;

import mango_engine.graphics.model : Vertex;

import derelict.opengl3.gl3;

import gl3n.linalg;

/++
    Struct that represents a Vertex with
    a position vector(vec3), and a texture
    vector (vec2).
+/
class GLTexturedVertex : Vertex {
    /// Vector containing the texture coordinates.
    vec2 texture;

    this(vec3 position, vec2 texture) @safe nothrow {
        super(position);
        this.texture = texture;
    }
}

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
    if(!(cast(GLTexturedVertex[]) vertices)) {
        import mango_engine.exception : InvalidArgumentException;
        throw new InvalidArgumentException("Vertices not type of TexturedVertex!");
    }
    foreach(vertex; (cast(GLTexturedVertex[]) vertices)) {
        data ~= vertex.texture.x;
        data ~= vertex.texture.y;
    }
    return data;
}

/// Represents an OpenGL VAO.
struct VAO {
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
    static VAO generateNew() @trusted nothrow {
        GLuint id;
        glGenVertexArrays(1, &id);

        return VAO(id);
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
struct VBO {
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
    this(GLenum type) @trusted nothrow {
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