import strutils, sequtils, algorithm, os

type
  TOKEN_KIND* = enum
    LARROW
    RARROW
    COMMA
    COLON
    SEMICOLON
    LPAREN
    RPAREN
    LBRACKET
    RBRACKET
    LBRACE
    RBRACE
    OPERATOR
    IF_KEYWORD
    ELIF_KEYWORD
    ELSE_KEYWORD
    WHILE_KEYWORD
    FOR_KEYWORD
    TYPE_KEYWORD
    VOID_KEYWORD
    FUNC_KEYWORD
    VAR_KEYWORD
    RETURN_KEYWORD
    IDENTIFY
    NUMBER
    STRING
    OTHER_TOKEN
    UNTYPED
  SYNTAX_KIND* = enum
    PROGRAM
    F_DEC
    PROTOTYPE
    V_DEC
    FUNCTION
    SENTENCE
    IF_FLOW
    WHILE_FLOW
    RETURN
    ASSIGN
    CALL
    EXPRESSION_LIST
    TYPE_LIST
    VARIABLE_LIST
    TYPE
    EXPRESSION
    LITERAL
    B_OPERATOR
    VARIABLE
    VOID
    OTHER_NODE
    SKIP_NODE
  TOKEN* = ref object of RootObj
    kind*: TOKEN_KIND
    str*: string
  NODE* = ref object of RootObj
    kind*: SYNTAX_KIND
    init*, last*: int
    arrived*: bool
    up*, left*, right*, down*: NODE
  FileP* = ref object of RootObj
    str*: string
    index*: int
  SOURCE* = ref object of RootObj
    program*: NODE
    node*: seq[NODE]
    token*: seq[TOKEN]


proc initToken*(): TOKEN =
  result = TOKEN(kind: UNTYPED, str: "")

proc openr*(filename: string): FileP =
  return FileP(str: filename.readFile, index: 0)

proc endOfFile*(fp: FileP): bool =
  return fp.index >= fp.str.len

proc getc*(fp: FileP): char =
  if fp.endOfFile:
    result = '\0'
  else:
    result = fp.str[int(fp.index)]
    fp.index.inc

proc ungetc*(fp: FileP) =
  fp.index.dec
