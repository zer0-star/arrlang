import math, strutils, sequtils, algorithm, common, lexer, os, tree, nodeedit, abstract, asm2code


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
  while i < os.paramCount():
    case params[i]
    of "-o":
      i.inc
      output = params[i]
    of "-h":
      discard
    of "--include":
      discard
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
  code = "#include <stdio.h>\n" & code
  tmpfp.write(code)
  close(tmpfp)
  let cmd = "cc " & tmpname & " -o " & output
  discard execShellCmd(cmd)
