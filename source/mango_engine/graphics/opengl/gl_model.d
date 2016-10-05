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
module mango_engine.graphics.opengl.gl_model;

import mango_engine.graphics.model;
import mango_engine.graphics.opengl.gl_types;

import derelict.opengl3.gl3;

class GLModel : Model {
    /// Enum containing array positions for Mesh VBOs.
    static enum VBOIndexes {
        VBO_VERTICES,
        VBO_INDICES,
        VBO_TEXTURES
    }

    protected size_t _drawCount;

    protected VBO[uint] vboList;
    private VAO _vao;

    /// The VAO belonging to the Mesh.
    @property VAO vao() @safe nothrow { return _vao; }

    /++
        The amount of points (vertices) that will be
        rendered. This is equal to the amount of
        indices.
    +/
    @property size_t drawCount() @safe nothrow { return _drawCount; }

    /++
        The amount of points (vertices) that will be
        rendered. This is equal to the amount of
        indices.
    +/
    @property protected void drawCount(size_t drawCount) @safe nothrow { _drawCount = drawCount; }

    this(Vertex[] vertices, uint[] indices /*, Texture texture, ShaderProgram shader*/) {
        super(vertices, indices);
        this._drawCount = indices.length;
    }

    private void setup() @system {
        _vao = VAO.generateNew();
        vao.bind();

        auto indicesVBO = new VBO(GL_ELEMENT_ARRAY_BUFFER);
        indicesVBO.bind();
        indicesVBO.setData(indices);
        //indicesVBO.setDataRaw(indices.ptr, cast(GLsizei) (indices.length * uint.sizeof));

        //------------------- Vertices
        auto verticesVBO = new VBO(GL_ARRAY_BUFFER);
        verticesVBO.bind();
        verticesVBO.setDataRaw(
            cast(void*) positionVerticesToFloats(vertices),
            cast(GLsizei) (vertices.length * vec3.sizeof) // Single vertex is a vec3
        );

        glEnableVertexAttribArray(0);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, cast(void*) 0);
        //------------------- End Vertices

        vboList[VBOIndexes.VBO_VERTICES] = verticesVBO;
        vboList[VBOIndexes.VBO_INDICES] = indicesVBO;

        // Check if using Textured vertices.
        if(cast(TexturedVertex[]) vertices) {
            auto textureVBO = new VBO(GL_ARRAY_BUFFER);
            textureVBO.bind();
            textureVBO.setDataRaw(
                cast(void*) textureVerticesToFloats(vertices),
                cast(GLsizei) (vertices.length * vec2.sizeof)
            );

            glEnableVertexAttribArray(1);
            glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 0, cast(void*) 0);

            vboList[VBOIndexes.VBO_TEXTURES] = textureVBO;
        }

        vao.unbind();
    }

    /// Cleanup resources used by the Model.
    void cleanup() @trusted {
        vao.bind();
        foreach(vbo; vboList.values) {
            vbo.cleanup();
        }
        vao.unbind();
        vao.cleanup();

        //texture.cleanup();
        //shader.cleanup();
    }
}