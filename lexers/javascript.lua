-- Copyright 2006-2010 Mitchell Foral mitchell<att>caladbolg.net. See LICENSE.
-- JavaScript LPeg Lexer

local l = lexer
local token, style, color, word_match = l.token, l.style, l.color, l.word_match
local P, R, S = l.lpeg.P, l.lpeg.R, l.lpeg.S

module(...)

local ws = token('js_whitespace', l.space^1)

local newline = #S('\r\n\f') * P(function(input, idx)
  if input:sub(idx - 1, idx - 1) ~= '\\' then return idx end
end) * S('\r\n\f')^1

-- comments
local line_comment = '//' * l.nonnewline_esc^0
local block_comment = '/*' * (l.any - '*/')^0 * P('*/')^-1
local comment = token('comment', line_comment + block_comment)

-- strings
local sq_str = l.delimited_range("'", '\\', true)
local dq_str = l.delimited_range('"', '\\', true)
local regex_str = l.delimited_range('/', '\\', nil, nil, '\n') * S('igm')^0
local string = token('string', sq_str + dq_str) + token('regex', regex_str)

-- numbers
local number = token('number', l.float + l.integer)

-- keywords
local keyword = token('keyword', word_match {
  'abstract', 'boolean', 'break', 'byte', 'case', 'catch', 'char',
  'class', 'const', 'continue', 'debugger', 'default', 'delete',
  'do', 'double', 'else', 'enum', 'export', 'extends', 'false',
  'final', 'finally', 'float', 'for', 'function', 'goto', 'if',
  'implements', 'import', 'in', 'instanceof', 'int', 'interface',
  'let', 'long', 'native', 'new', 'null', 'package', 'private',
  'protected', 'public', 'return', 'short', 'static', 'super',
  'switch', 'synchronized', 'this', 'throw', 'throws', 'transient',
  'true', 'try', 'typeof', 'var', 'void', 'volatile', 'while',
  'with', 'yield'
})

-- identifiers
local identifier = token('identifier', l.word)

-- operators
local operator = token('operator', S('+-/*%^!=&|?:;.()[]{}<>'))

_rules = {
  { 'js_whitespace', ws },
  { 'keyword', keyword },
  { 'identifier', identifier },
  { 'comment', comment },
  { 'number', number },
  { 'string', string },
  { 'operator', operator },
  { 'any_char', l.any_char },
}

_tokenstyles = {
  { 'js_whitespace', l.style_nothing },
  { 'regex', l.style_string..{ back = color('44', '44', '44')} },
}
