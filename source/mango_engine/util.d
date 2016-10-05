module mango_engine.util;

/++
    Reads a whole file into a string.

    Params:
            filename =  The file to be read.

    Returns: The file's contents.
    Throws: Exception if the file does not exist.
+/
string readFileToString(in string filename) @safe {
    import std.file : exists, readText;
    if(exists(filename)) {
        auto text = readText(filename);
        return text;
    } else throw new Exception("File does not exist!"); 
}