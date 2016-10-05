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
module mango_engine.graphics.backend;

template GenFactory(string object_, string params) {
    const char[] GenFactory = "
    version(mango_GLBackend) {
        if(backend == GraphicsBackendType.API_OPENGL)
            return new GL" ~ object_ ~ "(" ~ params ~ ");
    }
    /*
    version(mango_VKBackend) {
        if(backend == GraphicsBackendType.API_VULKAN)
            return new VK" ~ object_ ~ "(" ~ params ~ ");
    }
    */
    throw new Exception(\"No backends avaliable, was it compiled in?\");
    ";
}

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