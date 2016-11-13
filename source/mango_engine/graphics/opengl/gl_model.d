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
module mango_engine.graphics.opengl.gl_model;

version(mango_GLBackend) {
    import mango_engine.game;
    import mango_engine.graphics.renderer;
    import mango_engine.graphics.texture;
    import mango_engine.graphics.shader;
    import mango_engine.graphics.model;

    import mango_engine.graphics.opengl.gl_texture;
    import mango_engine.graphics.opengl.gl_shader;
    import mango_engine.graphics.opengl.gl_types;

    import derelict.opengl3.gl3;

    import gl3n.linalg;

    class GLModel : Model {

        /// Enum containing array positions for Mesh VBOs.
        static enum VBOIndexes {
            VBO_VERTICES,
            VBO_INDICES,
            VBO_TEXTURES
        }

        protected shared size_t _drawCount;

        protected shared VBO[uint] vboList;
        private shared VAO _vao;

        /// The VAO belonging to the Mesh.
        @property VAO vao() @trusted nothrow { return cast(VAO) _vao; }

        /++
            The amount of points (vertices) that will be
            rendered. This is equal to the amount of
            indices.
        +/
        @property size_t drawCount() @trusted nothrow { return cast(size_t) _drawCount; }

        /++
            The amount of points (vertices) that will be
            rendered. This is equal to the amount of
            indices.
        +/
        @property protected void drawCount(shared size_t drawCount) @safe nothrow { _drawCount = drawCount; }

        this(in string name, GameManager game, Vertex[] vertices, uint[] indices, Texture texture, ShaderProgram shader) @safe {
            super(name, game, vertices, indices, texture, shader);

            this._drawCount = indices.length;

            this.game.renderer.submitOperation(&this.setup);
        }

        private void setup() @system {
            _vao = cast(shared) VAO.generateNew();
            vao.bind();

            debug {
                import std.stdio;
                writeln(indices);
                foreach(v; (cast(Vertex[]) vertices)) {
                    writeln(v.positionToVec3());
                }
            }

            auto indicesVBO = new VBO(GL_ELEMENT_ARRAY_BUFFER);
            indicesVBO.bind();
            indicesVBO.setData(indices);
            //indicesVBO.setDataRaw(indices.ptr, cast(GLsizei) (indices.length * uint.sizeof));

            //------------------- Vertices
            auto verticesVBO = new VBO(GL_ARRAY_BUFFER);
            verticesVBO.bind();
            verticesVBO.setDataRaw(
                cast(void*) positionVerticesToFloats(cast(Vertex[]) vertices),
                cast(GLsizei) (vertices.length * vec3.sizeof) // Single vertex is a vec3
            );

            glEnableVertexAttribArray(0);
            glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, cast(void*) 0);
            //------------------- End Vertices

            vboList[VBOIndexes.VBO_VERTICES] = cast(shared) verticesVBO;
            vboList[VBOIndexes.VBO_INDICES] = cast(shared) indicesVBO;

            // Check if using Textured vertices.
            if(cast(TexturedVertex[]) vertices) {
                auto textureVBO = new VBO(GL_ARRAY_BUFFER);
                textureVBO.bind();
                textureVBO.setDataRaw(
                    cast(void*) textureVerticesToFloats(cast(Vertex[]) vertices),
                    cast(GLsizei) (vertices.length * vec2.sizeof)
                );

                glEnableVertexAttribArray(1);
                glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 0, cast(void*) 0);

                vboList[VBOIndexes.VBO_TEXTURES] = cast(shared) textureVBO;
            }

            vao.unbind();
        }

        override {
            void cleanup() @system {
                this.game.renderer.submitOperation(() {
                    vao.bind();
                    foreach(vbo; vboList.values) {
                        (cast(VBO) vbo).cleanup();
                    }
                    vao.unbind();
                    vao.cleanup();
                });
            }
        
            /// Will be called in the Renderer thread from GLRenderer
            protected void render_(Renderer renderer) @system {
                (cast(GLTexture) texture).use();
                (cast(GLShaderProgram) shader).use();

                vao.bind();
                
                glDrawElements(GL_TRIANGLES, cast(GLsizei) drawCount,
                    GL_UNSIGNED_INT,
                    cast(void*) 0
                );

                vao.unbind();
            }
        }
    }
}