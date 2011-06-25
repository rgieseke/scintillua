-- Copyright 2006-2011 Mitchell mitchell<att>caladbolg.net. See LICENSE.
-- Gtkrc LPeg lexer.

local l = lexer
local token, style, color, word_match = l.token, l.style, l.color, l.word_match
local P, R, S = l.lpeg.P, l.lpeg.R, l.lpeg.S

module(...)

-- Whitespace.
local ws = token(l.WHITESPACE, l.space^1)

-- Comments.
local comment = token(l.COMMENT, '#' * l.nonnewline^0)

-- Strings.
local sq_str = l.delimited_range("'", '\\', true, false, '\n')
local dq_str = l.delimited_range('"', '\\', true, false, '\n')
local string = token(l.STRING, sq_str + dq_str)

-- Numbers.
local number = token(l.NUMBER, l.digit^1 * ('.' * l.digit^1)^-1)

-- Keywords.
local keyword = token(l.KEYWORD, word_match {
  'binding', 'class', 'include', 'module_path', 'pixmap_path', 'im_module_file',
  'style', 'widget', 'widget_class'
})

-- Variables.
local variable = token(l.VARIABLE, word_match {
  'bg', 'fg', 'base', 'text', 'xthickness', 'ythickness', 'bg_pixmap', 'font',
  'fontset', 'font_name', 'stock', 'color', 'engine'
})

-- States.
local state = token(l.CONSTANT, word_match {
  'ACTIVE', 'SELECTED', 'NORMAL', 'PRELIGHT', 'INSENSITIVE', 'TRUE', 'FALSE'
})

-- Functions.
local func = token(l.FUNCTION, word_match {
  'mix', 'shade', 'lighter', 'darker'
})

-- Identifiers.
local identifier = token(l.IDENTIFIER, l.alpha * (l.alnum + S('_-'))^0)

-- Operators.
local operator = token(l.OPERATOR, S(':=,*()[]{}'))

_rules = {
  { 'whitespace', ws },
  { 'keyword', keyword },
  { 'variable', variable },
  { 'state', state },
  { 'function', func },
  { 'identifier', identifier },
  { 'string', string },
  { 'comment', comment },
  { 'number', number },
  { 'operator', operator },
  { 'any_char', l.any_char },
}

_foldsymbols = {
  _patterns = { '[{}]', '#' },
  [l.OPERATOR] = { ['{'] = 1, ['}'] = -1 },
  [l.COMMENT] = { ['#'] = l.fold_line_comments('#') }
}
