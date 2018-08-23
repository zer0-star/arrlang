import lexer, common, tree, nodeedit, abstract, autoinclude

proc asmProgram*(node: NODE; s: SOURCE): string
proc asmF_dec(node: NODE; s: SOURCE): string
proc asmPrototype(node: NODE; s: SOURCE): string
proc asmV_dec(node: NODE; s: SOURCE): string
proc asmFunction(node: NODE; s: SOURCE): string
proc asmSentence(node: NODE; s: SOURCE): string
proc asmIf_flow(node: NODE; s: SOURCE): string
proc asmWhile_flow(node: NODE; s: SOURCE): string
proc asmReturn(node: NODE; s: SOURCE): string
proc asmAssign(node: NODE; s: SOURCE): string
proc asmCall(node: NODE; s: SOURCE): string
proc asmExpression_list(node: NODE; s: SOURCE): string
#proc asmType_list(node: NODE; s: SOURCE): string
#proc asmVariable_list(node: NODE; s: SOURCE): string
proc asmExpression(node: NODE; s: SOURCE): string


proc asmProgram*(node: NODE; s: SOURCE): string =
  var down = node.down
  result = ""
  while down != nil:
    case down.kind
    of F_DEC: result &= asmF_dec(down, s)
    of V_DEC: result &= asmV_dec(down, s) & ";\n"
    of PROTOTYPE: result &= asmPrototype(down, s) & ";\n"
    else: discard
    down = down.right
proc asmF_dec(node: NODE; s: SOURCE): string =
  var
    argtyp = node.down
    typ = argtyp.right
    variable = typ.right
    fun: NODE
  result = s.token[typ.init].str & " " & s.token[variable.init].str & "("
  if variable.right.kind != FUNCTION:
    if argtyp.kind == TYPE_LIST:
      var
        arg = variable.right
        downtyp = argtyp.down
        downarg = arg.down
      fun = arg.right
      assert downtyp.countHorizontal == downarg.countHorizontal
      result &= s.token[downtyp.init].str & " " & s.token[downarg.init].str
      while downtyp.right != nil and downarg.right != nil:
        downtyp = downtyp.right
        downarg = downarg.right
        result &= "," & s.token[downtyp.init].str & " " & s.token[downarg.init].str
      result &= ")"
    elif argtyp.kind == TYPE:
      var arg = variable.right
      fun = arg.right
      assert arg.kind == VARIABLE
      result &= s.token[argtyp.init].str & " " & s.token[arg.init].str & ")"
  else: 
    fun = variable.right
    result &= s.token[argtyp.init].str & ")"
  result &= asmFunction(fun, s)
proc asmPrototype(node: NODE; s: SOURCE): string =
  var
    argtyp = node.down
    typ = argtyp.right
    variable = typ.right
  result = s.token[typ.init].str & " " & s.token[variable.init].str & "("
  if argtyp.kind == TYPE_LIST:
    var down = argtyp.down
    result &= s.token[down.init].str
    while down.right != nil:
      down = down.right
      result &= "," & s.token[down.init].str
    result &= ")"
  elif argtyp.kind == TYPE:
    result &= s.token[argtyp.init].str & ")"
proc asmV_dec(node: NODE; s: SOURCE): string =
  var
    typ = node.down
    variable = typ.right
  result = s.token[typ.init].str & " " & s.token[variable.init].str
  if variable.right != nil:
    result &= "=" & asmExpression(variable.right, s)
proc asmFunction(node: NODE; s: SOURCE): string =
  var down = node.down
  assert down != nil
  result = "{\n"
  while down.kind == V_DEC:
    result &= asmV_dec(down, s) & ";\n"
    down = down.right
  result &= asmSentence(down, s) & "}\n"
proc asmSentence(node: NODE; s: SOURCE): string =
  var down = node.down
  result = ""
  while down != nil:
    case down.kind
    of IF_FLOW: result &= asmIf_flow(down, s)
    of WHILE_FLOW: result &= asmWhile_flow(down, s)
    of RETURN: result &= asmReturn(down, s)
    of ASSIGN: result &= asmAssign(down, s)
    of CALL: result &= asmCall(down, s) & ";\n"
    else: discard
    down = down.right
proc asmIf_flow(node: NODE; s: SOURCE): string =
  var
    expr = node.down
    sentence = expr.right
  assert sentence != nil
  result = "if("
  result &= asmExpression(expr, s) & "){\n"
  result &= asmSentence(sentence, s) & "}"
  if sentence.right != nil:
    while sentence.right != nil and sentence.right.kind == EXPRESSION:
      expr = sentence.right
      sentence = expr.right
      assert sentence != nil
      result &= "else if("
      result &= asmExpression(expr, s) & "){\n"
      result &= asmSentence(sentence, s) & "}"
    if sentence.right != nil:
      result &= "else{\n"
      result &= asmSentence(sentence.right, s) & "}"
  result &= "\n"
proc asmWhile_flow(node: NODE; s: SOURCE): string =
  var
    expr = node.down
    sentence = expr.right
  assert sentence != nil
  result = "while("
  result &= asmExpression(expr, s) & "){\n"
  result &= asmSentence(sentence, s) & "}\n"
proc asmReturn(node: NODE; s: SOURCE): string =
  var expr = node.down
  result = "return " & asmExpression(expr, s) & ";\n"
proc asmAssign(node: NODE; s: SOURCE): string =
  var
    variable = node.down
    expr = variable.right
  assert expr != nil
  result = s.token[variable.init].str & "=" & asmExpression(expr, s) & ";\n"
proc asmCall(node: NODE; s: SOURCE): string =
  var arg, fun: NODE
  if node.down.kind == VARIABLE:
    fun = node.down
  else:
    arg = node.down
    fun = arg.right
  result = ""
  if fun != nil:
    if fun.kind == B_OPERATOR:
      assert arg.kind == EXPRESSION_LIST
      var expr = arg.down
      let operator = s.token[fun.init].str
      result &= "(" & asmExpression(expr, s)
      while expr.right != nil:
        expr = expr.right
        result &= operator & asmExpression(expr, s)
      result &= ")"
    else:
      autoInclude(s.token[fun.init].str)
      result &= s.token[fun.init].str
      result &= "(" & (if arg.kind == EXPRESSION: asmExpression(arg, s) elif arg.kind == EXPRESSION_LIST: asmExpression_list(arg, s) else: "") & ")"
proc asmExpression_list(node: NODE; s: SOURCE): string =
  var expr = node.down
  assert expr != nil
  result = asmExpression(expr, s)
  while expr.right != nil:
    expr = expr.right
    result &= "," & asmExpression(expr, s)
#proc asmType_list(node: NODE; s: SOURCE): string
#proc asmVariable_list(node: NODE; s: SOURCE): string
proc asmExpression(node: NODE; s: SOURCE): string =
  var down = node.down
  if   down.kind == LITERAL or down.kind == VARIABLE: result = s.token[down.init].str
  elif down.kind == CALL: result = asmCall(down, s)

when isMainModule:
  let
    filename = "test.arr"
  var
    fp = openr(filename)
    token = fp.getTokens
    init = 0
    last = token.len - 1
    node: seq[NODE] = @[]
  node.add makeRootNode(token.len-1)
  node[0].down = makeDownTree(init, last, node[0], nil, token, node)
  var src = SOURCE(program: node[0], node: node, token: token)
  src.eliminateInsignificant
  echo src.program.repr
