import os

template currentSourceDir(): string =
    ## Return the directory the current source file resides in.
    parentDir(currentSourcePath())

when hostOS == "windows":
    const libraryName = currentSourceDir() & "/lib/tommath.lib"
else:
    const libraryName = currentSourceDir() & "/lib/libtommath.a"

{.passC:"-I" & currentSourceDir() & "/include".}
{.passL:libraryName.}
