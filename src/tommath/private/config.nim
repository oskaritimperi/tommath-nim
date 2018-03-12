import os

template currentSourceDir(): string =
    ## Return the directory the current source file resides in.
    parentDir(currentSourcePath())

when not defined(tommathPrefix):
    const tommathPrefix* = currentSourceDir()

when not defined(tommathIncDir):
    const tommathIncDir* = tommathPrefix / "include"

when defined(vcc):
    {.passC:"/I" & tommathIncDir.}
else:
    {.passC:"-I" & tommathIncDir.}

when not defined(tommathLibDir):
    const tommathLibDir* = tommathPrefix / "lib"

when defined(vcc):
    const tommathLibPath* = tommathLibDir / "tommath.lib"
else:
    const tommathLibPath* = tommathLibDir / "libtommath.a"

{.passL:tommathLibPath.}
