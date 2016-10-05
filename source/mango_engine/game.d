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
module mango_engine.game;

import mango_engine.graphics.model;
import mango_engine.graphics.renderer;
import mango_engine.graphics.scene;
import mango_engine.graphics.window;

/++
    The main core of any Game application.
    Handles all sub- (Manager) classes.
+/
class GameManager {
    private shared Window _window;
    private shared Scene _currentScene;
    private shared Renderer _renderer;

    // Scenes that are currently loaded in memory, but are not being rendered
    private shared Scene[] loadedScenes; 

    alias scene = currentScene;

    /// The Window the Game is rendering to.
    @property Window window() @safe nothrow { return _window; }
    /// The Scene that is currently being displayed.
    @property Scene currentScene() @safe nothrow { return _currentScene; }
    /// The Renderer that renders the current Scene
    @property Renderer renderer() @safe nothrow { return _renderer; }
}