-- Copyright 2006-2010 Mitchell Foral mitchell<att>caladbolg.net. See LICENSE.
-- Postscript LPeg lexer

local l = lexer
local token, style, color, word_match = l.token, l.style, l.color, l.word_match
local P, R, S = l.lpeg.P, l.lpeg.R, l.lpeg.S

module(...)

local ws = token('whitespace', l.space^1)

-- comments
local comment = token('comment', '%' * l.nonnewline^0)

-- strings
local arrow_string = l.delimited_range('<>', '\\', true)
local nested_string = l.delimited_range('()', '\\', true, true)
local string = token('string', arrow_string + nested_string)

-- numbers
local number = token('number', l.float + l.integer)

-- keywords
local keyword = token('keyword', word_match {
  'pop', 'exch', 'dup', 'copy', 'roll', 'clear', 'count', 'mark', 'cleartomark',
  'counttomark', 'exec', 'if', 'ifelse', 'for', 'repeat', 'loop', 'exit',
  'stop', 'stopped', 'countexecstack', 'execstack', 'quit', 'start',
  'true', 'false', 'NULL'
})

-- functions
local func = token('function', word_match {
  'add', 'div', 'idiv', 'mod', 'mul', 'sub', 'abs', 'ned', 'ceiling', 'floor',
  'round', 'truncate', 'sqrt', 'atan', 'cos', 'sin', 'exp', 'ln', 'log', 'rand',
  'srand', 'rrand'
})

-- identifiers
local word = (l.alpha + '-') * (l.alnum + '-')^0
local identifier = token('identifier', word)

-- labels
local label = token('label', '/' * word)

-- operators
local operator = token('operator', S('[]{}'))

_rules = {
  { 'whitespace', ws },
  { 'keyword', keyword },
  { 'function', func },
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
