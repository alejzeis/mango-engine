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
module mango_engine.logging;

abstract class Logger {
    /// The name of the logger.
    immutable string name;

    this(in string name) @safe nothrow {
        this.name = name;
    }

    void logDebug(in string message) @safe {
        debug {
            logDebug_(message);
        }
    }

    abstract void logDebug_(in string message) @safe;

    abstract void logInfo(in string message) @safe;

    abstract void logWarn(in string message) @safe;

    abstract void logError(in string message) @safe;

    abstract void logException(Exception e) @safe;
}

class ConsoleLogger : Logger {
    import std.stdio : write, writeln;
    import std.file;

    import consoled;

    import core.thread : Thread;

    this(in string name) @safe nothrow {
        super(name);
    }

    override {
        void logDebug_(in string message) @trusted {
            synchronized(this) {
                writecln(FontStyle.bold, Fg.cyan, "[", name, Fg.magenta, "|", Thread.getThis().name, "|", Fg.cyan, "/", Fg.lightBlue, "DEBUG", Fg.cyan, "]: ", FontStyle.none, Fg.white, message);

                resetColors();
                resetFontStyle();
            }
        }

        void logInfo(in string message) @trusted {
            synchronized(this) {
                writecln(FontStyle.bold, Fg.cyan, "[", name, "/", Fg.lightGreen, "INFO", Fg.cyan, "]: ", FontStyle.none, Fg.white, message);

                resetColors();
                resetFontStyle();
            }
        }

        void logWarn(in string message) @trusted {
            synchronized(this) {
                writecln(FontStyle.bold, Fg.cyan, "[", name, "/", Fg.lightYellow, "WARN", Fg.cyan, "]: ", FontStyle.none, Fg.white, message);

                resetColors();
                resetFontStyle();
            }
        }

        void logError(in string message) @trusted {
            synchronized(this) {
                writecln(FontStyle.bold, Fg.cyan, "[", name, Fg.magenta, "|", Thread.getThis().name, "|", Fg.cyan, "/", Fg.lightRed, "ERROR", Fg.cyan, "]: ", Fg.white, message);

                resetColors();
                resetFontStyle();
            }
        }

        void logException(Exception e) @trusted {
            debug {
                logError(e.toString());
            }
            std.file.write("exceptionReport-" ~ e.classinfo.name ~ ".txt", "Exception Dump:\n\n" ~ e.toString());
        }
    }
}