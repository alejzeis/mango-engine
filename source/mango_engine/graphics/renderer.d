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