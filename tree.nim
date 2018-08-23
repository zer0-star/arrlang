import common, lexer, sequtils, strutils

proc makeRootNode*(maxNodeNum: int): NODE = NODE(kind: PROGRAM, init: 0, last: maxNodeNum, up: nil, down: nil, left: nil, right: nil)



proc searchNextCorresponding(nt, last: int; token: seq[TOKEN]; left, right: TOKEN_KIND): int 
proc searchNextRparen(nt, last: int; token: seq[TOKEN]): int 
proc searchNextRbracket(nt, last: int; token: seq[TOKEN]): int 
proc searchNextRbrace(nt, last: int; token: seq[TOKEN]): int 

proc countRMinusL(nt, last: int; token: seq[TOKEN]; left, right: TOKEN_KIND): int
proc countRMinusLparen(nt, last: int; token: seq[TOKEN]): int 
proc countRMinusLbracket(nt, last: int; token: seq[TOKEN]): int 
proc countRMinusLbrace(nt, last: int; token: seq[TOKEN]): int 


proc printTokenError(nt, init, last: int; token: seq[TOKEN])
proc printTokenErrorArray(nt, init, last: int; token: seq[TOKEN]; kindArray: seq[TOKEN_KIND]; arrayNum: int)
proc syntaxCheck(nt, init, last: int; token: seq[TOKEN]; shouldBe: TOKEN_KIND)

proc findProgram(init, last: var int; token: seq[TOKEN]): SYNTAX_KIND
proc findF_dec(init, last: var int; token: seq[TOKEN]): SYNTAX_KIND
proc findPrototype(init, last: var int; token: seq[TOKEN]): SYNTAX_KIND
proc findV_dec(init, last: var int; token: seq[TOKEN]): SYNTAX_KIND
proc findFunction(init, last: var int; token: seq[TOKEN]): SYNTAX_KIND
proc findSentence(init, last: var int; token: seq[TOKEN]): SYNTAX_KIND
proc findIf_flow(init, last: var int; token: seq[TOKEN]): SYNTAX_KIND
proc findWhile_flow(init, last: var int; token: seq[TOKEN]): SYNTAX_KIND
proc findReturn(init, last: var int; token: seq[TOKEN]): SYNTAX_KIND
proc findAssign(init, last: var int; token: seq[TOKEN]): SYNTAX_KIND
proc findCall(init, last: var int; token: seq[TOKEN]): SYNTAX_KIND
proc findExpression_list(init, last: var int; token: seq[TOKEN]): SYNTAX_KIND
proc findType_list(init, last: var int; token: seq[TOKEN]): SYNTAX_KIND
proc findVariable_list(init, last: var int; token: seq[TOKEN]): SYNTAX_KIND
proc findExpression(init, last: var int; token: seq[TOKEN]): SYNTAX_KIND

proc makeDownTree*(init, last: int; up, left: NODE; token: seq[TOKEN]; node: var seq[NODE]): NODE =
  var
    findInit = init
    findLast = last
    findKind = OTHER_NODE
  result = nil
  if init <= last:
    if false: discard
    elif up.kind == PROGRAM: findKind = findProgram(findInit, findLast, token)
    elif up.kind == F_DEC: findKind = findF_dec(findInit, findLast, token)
    elif up.kind == PROTOTYPE: findKind = findPrototype(findInit, findLast, token)
    elif up.kind == V_DEC: findKind = findV_dec(findInit, findLast, token)
    elif up.kind == FUNCTION: findKind = findFunction(findInit, findLast, token)
    elif up.kind == SENTENCE: findKind = findSentence(findInit, findLast, token)
    elif up.kind == IF_FLOW: findKind = findIf_flow(findInit, findLast, token)
    elif up.kind == WHILE_FLOW: findKind = findWhile_flow(findInit, findLast, token)
    elif up.kind == RETURN: findKind = findReturn(findInit, findLast, token)
    elif up.kind == ASSIGN: findKind = findAssign(findInit, findLast, token)
    elif up.kind == CALL: findKind = findCall(findInit, findLast, token)
    elif up.kind == EXPRESSION_LIST: findKind = findExpression_list(findInit, findLast, token)
    elif up.kind == TYPE_LIST: findKind = findType_list(findInit, findLast, token)
    elif up.kind == VARIABLE_LIST: findKind = findVariable_list(findInit, findLast, token)
    elif up.kind == EXPRESSION: findKind = findExpression(findInit, findLast, token)
  if findKind != OTHER_NODE:
    result = NODE(init: findInit, last: findLast, kind: findKind, up: up, left: left, down: nil, right: nil)
    node.add(result)
    result.down = makeDownTree(findInit, findLast, result, nil, token, node)
    result.right = makeDownTree(findLast+1, last, up, result, token, node)


