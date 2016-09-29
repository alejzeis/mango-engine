"""
    zlib License
    (C) 2016 jython234
    This software is provided 'as-is', without any express or implied
    warranty.  In no event will the authors be held liable for any damages
    arising from the use of this software.
    Permission is granted to anyone to use this software for any purpose,
    including commercial applications, and to alter it and redistribute it
    freely, subject to the following restrictions:
    1. The origin of this software must not be misrepresented; you must not
    claim that you wrote the original software. If you use this software
    in a product, an acknowledgment in the product documentation would be
    appreciated but is not required.
    2. Altered source versions must be plainly marked as such, and must not be
    misrepresented as being the original software.
    3. This notice may not be removed or altered from any source distribution.
"""
#----------------------------------------------------------
# License Header script to update headers in source code.
# Author: jython234
# _____________________________NOTICE!_____________________________
# ORIGINAL LOCATION: https://gist.github.com/jython234/547d5c96f225160484706356dc593fe2
# THIS COPY HAS NOT BEEN MODIFIED FROM THE ORIGINAL OTHER THAN THIS NOTICE
# _____________________________NOTICE!_____________________________
#----------------------------------------------------------

import os, sys

licenseFile = open(input("Enter the License filename: "), 'r')
licenseLines = licenseFile.readlines()
licenseFile.close()

def formatFile(filename: str):
    f = open(filename, 'r')
    lines = f.readlines()
    f.close()
    if lines[0].startswith("/*"):
        print("\\ File " + filename + " already has header.")
        return

    f = open(filename, 'w')

    f.write("/*\n")
    for line in licenseLines:
        f.write(" *  " + line)
    f.write("*/\n")

    for line2 in lines:
        f.write(line2)
    
    f.close()

def formatDirectory(directory: str):
    print("| Formatting Directory: " + directory)
    files = os.listdir(directory)

    oldDir = os.getcwd()
    os.chdir(directory)
    print("* Changed to " + os.getcwd())

    for f in files:
        if os.path.isdir(f):
            formatDirectory(f)
        elif ".d" in f:
            print("/ Formatting file: " + f)
            formatFile(f)
            
    os.chdir(oldDir)

print("License Headers script by jython234.\nThis Software is released under the Zlib license:")
print("""
    zlib License
    (C) 2016 jython234
    This software is provided 'as-is', without any express or implied
    warranty.  In no event will the authors be held liable for any damages
    arising from the use of this software.
    Permission is granted to anyone to use this software for any purpose,
    including commercial applications, and to alter it and redistribute it
    freely, subject to the following restrictions:
    1. The origin of this software must not be misrepresented; you must not
    claim that you wrote the original software. If you use this software
    in a product, an acknowledgment in the product documentation would be
    appreciated but is not required.
    2. Altered source versions must be plainly marked as such, and must not be
    misrepresented as being the original software.
    3. This notice may not be removed or altered from any source distribution.
""")
print("NOTICE! This script formats using C style comments! (/* */)")
directory = input("Enter a directory to format: ")

if os.path.exists(directory) and os.path.isdir(directory):
    formatDirectory(directory)
    sys.exit(0)
else:
    print("Directory does not exist!")
    sys.exit(1)
