-- Copyright 2006-2011 Brian "Sir Alaran" Schott. See LICENSE.
-- Dot LPeg lexer.
-- Based off of lexer code by Mitchell.

local l = lexer
local token, style, color, word_match = l.token, l.style, l.color, l.word_match
local P, R, S = l.lpeg.P, l.lpeg.R, l.lpeg.S

module(...)

-- Whitespace.
local ws = token(l.WHITESPACE, l.space^1)

-- Comments.
local line_comment = '//' * l.nonnewline_esc^0
local block_comment = '/*' * (l.any - '*/')^0 * P('*/')^-1
local comment = token(l.COMMENT, line_comment + block_comment)

-- Strings.
local sq_str = l.delimited_range("'", '\\', true)
local dq_str = l.delimited_range('"', '\\', true)
local string = token(l.STRING, sq_str + dq_str)

-- Numbers.
local number = token(l.NUMBER, l.digit^1 + l.float)

-- Keywords.
local keyword = token(l.KEYWORD, word_match {
  'graph', 'node', 'edge', 'digraph', 'fontsize', 'rankdir',
  'fontname', 'shape', 'label', 'arrowhead', 'arrowtail', 'arrowsize',
  'color', 'comment', 'constraint', 'decorate', 'dir', 'headlabel', 'headport',
  'headURL', 'labelangle', 'labeldistance', 'labelfloat', 'labelfontcolor',
  'labelfontname', 'labelfontsize', 'layer', 'lhead', 'ltail', 'minlen',
  'samehead', 'sametail', 'style', 'taillabel', 'tailport', 'tailURL', 'weight',
  'subgraph'
})

-- Types.
local type = token(l.TYPE, word_match {
	'box', 'polygon', 'ellipse', 'circle', 'point', 'egg', 'triangle',
	'plaintext', 'diamond', 'trapezium', 'parallelogram', 'house', 'pentagon',
	'hexagon', 'septagon', 'octagon', 'doublecircle', 'doubleoctagon',
	'tripleoctagon', 'invtriangle', 'invtrapezium', 'invhouse', 'Mdiamond',
	'Msquare', 'Mcircle', 'rect', 'rectangle', 'none', 'note', 'tab', 'folder',
	'box3d', 'record'
})

-- Identifiers.
local identifier = token(l.IDENTIFIER, l.word)

-- Operators.
local operator = token(l.OPERATOR, S('->()[]{};'))

_rules = {
  { 'whitespace', ws },
  { 'comment', comment },
  { 'keyword', keyword },
  { 'type', type },
  { 'identifier', identifier },
  { 'number', number },
  { 'string', string },
  { 'operator', operator },
  { 'any_char', l.any_char },
}

_foldsymbols = {
  _patterns = { '[{}]', '/%*', '%*/', '//' },
  [l.OPERATOR] = { ['{'] = 1, ['}'] = -1 },
  [l.COMMENT] = { ['/*'] = 1, ['*/'] = -1, ['//'] = l.fold_line_comments('//') }
}