proc printTokenErrorArray(nt, init, last: int; token: seq[TOKEN]; kindArray: seq[TOKEN_KIND]; arrayNum: int) =
  printTokenError(nt, init, last, token)
  stderr.write(" ---> ")
  for i in 0..<arrayNum: stderr.write(kindArray[i], ", ")
  stderr.write("\n")

proc printTokenError(nt, init, last: int; token: seq[TOKEN]) =
  stderr.write("\nSyntax Error")
  for i in init..<last:
    if i == nt: stderr.write(" ```", token[i].str, "'''")
    else: stderr.write(token[i].str)
  stderr.write(" ")

proc inc(nt: var int; last: int; ifInside: var bool) =
  if ifInside:
    if nt < last: nt.inc
    else: ifInside = false

proc searchNextRparen(nt, last: int; token: seq[TOKEN]): int =
  searchNextCorresponding(nt, last, token, LPAREN, RPAREN)
proc searchNextRbracket(nt, last: int; token: seq[TOKEN]): int =
  searchNextCorresponding(nt, last, token, LBRACKET, RBRACKET)
proc searchNextRbrace(nt, last: int; token: seq[TOKEN]): int =
  searchNextCorresponding(nt, last, token, LBRACE, RBRACE)

proc countRMinusLparen(nt, last: int; token: seq[TOKEN]): int =
  countRMinusL(nt, last, token, LPAREN, RPAREN)
proc countRMinusLbracket(nt, last: int; token: seq[TOKEN]): int =
  countRMinusL(nt, last, token, LBRACKET, RBRACKET)
proc countRMinusLbrace(nt, last: int; token: seq[TOKEN]): int =
  countRMinusL(nt, last, token, LBRACE, RBRACE)

proc countRMinusL(nt, last: int; token: seq[TOKEN]; left, right: TOKEN_KIND): int =
  var leftNum, rightNum = 0
  for i in nt..last:
    let kind = token[i].kind
    if kind == left: leftNum.inc
    elif kind == right: rightNum.inc
  return rightNum - leftNum

proc searchNextCorresponding(nt, last: int; token: seq[TOKEN]; left, right: TOKEN_KIND): int =
  var
    leftNum, rightNum = 0
    ifFind = false
  result = nt
  while result <= last:
    let kind = token[result].kind
    if kind == left: leftNum.inc
    elif kind == right: rightNum.inc

    if leftNum <= rightNum:
      ifFind = true
      break
    result.inc
  if not ifFind:
    stderr.writeLine("Corresponding ", right, " Not Found")
    result = -1

proc syntaxCheck(nt, init, last: int; token: seq[TOKEN]; shouldBe: TOKEN_KIND) =
  if token[nt].kind != shouldBe:
    printTokenError(nt, init, last, token)
    stderr.write(" ---> ", shouldBe, "\n")

proc findProgram(init, last: var int; token: seq[TOKEN]): SYNTAX_KIND =
  let
    argInit = init
    argLast = last
  var nt = init
  result = OTHER_NODE
  if token[nt].kind == SEMICOLON:
    last = nt
    result = SKIP_NODE
  elif token[nt].kind == VAR_KEYWORD:
    nt.inc
    nt = searchNextRbracket(nt, argLast, token)
    assert nt > 0
    while token[nt+1].kind != SEMICOLON:
      nt.inc
    last = nt
    result = V_DEC
  elif token[nt].kind == FUNC_KEYWORD:
    nt.inc
    nt = searchNextRbracket(nt, argLast, token)
    assert nt > 0
    if token[nt+1].kind == SEMICOLON:
      last = nt
      result = PROTOTYPE
    elif token[nt+1].kind == LARROW:
      nt.inc(2)
      if token[nt].kind == LPAREN:
        nt = searchNextRparen(nt, argLast, token)
        assert nt > 0
        nt.inc(2)
      elif token[nt].kind == IDENTIFY:
        nt.inc(2)
      assert token[nt].kind == LBRACE
      nt = searchNextRbrace(nt, argLast, token)
      last = nt
      result = F_DEC


