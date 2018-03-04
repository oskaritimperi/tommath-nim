# Package

version       = "0.1.0"
author        = "Oskari Timperi"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"

# Dependencies

requires "nim >= 0.18.0"

before install:
    exec "git clone --branch v1.0.1 https://github.com/libtom/libtommath.git"
