import os

template currentSourceDir(): string =
    ## Return the directory the current source file resides in.
    parentDir(currentSourcePath())

when not defined(tommathPrefix):
    const tommathPrefix = currentSourceDir()

when not defined(tommathIncPath):
    const tommathIncPath = tommathPrefix / "include"

when defined(vcc):
    {.passC:"/I" & tommathIncPath.}
else:
    {.passC:"-I" & tommathIncPath.}

when not defined(tommathLibPath):
    const tommathLibPath = tommathPrefix / "lib"

when defined(vcc):
    const libraryPath = tommathLibPath / "tommath.lib"
else:
    const libraryPath = tommathLibPath / "libtommath.a"

{.passL:libraryPath.}