proc findF_dec(init, last: var int; token: seq[TOKEN]): SYNTAX_KIND =
  let
    argInit = init
    argLast = last
  var nt = init
  result = OTHER_NODE
  if token[nt].kind == FUNC_KEYWORD:
    last = init
    result = SKIP_NODE
  elif token[nt].kind == LBRACKET:
    last = init
    result = SKIP_NODE
  elif token[nt].kind == RBRACKET:
    last = init
    result = SKIP_NODE
  elif token[nt].kind == LPAREN and token[nt-1].kind == LBRACKET:
    let nxtprn = searchNextRparen(nt, argLast, token)
    assert nxtprn > 0
    last = nxtprn
    result = TYPE_LIST
  elif token[nt].kind == VOID_KEYWORD or token[nt].kind == TYPE_KEYWORD:
    last = init
    result = TYPE
  elif token[nt].kind == RARROW:
    last = init
    result = SKIP_NODE
  elif token[nt].kind == LARROW:
    last = init
    result = SKIP_NODE
  elif token[nt].kind == COLON:
    last = init
    result = SKIP_NODE
  elif token[nt].kind == IDENTIFY and token[nt-1].kind == COLON:
    last = init
    result = VARIABLE
  elif token[nt].kind == LBRACE:
    let nxtbrc = searchNextRbrace(nt, argLast, token)
    assert nxtbrc == argLast
    last = nxtbrc
    result = FUNCTION
  elif token[nt-1].kind == LARROW:
    if token[nt].kind == LPAREN:
      let nxtprn = searchNextRparen(nt, argLast, token)
      assert nxtprn > 0
      last = nxtprn
      result = VARIABLE_LIST
    elif token[nt].kind == IDENTIFY:
      last = nt
      result = VARIABLE


proc findPrototype(init, last: var int; token: seq[TOKEN]): SYNTAX_KIND =
  let
    argInit = init
    argLast = last
  var nt = init
  result = OTHER_NODE
  if token[nt].kind == FUNC_KEYWORD:
    last = init
    result = SKIP_NODE
  elif token[nt].kind == LBRACKET:
    last = init
    result = SKIP_NODE
  elif token[nt].kind == RBRACKET:
    last = init
    result = SKIP_NODE
  elif token[nt].kind == LPAREN and token[nt-1].kind == LBRACKET:
    let nxtprn = searchNextRparen(nt, argLast, token)
    assert nxtprn > 0
    last = nxtprn
    result = TYPE_LIST
  elif token[nt].kind == VOID_KEYWORD or token[nt].kind == TYPE_KEYWORD:
    last = init
    result = TYPE
  elif token[nt].kind == RARROW:
    last = init
    result = SKIP_NODE
  elif token[nt].kind == LARROW:
    last = init
    result = SKIP_NODE
  elif token[nt].kind == COLON:
    last = init
    result = SKIP_NODE
  elif token[nt].kind == IDENTIFY:
    last = init
    result = VARIABLE


proc findV_dec(init, last: var int; token: seq[TOKEN]): SYNTAX_KIND =
  let
    argInit = init
    argLast = last
  var nt = init
  result = OTHER_NODE
  if token[nt].kind == VAR_KEYWORD:
    last = init
    result = SKIP_NODE
  elif token[nt].kind == LBRACKET:
    last = init
    result = SKIP_NODE
  elif token[nt].kind == RBRACKET:
    last = init
    result = SKIP_NODE
  elif token[nt].kind == TYPE_KEYWORD:
    last = init
    result = TYPE
  elif token[nt].kind == COLON:
    last = init
    result = SKIP_NODE
  elif token[nt].kind == IDENTIFY and token[nt+1].kind == RBRACKET:
    last = init
    result = VARIABLE
  elif token[nt].kind == LARROW:
    last = init
    result = SKIP_NODE
  else:
    result = EXPRESSION

