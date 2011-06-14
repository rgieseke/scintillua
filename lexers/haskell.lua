-- Copyright 2006-2011 Mitchell mitchell<att>caladbolg.net. See LICENSE.
-- Haskell LPeg lexer.
-- Modified by Alex Suraci.

local l = lexer
local token, style, color, word_match = l.token, l.style, l.color, l.word_match
local P, R, S = l.lpeg.P, l.lpeg.R, l.lpeg.S

module(...)

-- Whitespace.
local ws = token(l.WHITESPACE, l.space^1)

-- Comments.
local line_comment = '--' * l.nonnewline_esc^0
local block_comment = '{-' * (l.any - '-}')^0 * P('-}')^-1
local comment = token(l.COMMENT, line_comment + block_comment)

-- Strings.
local string = token(l.STRING, l.delimited_range('"', '\\'))

-- Chars.
local char = token('char', l.delimited_range("'", "\\", false, false, '\n'))

-- Numbers.
local number = token(l.NUMBER, l.float + l.integer)

-- Keywords.
local keyword = token(l.KEYWORD, word_match {
  'case', 'class', 'data', 'default', 'deriving', 'do', 'else', 'if', 'import',
  'in', 'infix', 'infixl', 'infixr', 'instance', 'let', 'module', 'newtype',
  'of', 'then', 'type', 'where', '_', 'as', 'qualified', 'hiding'
})

-- Identifiers.
local word = (l.alnum + S("._'#"))^0
local identifier = token(l.IDENTIFIER, (l.alpha + '_') * word)

-- Operators.
local op = l.punct - S('()[]{}')
local operator = token(l.OPERATOR, op)

-- Types & type constructors.
local constructor = token(l.TYPE, (l.upper * word) + (P(":") * (op^1 - P(":"))))

_rules = {
  { 'whitespace', ws },
  { 'keyword', keyword },
  { 'type', constructor },
  { 'identifier', identifier },
  { 'string', string },
  { 'char', char },
  { 'comment', comment },
  { 'number', number },
  { 'operator', operator },
  { 'any_char', l.any_char },
}
