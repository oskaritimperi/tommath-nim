import os
import osproc
import sequtils
import strformat
import strutils

type
    Compiler* {.pure.} = enum
        Gcc
        Vcc
        Clang

    CompilerInfo* = tuple[
        name: string,
        compilerC: string,
        compilerCxx: string,
        compileTmpl: string,
        linkStaticTmpl: string,
        includeTmpl: string,
        defineTmpl: string,
    ]

    PublicHeader = ref object
        destination: string
        source: string

    StaticLibrary* = ref object of RootObj
        name*: string
        sources*: seq[string]
        defines*: seq[string]
        compilerOptions*: seq[string]
        includeDirectories*: seq[string]
        buildDirectory*: string
        publicHeaders*: seq[PublicHeader]

template compiler(name, settings: untyped): untyped =
    proc name: CompilerInfo {.compileTime.} = settings

compiler(gcc):
    result = (
        name: "gcc",
        compilerC: "gcc",
        compilerCxx: "g++",
        compileTmpl: "$compiler -c $options $includes -o $obj $source",
        linkStaticTmpl: "ar rcs $library $obj",
        includeTmpl: " -I$path",
        defineTmpl: " -D$define"
    )

compiler(vcc):
    result = (
        name: "vcc",
        compilerC: "cl",
        compilerCxx: "cl",
        compileTmpl: "$compiler /c $options $includes /Fo$obj $source",
        linkStaticTmpl: "lib /OUT:$library $obj",
        includeTmpl: " /I$path",
        defineTmpl: " /D$define"
    )

compiler(clang):
    result = gcc()
    result.name = "clang"
    result.compilerC = "clang"
    result.compilerCxx = "clang++"

const
    Compilers* = [
        gcc(),
        vcc(),
        clang(),
    ]

proc getCompiler*(): CompilerInfo {.compileTime.} =
    ## Return the compiler info.
    when hostOS == "windows":
        result = Compilers[Compiler.Vcc.int]
    elif hostOS == "macosx":
        result = Compilers[Compiler.Clang.int]
    else:
        result = Compilers[Compiler.Gcc.int]

proc newStaticLibrary*(name: string,
                       sourceDir: string): StaticLibrary =
    ## Initialize a new static library.
    ##
    ## Args:
    ##      name: The logical name of the library. The platform specific
    ##          filename is built from this name.
    ##      sourceDir: The source directory of the library. Relative filenames
    ##          are resolved relating to this directory.
    new(result)
    result.name = name
    result.sources = @[]
    result.defines = @[]
    result.compilerOptions = @[]
    result.includeDirectories = @[]
    result.buildDirectory = getTempDir() / &"build-{name}"
    result.publicHeaders = @[]

proc addIncludeDirectory*(library: StaticLibrary, dir: string) =
    ## Add an include directory for the library.
    add(library.includeDirectories, dir)

proc addSourceFiles*(library: StaticLibrary, sources: varargs[string]) =
    for source in sources:
        var source = source
        if not isAbsolute(source):
            source = expandFilename(source)
        add(library.sources, source)

proc addSourceFilesWithPattern*(library: StaticLibrary, pattern: string) =
    for file in walkFiles(pattern):
        addSourceFiles(library, file)

proc addPublicHeaders*(library: StaticLibrary, destination: string,
    headers: varargs[string]) =
    for header in headers:
        add(library.publicHeaders, PublicHeader(destination: destination,
            source: header))

proc prefix(library: StaticLibrary): string =
    ## Return the static library prefix.
    when defined(windows):
        result = ""
    else:
        result = "lib"

proc suffix(library: StaticLibrary): string =
    ## Return the static library suffix (extension).
    when defined(windows):
        result = ".lib"
    else:
        result = ".a"

proc fullName(library: StaticLibrary): string =
    ## Return the full name of a static library.
    result = &"{library.prefix}{library.name}{library.suffix}"

proc fullPath(library: StaticLibrary): string =
    ## Return the full path of a static library
    result = library.buildDirectory / fullName(library)

proc relativePath(path, start: string): string =
    ## Return the relative version of path.
    ##
    ## The returned path is relative to start. The procedure is translated into
    ## Nim from Python's relpath() from posixpath.py.
    let separators = { DirSep, AltSep }

    var startList: seq[string] = @[]
    for part in split(expandFilename(start), separators):
        add(startList, part)

    var pathList: seq[string] = @[]
    for part in split(expandFilename(path), separators):
        add(pathList, part)

    let minLen = min(len(startList), len(pathList))

    var commonLen = 0

    for value in zip(startList, pathList):
        if value.a == value.b:
            inc(commonLen)
        else:
            break

    let relList = cycle([ParDir], len(startList) - commonLen) & pathList[commonLen..^1]

    if len(relList) == 0:
        return $CurDir

    result = joinPath(relList)

proc objectFilename(library: StaticLibrary, source: string): string =
    ## Return the absolute object file path of a source file.
    var source = relativePath(source, getAppDir())
    source = changeFileExt(source, "obj")
    source = replace(source, "..", "__")
    result = library.buildDirectory / source

proc createParentDir(filename: string) =
    ## Create the parent directory of a file.
    let parent = parentDir(filename)
    createDir(parent)

proc echoAndExec(command: string): int =
    echo(command)
    result = execCmd(command)

proc compile(library: StaticLibrary): bool =
    ## Compile the sources of a static library.
    var includes = ""
    for path in library.includeDirectories:
        includes &= getCompiler().includeTmpl % ["path", path]

    var defines = ""
    for define in library.defines:
        defines &= getCompiler().defineTmpl % ["define", define]

    for source in library.sources:
        let obj = objectFilename(library, source)

        createParentDir(obj)

        let (_, _, ext) = splitFile(source)

        let compilerExe =
            if ext == ".c":
                getCompiler().compilerC
            else:
                getCompiler().compilerCxx

        let tmpl = getCompiler().compileTmpl

        let command = tmpl % [
            "compiler", compilerExe,
            "options", defines,
            "includes", includes,
            "obj", obj,
            "source", source
        ]

        if echoAndExec(command) != 0:
            return false

    result = true

proc link(library: StaticLibrary): bool =
    ## Link the static library.
    let outputPath = fullPath(library)

    for source in library.sources:
        let obj = objectFilename(library, source)

        let command =  getCompiler().linkStaticTmpl % [
            "library", outputPath,
            "obj", obj
        ]

        if echoAndExec(command) != 0:
            return false

    result = true

proc build*(library: StaticLibrary): bool =
    result = false
    if compile(library):
        result = link(library)

proc install*(library: StaticLibrary, destdir: string) =
    createDir(destdir / "lib")
    copyFile(fullPath(library), destdir / "lib" / fullName(library))

    for header in library.publicHeaders:
        let filename = extractFilename(header.source)
        createDir(destdir / header.destination)
        copyFile(header.source, destdir / header.destination / filename)
