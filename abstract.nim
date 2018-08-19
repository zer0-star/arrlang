import common, lexer, tree, nodeedit

proc eliminateInsignificant*(s: SOURCE)
proc eliminateRedundantSentence(s: SOURCE)
proc eliminateRedundantMath(s: SOURCE)

proc eliminateInsignificant*(s: SOURCE) =
  var node = s.program
  freshTree(s)
  while node != nil:
    if node.kind == SKIP_NODE: node.deleteNodeRecursive
    node = goNextNode(node)

proc eliminateRedundantSentence(s: SOURCE) =
  var node = s.program
  freshTree(s)
  while node != nil:
    if node.up == nil:
      node = goNextNode(node)
      continue
    if node.up.kind == SENTENCE: replaceBySolitaryNode(node)
    node = goNextNode(node)

proc eliminateRedundantMath(s: SOURCE) =
  var node = s.program
  freshTree(s)
  while node != nil:
    if node.up == nil:
      node = goNextNode(node)
      continue
    if ( node.kind == LITERAL or node.kind == VARIABLE or node.kind == CALL or node.kind == EXPRESSION) and node.kind == EXPRESSION:
      replaceBySolitaryNode(node)
    node = goNextNode(node)


