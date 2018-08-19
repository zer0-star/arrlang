import common, lexer, tree, sequtils, algorithm

proc freshTree*(s: SOURCE)
proc goNextNode*(node: NODE): NODE
proc deleteNodeRecursive*(node: NODE)
proc replaceBySolitaryNode*(node: NODE)
proc countHorizontal*(node: NODE): int
proc countVertical*(node: NODE): int


proc countVertical*(node: NODE): int =
  result = 0
  var up = node.up
  while up != nil:
    result.inc
    up = up.up

proc countHorizontal*(node: NODE): int =
  var left = node
  while left.left != nil: left = left.left
  result = 1
  while left.right != nil:
    left = left.right
    result.inc

proc freshTree*(s: SOURCE) =
  for n in s.node:
    n.arrived = false

proc replaceBySolitaryNode*(node: NODE) =
  if node.up != nil and node.left == nil and node.right == nil:
    node.up.kind = node.kind
    node.up.init = node.init
    node.up.last = node.last
    node.up.down = node.down
    var down = node.down
    while down != nil:
      down.up = node.up
      down = down.right

proc goNextNode*(node: NODE): NODE =
  if node.arrived:
    if node.right != nil: result = node.right
    elif node.up != nil: result = node.up
    else: result = nil
  else:
    node.arrived = true
    if node.down != nil: result = node.down
    elif node.right != nil: result = node.right
    elif node.up != nil: result = node.up
    else: result = nil


proc deleteNodeRecursive*(node: NODE) =
  assert node.up != nil
  if node.left != nil and node.right != nil:
    node.left.right = node.right
    node.right.left = node.left
  elif node.left != nil and node.right == nil:
    node.left.right = nil
  elif node.left == nil and node.right != nil:
    node.right.left = nil
    node.up.down = node.right
  elif node.left == nil and node.right == nil:
    node.up.down = nil

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
  var nodetmp = src.program
  while nodetmp != nil:
    if nodetmp.kind == SKIP_NODE: deleteNodeRecursive(nodetmp)
    nodetmp = goNextNode(nodetmp)
  src.freshTree
  echo src.program.repr
