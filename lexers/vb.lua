-- Copyright 2006-2011 Mitchell mitchell<att>caladbolg.net. See LICENSE.
-- VisualBasic LPeg lexer.

local l = lexer
local token, style, color, word_match = l.token, l.style, l.color, l.word_match
local P, R, S = l.lpeg.P, l.lpeg.R, l.lpeg.S

module(...)

-- Whitespace.
local ws = token(l.WHITESPACE, l.space^1)

-- Comments.
local comment = token(l.COMMENT, (P("'") + 'REM ') * l.nonnewline^0)

-- Strings.
local string = token(l.STRING, l.delimited_range('"', nil, true, false, '\n'))

-- Numbers.
local number = token(l.NUMBER, (l.float + l.integer) * S('LlUuFf')^-2)

-- Keywords.
local keyword = token(l.KEYWORD, word_match {
  -- Control.
  'If', 'Then', 'Else', 'ElseIf', 'EndIf', 'While', 'Went', 'For', 'To', 'Each',
  'In', 'Step', 'Case', 'Select', 'EndSelect', 'Return', 'Continue', 'Do',
  'Until', 'Loop', 'Next', 'With', 'Exit',
  -- Operators.
  'Mod', 'And', 'Not', 'Or', 'Xor', 'Is',
  -- Storage types.
  'Call', 'Class', 'Const', 'Dim', 'Redim', 'Function', 'Sub', 'Property',
  'End', 'Set', 'Let', 'Get', 'New', 'Randomize',
  -- Storage modifiers.
  'Private', 'Public', 'Default',
  -- Constants.
  'Empty', 'False', 'Nothing', 'Null', 'True'
})

-- Types.
local type = token(l.TYPE, word_match {
  'Boolean', 'Byte', 'Char', 'Date', 'Decimal', 'Double', 'Long', 'Object',
  'Short', 'Single', 'String'
})

-- Identifiers.
local identifier = token(l.IDENTIFIER, l.word)

-- Operators.
local operator = token(l.OPERATOR, S('=><+-*^&:.,_()'))

_rules = {
  { 'whitespace', ws },
  { 'keyword', keyword },
  { 'type', type },
  { 'comment', comment },
  { 'identifier', identifier },
  { 'string', string },
  { 'number', number },
  { 'operator', operator },
  { 'any_char', l.any_char },
}