proc findFunction(init, last: var int; token: seq[TOKEN]): SYNTAX_KIND =
  let
    argInit = init
    argLast = last
  var nt = init
  result = OTHER_NODE
  if token[nt].kind == LBRACE:
    last = init
    result = SKIP_NODE
  elif token[nt].kind == VAR_KEYWORD:
    assert token[nt+1].kind == LBRACKET
    while token[nt].kind != SEMICOLON:
      nt.inc
    last = nt - 1
    result = V_DEC
  elif token[nt].kind == SEMICOLON:# and token[nt-1].kind == RBRACE:
    last = init
    result = SKIP_NODE
  elif token[nt].kind == RBRACE:
    last = init
    result = SKIP_NODE
  elif token[argLast].kind == RBRACE:
    last = argLast - 1
    result = SENTENCE

proc findSentence(init, last: var int; token: seq[TOKEN]): SYNTAX_KIND =
  let
    argInit = init
    argLast = last
  var nt = init
  result = OTHER_NODE
  if token[nt].kind == SEMICOLON:
    last = init
    result = SKIP_NODE
  elif token[nt].kind == IF_KEYWORD:
    result = IF_FLOW
    nt.inc
    assert(token[nt].kind == LPAREN)
    nt = searchNextRparen(nt, argLast, token)
    assert(nt > 0)
    nt.inc(2)
    assert(token[nt].kind == LBRACE)
    nt = searchNextRbrace(nt, argLast, token)
    assert(nt > 0)
    if nt == argLast: last = nt
    else:
      nt.inc
      if token[nt].kind == ELIF_KEYWORD:
        while token[nt].kind == ELIF_KEYWORD:
          nt.inc
          assert(token[nt].kind == LPAREN)
          nt = searchNextRparen(nt, argLast, token)
          assert(nt > 0)
          nt.inc(2)
          assert(token[nt].kind == LBRACE)
          nt = searchNextRbrace(nt, argLast, token)
          assert(nt > 0)
          nt.inc
      if token[nt].kind == ELSE_KEYWORD:
        nt.inc(2)
        assert(token[nt].kind == LBRACE)
        nt = searchNextRbrace(nt, argLast, token)
        assert(nt > 0)
      else:
        nt.dec
      last = nt
  elif token[nt].kind == WHILE_KEYWORD:
    nt.inc
    assert token[nt].kind == LPAREN
    nt = searchNextRparen(nt, argLast, token)
    assert nt > 0
    nt.inc(2)
    assert token[nt].kind == LBRACE
    nt = searchNextRbrace(nt, argLast, token)
    assert nt > 0
    last = nt
    result = WHILE_FLOW
  elif token[nt].kind == RETURN_KEYWORD:
    while token[nt].kind != SEMICOLON:
      nt.inc
    last = nt
    result = RETURN
  elif token[nt].kind == IDENTIFY:
    if token[nt+1].kind == RARROW:
      result = CALL
      while token[nt].kind != SEMICOLON:
        nt.inc
      last = nt - 1
    elif token[nt+1].kind == LARROW:
      result = ASSIGN
      while token[nt].kind != SEMICOLON:
        nt.inc
      last = nt
  elif token[nt].kind == LPAREN:
    nt = searchNextRparen(nt, argLast, token)
    if token[nt+1].kind == RARROW:
      result = CALL
      while token[nt].kind != SEMICOLON:
        nt.inc
      last = nt - 1
    elif token[nt+1].kind == LARROW:
      result = ASSIGN
      while token[nt].kind != SEMICOLON:
        nt.inc
      last = nt
  elif token[nt].kind == LBRACE:
    #assert searchNextRbrace(nt, argLast, token) == argLast
    last = init
    result = SKIP_NODE
  elif token[nt-1].kind == LBRACE:
    let nxtbrc = searchNextRbrace(nt-1, argLast, token)
    assert nxtbrc > 0
    #assert nxtbrc == argLast
    last = nxtbrc - 1
    result = SENTENCE
  elif token[nt].kind == RBRACE:
    #assert nt == argLast
    last = init
    result = SKIP_NODE

