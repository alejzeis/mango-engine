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
    @property GLuint vao() @trusted nothrow { return _vao; }

    private this(GLuint vao) @trusted nothrow {
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
    @property GLuint vbo() @trusted nothrow { return _vbo; }
    /// The VBO Type, ex. GL_ARRAY_BUFFER.
    @property GLenum type() @trusted nothrow { return _type; }

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