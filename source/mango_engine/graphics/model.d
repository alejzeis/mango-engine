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
    private uint[] indices;

    this(Vertex[] vertices, uint[] indices) {
        this.vertices = vertices;
        this.indices = indices;
    }
}