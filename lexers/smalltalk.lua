-- Copyright 2006-2011 Mitchell mitchell<att>caladbolg.net. See LICENSE.
-- Smalltalk LPeg lexer.

local l = lexer
local token, style, color, word_match = l.token, l.style, l.color, l.word_match
local P, R, S = l.lpeg.P, l.lpeg.R, l.lpeg.S

module(...)

-- Whitespace.
local ws = token(l.WHITESPACE, l.space^1)

-- Comments.
local comment = token(l.COMMENT, l.delimited_range('"', nil, true))

-- Strings.
local sq_str = l.delimited_range("'", '\\', true)
local literal = '$' * l.word
local string = token(l.STRING, sq_str + literal)

-- Numbers.
local number = token(l.NUMBER, l.float + l.integer)

-- Keywords.
local keyword = token(l.KEYWORD, word_match {
  'true', 'false', 'nil', 'self', 'super', 'isNil', 'not', 'Smalltalk',
  'Transcript'
})

-- Types.
local type = token(l.TYPE, word_match {
  'Date', 'Time', 'Boolean', 'True', 'False', 'Character', 'String', 'Array',
  'Symbol', 'Integer', 'Object'
})

-- Identifiers.
local identifier = token(l.IDENTIFIER, l.word)

-- Operators.
local operator = token(l.OPERATOR, S(':=_<>+-/*!()[]'))

-- Labels.
local label = token('label', '#' * l.word)

_rules = {
  { 'whitespace', ws },
  { 'keyword', keyword },
  { 'type', type },
  { 'identifier', identifier },
  { 'string', string },
  { 'comment', comment },
  { 'number', number },
  { 'label', label },
  { 'operator', operator },
  { 'any_char', l.any_char },
}

_tokenstyles = {
  { 'label', l.style_variable },
}

_foldsymbols = {
  _patterns = { '[%[%]]' },
  [l.OPERATOR] = { ['['] = 1, [']'] = -1 }
}