proc findIf_flow(init, last: var int; token: seq[TOKEN]): SYNTAX_KIND =
  let
    argInit = init
    argLast = last
  var nt = init
  result = OTHER_NODE
  if token[nt].kind == IF_KEYWORD or token[nt].kind == ELIF_KEYWORD or token[nt].kind == ELSE_KEYWORD:
    last = init
    result = SKIP_NODE
  elif token[nt].kind == LPAREN and (token[nt-1].kind == IF_KEYWORD or token[nt-1].kind == ELIF_KEYWORD):
    last = init
    result = SKIP_NODE
  elif token[nt-1].kind == LPAREN:
    let nxtprn = searchNextRparen(nt-1, argLast, token)
    assert nt < nxtprn
    last = nxtprn - 1
    result = EXPRESSION
  elif token[nt].kind == RPAREN:
    last = init
    result = SKIP_NODE
  elif token[nt].kind == RARROW:
    last = init
    result = SKIP_NODE
  elif token[nt].kind == LBRACE:
    let nxtbrc = searchNextRbrace(nt, argLast, token)
    assert nt+1 < nxtbrc
    last = nxtbrc
    result = SENTENCE


proc findWhile_flow(init, last: var int; token: seq[TOKEN]): SYNTAX_KIND =
  let
    argInit = init
    argLast = last
  var nt = init
  result = OTHER_NODE
  if token[nt].kind == WHILE_KEYWORD:
    last = init
    result = SKIP_NODE
  elif token[nt].kind == LPAREN and token[nt-1].kind == WHILE_KEYWORD:
    last = init 
    result = SKIP_NODE
  elif token[nt-1].kind == LPAREN:
    let nxtprn = searchNextRparen(nt-1, argLast, token)
    assert nt < nxtprn
    last = nxtprn - 1
    result = EXPRESSION
  elif token[nt].kind == RPAREN:
    last = init
    result = SKIP_NODE
  elif token[nt].kind == RARROW:
    last = init
    result = SKIP_NODE
  elif token[nt].kind == LBRACE:
    let nxtbrc = searchNextRbrace(nt, argLast, token)
    assert nt + 1 < nxtbrc
    last = nxtbrc
    result = SENTENCE

proc findReturn(init, last: var int; token: seq[TOKEN]): SYNTAX_KIND =
  let
    argInit = init
    argLast = last
  var nt = init
  result = OTHER_NODE
  if token[nt].kind == RETURN_KEYWORD:
    assert token[nt+1].kind == LARROW
    last = init
    result = SKIP_NODE
  elif token[nt].kind == LARROW:
    assert token[nt-1].kind == RETURN_KEYWORD
    last = init
    result = SKIP_NODE
  elif token[nt].kind == VOID_KEYWORD:
    last = init
    result = SKIP_NODE
  elif token[nt].kind == SEMICOLON:
    assert nt == argLast
    last = init
    result = SKIP_NODE
  elif token[nt-1].kind == LARROW:
    while token[nt].kind != SEMICOLON:
      nt.inc
    last = nt - 1
    result = EXPRESSION

proc findAssign(init, last: var int; token: seq[TOKEN]): SYNTAX_KIND =
  let
    argInit = init
    argLast = last
  var nt = init
  result = OTHER_NODE
  if token[nt].kind == IDENTIFY and token[nt+1].kind == LARROW:
    last = init
    result = VARIABLE
  elif token[nt].kind == LARROW:
    last = init
    result = SKIP_NODE
  elif token[nt].kind == SEMICOLON:
    assert nt == argLast
    last = init
    result = SKIP_NODE
  elif token[nt].kind == LPAREN:
    nt = searchNextRparen(nt, argLast, token)
    assert nt > 0
    last = nt
    if token[nt+1].kind == LARROW:
      result = VARIABLE_LIST
    elif token[nt+1].kind == SEMICOLON:
      result = EXPRESSION_LIST
  elif token[nt-1].kind == LARROW:
    while token[nt].kind != SEMICOLON:
      nt.inc
    last = nt - 1
    result = EXPRESSION

