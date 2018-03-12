# Package

version       = "0.1.0"
author        = "Oskari Timperi"
description   = "libtommath for Nim"
license       = "MIT"
srcDir        = "src"

# Dependencies

requires "nim >= 0.18.0"

before install:
    if not existsEnv("TOMMATH_NO_CLONE"):
        exec "git clone --branch v1.0.1 --depth 1 https://github.com/libtom/libtommath.git /tmp/source-libtommath"

    exec "nim c -r tools/libtommath.nim"
