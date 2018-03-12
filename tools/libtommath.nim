import os

import builder

let sourceDir = expandFilename("/tmp/source-libtommath")

let libtommath = newStaticLibrary("tommath", sourceDir)

addSourceFilesWithPattern(libtommath, sourceDir / "*.c")

addIncludeDirectory(libtommath, sourceDir)

addPublicHeaders(libtommath, "include",
    sourceDir / "tommath.h",
    sourceDir / "tommath_class.h",
    sourceDir / "tommath_superclass.h")

if build(libtommath):
    install(libtommath, getAppDir() / ".." / "src" / "tommath" / "private")