proc findCall(init, last: var int; token: seq[TOKEN]): SYNTAX_KIND =
  let
    argInit = init
    argLast = last
  var nt = init
  result = OTHER_NODE
  if token[nt].kind == VOID_KEYWORD and argLast - nt == 2:
    assert token[nt+1].kind == RARROW
    last = init
    result = SKIP_NODE
  elif token[nt].kind == RARROW:
    assert token[nt+1].kind == IDENTIFY or token[nt+1].kind == OPERATOR
    last = init
    result = SKIP_NODE
  elif nt == argLast:
    if token[nt].kind == IDENTIFY:
      assert token[nt-1].kind == RARROW
      last = init
      result = VARIABLE
    elif token[nt].kind == OPERATOR:
      assert token[nt-1].kind == RARROW
      last = init
      result = B_OPERATOR
  elif token[nt].kind == LPAREN and searchNextRparen(nt, argLast, token) == argLast - 2:
    assert token[argLast-1].kind == RARROW
    last = argLast - 2
    result = EXPRESSION_LIST
  else:
    assert token[argLast-1].kind == RARROW
    last = argLast - 2
    result = EXPRESSION



proc findExpression_list(init, last: var int; token: seq[TOKEN]): SYNTAX_KIND =
  let 
    argInit = init
    argLast = last
  var
    nt = init
  result = OTHER_NODE
  if token[nt].kind == RPAREN:
    assert nt == argLast
    last = init
    result = SKIP_NODE
  elif token[nt].kind == LPAREN:
    let rparenlocation = searchNextRparen(nt, argLast, token)
    if rparenlocation == argLast:
      last = init
      result = SKIP_NODE
    else:
      nt = rparenlocation + 1
      while token.len > nt and token[nt].kind != COMMA and token[nt].kind != RPAREN:
        nt.inc
      last = nt - 1
      result = EXPRESSION
  elif token[nt].kind == COMMA:
    last = init
    result = SKIP_NODE
  else:
    while token[nt].kind != COMMA and token[nt].kind != RPAREN:
      nt.inc
    last = nt - 1
    result = EXPRESSION



proc findType_list(init, last: var int; token: seq[TOKEN]): SYNTAX_KIND =
  let
    argInit = init
    argLast = last
  var
    nt = init
  result = OTHER_NODE
  if token[nt].kind == RPAREN:
    assert nt == argLast
    last = init
    result = SKIP_NODE
  elif token[nt].kind == LPAREN:
    assert searchNextRparen(nt, argLast, token) == argLast
    last = init
    result = SKIP_NODE
  elif token[nt].kind == COMMA:
    assert (token[nt-1].kind == TYPE_KEYWORD or token[nt-1].kind == VOID_KEYWORD) and (token[nt+1].kind == TYPE_KEYWORD or token[nt+1].kind == VOID_KEYWORD)
    last = init
    result = SKIP_NODE
  elif token[nt].kind == TYPE_KEYWORD or token[nt].kind == VOID_KEYWORD:
    last = init
    result = TYPE


proc findVariable_list(init, last: var int; token: seq[TOKEN]): SYNTAX_KIND =
  let
    argInit = init
    argLast = last
  var
    nt = init
  result = OTHER_NODE
  if token[nt].kind == RPAREN:
    assert nt == argLast
    last = init
    result = SKIP_NODE
  elif token[nt].kind == LPAREN:
    assert searchNextRparen(nt, argLast, token) == argLast
    last = init
    result = SKIP_NODE
  elif token[nt].kind == COMMA:
    assert token[nt-1].kind == IDENTIFY and token[nt+1].kind == IDENTIFY
    last = init
    result = SKIP_NODE
  elif token[nt].kind == IDENTIFY:
    last = init
    result = VARIABLE

proc findExpression(init, last: var int; token: seq[TOKEN]): SYNTAX_KIND =
  let
    argInit = init
    argLast = last
  var nt = init
  result = OTHER_NODE
  if token[nt].kind == LPAREN:
    result = CALL
  elif token[nt].kind == IDENTIFY:
    if argLast == argInit:
      result = VARIABLE
    elif token[nt+1].kind == RARROW:
      result = CALL
  elif token[nt].kind == VOID_KEYWORD:
    result = CALL
  elif nt < argLast and token[nt+1].kind == RARROW:
    result = CALL
  elif token[nt].kind == NUMBER:
    result = LITERAL
  elif token[nt].kind == STRING:
    result = LITERAL



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
  echo repr(node)
