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
module mango_engine.graphics.backend;

/++
    Base class for a video backend implementation.
    This class handles loading system libraries required
    by the backend, and prepares the libraries to be
    used.

    All backends must extend this class.
+/
abstract class Backend {

    /++
        Load system libraries required by the backend.
        Additional options can be passed.

        Params:
            args =  Can be any additional options passed to the
                    backend. Consult the backend documentation
                    for information on keys and values.
    +/
    abstract shared void loadLibraries(in string[string] args = null) @system;

    /// Call any initialization code required by the Backend. May be overriden.
    shared void doInit() @system {

    }

    /// Call any de-initialization code required by the Backend. May be overriden.
    shared void doDestroy() @system {

    }
}

/// LibraryLoadException is called when a system library fails to load.
class LibraryLoadException : Exception {
    /// Default constructor
    this(in string library, in string message) {
        super("Failed to laod library \"" ~ library ~ "\": " ~ message);
    }
}

/// BackendException is called when there is a failure in the backend.
class BackendException : Exception {
    /// Default constructor
    this(in string message) {
        super(message);
    }
}