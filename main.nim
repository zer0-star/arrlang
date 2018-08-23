import math, strutils, sequtils, algorithm, common, lexer, os, tree, nodeedit, abstract, asm2code, autoinclude

const USAGE = """
Usage: arrlang [OPTIONS] sourcefile

arrlang is the best language powered by "ARROW".

  -o                      set the output file
  -h                      show this message and exit
  -i/--include/--import   set the include/import files
  -r/--run                run after compiling
"""

if os.paramCount() == 0:
  echo "filename wasn't found"
  system.programResult = 1
else:
  let
    params = os.commandLineParams()
  var
    i = 0
    filename = ""
    output = ""
    runflag = false
    userIncludes: seq[string] = @[]
  while i < os.paramCount():
    case params[i]
    of "-o", "--output":
      i.inc
      output = params[i]
    of "-h", "--help":
      echo USAGE
      quit(QuitSuccess)
    of "-i", "--import", "--include":
      i.inc
      userIncludes.add(params[i].split(','))
    of "-r", "--run":
      runflag = true
    else:
      filename = params[i]
    i.inc
  var 
    tmppath = filename.splitPath
  createDir(tmppath.head & (if tmppath.head == "": "" else: "/") & "arrowcache")
  var
    fp = openr(filename)
    tmpname = tmppath.head & (if tmppath.head == "": "" else: "/") & "arrowcache/" & tmppath.tail & ".c"
    tmpfp = open(tmpname, FileMode.fmWrite)
    token = fp.getTokens
    init = 0
    last = token.len - 1
    node: seq[NODE] = @[]
  node.add makeRootNode(token.len-1)
  node[0].down = makeDownTree(init, last, node[0], nil, token, node)
  var src = SOURCE(program: node[0], node: node, token: token)
  src.eliminateInsignificant
  var code = src.program.asmProgram(src)
  for incstr in userIncludes:
    code = ("#include \"$#\"" % incstr) & code
  for incstr in includes:
    code = ("#include <$#>\n" % incstr) & code
  tmpfp.write(code)
  close(tmpfp)
  let
    cmd = "cc " & tmpname & " -o " & output
    res = execShellCmd(cmd)
  if res != 0: quit(res)
  if runflag: quit(execShellCmd("./" & output))
