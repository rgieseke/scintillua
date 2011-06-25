-- Copyright 2006-2011 Mitchell mitchell<att>caladbolg.net. See LICENSE.
-- ANTLR LPeg lexer.

local l = lexer
local token, style, color, word_match = l.token, l.style, l.color, l.word_match
local P, R, S = l.lpeg.P, l.lpeg.R, l.lpeg.S

module(...)

-- Whitespace.
local ws = token(l.WHITESPACE, l.space^1)

-- Comments.
local line_comment = '//' * l.nonnewline^0
local block_comment = '/*' * (l.any - '*/')^0 * P('*/')^-1
local comment = token(l.COMMENT, line_comment + block_comment)

-- Strings.
local string = token(l.STRING, l.delimited_range("'", '\\', true, false, '\n'))

-- Keywords.
local keyword = token(l.KEYWORD, word_match {
  'abstract', 'break', 'case', 'catch', 'continue', 'default', 'do', 'else',
  'extends', 'final', 'finally', 'for', 'if', 'implements', 'instanceof',
  'native', 'new', 'private', 'protected', 'public', 'return', 'static',
  'switch', 'synchronized', 'throw', 'throws', 'transient', 'try', 'volatile',
  'while', 'package', 'import', 'header', 'options', 'tokens', 'strictfp',
  'false', 'null', 'super', 'this', 'true'
})

-- Types.
local type = token(l.TYPE, word_match {
  'boolean', 'byte', 'char', 'class', 'double', 'float', 'int', 'interface',
  'long', 'short', 'void'
})

-- Functions.
local func = token(l.FUNCTION, 'assert')

-- Identifiers.
local identifier = token(l.IDENTIFIER, l.word)

-- Operators.
local operator = token(l.OPERATOR, S('$@:;|.=+*?~!^>-()[]{}'))

-- Actions.
local action = #P('{') * operator * token('action', (1 - P('}'))^0) *
               (#P('}') * operator)^-1

_rules = {
  { 'whitespace', ws },
  { 'keyword', keyword },
  { 'type', type },
  { 'function', func },
  { 'identifier', identifier },
  { 'string', string },
  { 'comment', comment },
  { 'action', action },
  { 'operator', operator },
  { 'any_char', l.any_char },
}

_tokenstyles = {
  { 'action', l.style_nothing..{ italic = true } }
}

_foldsymbols = {
  _patterns = { '[:;%(%){}]', '/%*', '%*/', '//' },
  [l.OPERATOR] = {
    [':'] = 1, [';'] = -1, ['('] = 1, [')'] = -1, ['{'] = 1, ['}'] = -1
  },
  [l.COMMENT] = { ['/*'] = 1, ['*/'] = -1, ['//'] = l.fold_line_comments('//') }
}
