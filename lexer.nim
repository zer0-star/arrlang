import strutils, sequtils, algorithm, os, common

proc getNextToken(fp: FileP): TOKEN
proc getNextChar(fp: FileP): char
proc addCharToTokenStr(ret: TOKEN; ch: char)
proc addStrToTokenStr(ret: TOKEN; str: string)
proc ifNextStr(fp: FileP; str: string): bool

proc getNextToken(fp: FileP): TOKEN =
  result = initToken()
  var ch, ch_more: char
  if fp.endOfFile: return
  ch = fp.getNextChar
  if ch.isSpaceAscii:
    while true:
      if fp.endOfFile: return
      ch = fp.getNextChar
      if not ch.isSpaceAscii: break
  if ch == '<':
    result.addCharToTokenStr(ch)
    ch_more = fp.getNextChar
    if ch_more == '-':
      result.addCharToTokenStr(ch_more)
      result.kind = LARROW
    else:
      fp.ungetc
      result.kind = OPERATOR
    return
  elif ch == ',':
    result.addCharToTokenStr(ch)
    result.kind = COMMA
    return
  elif ch == ':':
    result.addCharToTokenStr(ch)
    result.kind = COLON
    return
  elif ch == ';':
    result.addCharToTokenStr(ch)
    result.kind = SEMICOLON
    return
  elif ch == '(':
    result.addCharToTokenStr(ch)
    result.kind = LPAREN
    return
  elif ch == ')':
    result.addCharToTokenStr(ch)
    result.kind = RPAREN
    return
  elif ch == '[':
    result.addCharToTokenStr(ch)
    result.kind = LBRACKET
    return
  elif ch == ']':
    result.addCharToTokenStr(ch)
    result.kind = RBRACKET
    return
  elif ch == '{':
    result.addCharToTokenStr(ch)
    result.kind = LBRACE
    return
  elif ch == '}':
    result.addCharToTokenStr(ch)
    result.kind = RBRACE
    return
  elif ch == '+' or ch == '*' or ch == '/' or ch == '=' or ch == '>':
    result.addCharToTokenStr(ch)
    result.kind = OPERATOR
    return
  elif ch == '-':
    result.addCharToTokenStr(ch)
    ch_more = fp.getNextChar
    if ch_more == '>':
      result.addCharToTokenStr(ch_more)
      result.kind = RARROW
    else:
      fp.ungetc
      result.kind = OPERATOR
    return
  elif fp.ifNextStr("if"):
    result.addStrToTokenStr("if")
    result.kind = IF_KEYWORD
    return
  elif fp.ifNextStr("elif"):
    result.addStrToTokenStr("elif")
    result.kind = ELIF_KEYWORD
    return
  elif fp.ifNextStr("else"):
    result.addStrToTokenStr("else")
    result.kind = ELSE_KEYWORD
    return
  elif fp.ifNextStr("while"):
    result.addStrToTokenStr("while")
    result.kind = WHILE_KEYWORD
    return
  elif fp.ifNextStr("int"):
    result.addStrToTokenStr("int")
    result.kind = TYPE_KEYWORD
    return
  elif fp.ifNextStr("void"):
    result.addStrToTokenStr("void")
    result.kind = VOID_KEYWORD
    return
  elif fp.ifNextStr("func"):
    result.addStrToTokenStr("func")
    result.kind = FUNC_KEYWORD
    return
  elif fp.ifNextStr("var"):
    result.addStrToTokenStr("var")
    result.kind = VAR_KEYWORD
    return
  elif fp.ifNextStr("return"):
    result.addStrToTokenStr("return")
    result.kind = RETURN_KEYWORD
    return
  elif ch == '"':
    result.addCharToTokenStr(ch)
    result.kind = STRING
    while true:
      ch_more = fp.getc
      result.addCharToTokenStr(ch_more)
      if ch_more == '"':
        break
  elif ch.isDigit:
    result.addCharToTokenStr(ch)
    result.kind = NUMBER
    while true:
      ch_more = fp.getNextChar
      if ch_more.isDigit: result.addCharToTokenStr(ch_more)
      else:
        fp.ungetc
        break
    return
  elif ch.isAlphaAscii or ch == '_':
    result.addCharToTokenStr(ch)
    result.kind = IDENTIFY
    while true:
      ch_more = fp.getNextChar
      if ch_more.isAlphaNumeric or ch_more == '_': result.addCharToTokenStr(ch_more)
      else:
        fp.ungetc
        break
    return
  else: 
    result.addCharToTokenStr(ch)
    result.kind = OTHER_TOKEN
    stderr.writeLine("unexpected token: ", ch)
    return




proc getNextChar(fp: FileP): char =
  result = fp.getc
  if result == '#':
    result = ' '
    while true:
      if fp.endOfFile or fp.getc == '\n': break
  elif result == '\n': result = ';'
  elif result.isSpaceAscii: result = ' '

proc addCharToTokenStr(ret: TOKEN; ch: char) =
  ret.str &= ch

proc addStrToTokenStr(ret: TOKEN; str: string) =
  ret.str &= str

proc ifNextStr(fp: FileP; str: string): bool =
  fp.ungetc
  result = true
  for i in 0..<str.len:
    if fp.endOfFile or not (fp.getc == str[i]):
      for j in 0..<i:
        fp.ungetc
      result = false
      break
  if result:
    var ch = fp.getc
    if ch.isAlphaAscii or ch.isDigit or ch == '_':
      for i in 0..<str.len:
        fp.ungetc
      result = false
    else:
      fp.ungetc

proc getTokens*(fp: FileP): seq[TOKEN] =
  let blankToken = initToken()
  var tmpToken = initToken()
  result = @[]
  fp.index = 0
  while true:
    tmpToken = fp.getNextToken
    if tmpToken.kind == blankToken.kind and tmpToken.str == blankToken.str: break
    if result.len > 0 and tmpToken.kind == SEMICOLON:
      if tmpToken.kind == result[^1].kind or result[^1].kind == RBRACE or result[^1].kind == LBRACE:
        continue
    result.add(tmpToken)
  if result[^1].kind != SEMICOLON and result[^1].kind != RBRACE: result.add(TOKEN(kind: SEMICOLON, str: ";"))
  fp.index = 0
