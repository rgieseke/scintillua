-- Copyright 2006-2010 Mitchell Foral mitchell<att>caladbolg.net. See LICENSE.
-- Vala LPeg Lexer

local l = lexer
local token, style, color, word_match = l.token, l.style, l.color, l.word_match
local P, R, S = l.lpeg.P, l.lpeg.R, l.lpeg.S

module(...)

local ws = token('whitespace', l.space^1)

-- comments
local line_comment = '//' * l.nonnewline_esc^0
local block_comment = '/*' * (l.any - '*/')^0 * P('*/')^-1
local comment = token('comment', line_comment + block_comment)

-- strings
local sq_str = l.delimited_range("'", '\\', true, false, '\n')
local dq_str = l.delimited_range('"', '\\', true, false, '\n')
local ml_str = '@' * l.delimited_range('"', nil, true)
local string = token('string', sq_str + dq_str + ml_str)

-- numbers
local number = token('number', (l.float + l.integer) * S('uUlLfFdDmM')^-1)

-- keywords
local keyword = token('keyword', word_match {
  'class', 'delegate', 'enum', 'errordomain', 'interface', 'namespace',
  'signal', 'struct', 'using',
  -- modifiers
  'abstract', 'const', 'dynamic', 'extern', 'inline', 'out', 'override',
  'private', 'protected', 'public', 'ref', 'static', 'virtual', 'volatile',
  'weak',
  -- other
  'as', 'base', 'break', 'case', 'catch', 'construct', 'continue', 'default',
  'delete', 'do', 'else', 'ensures', 'finally', 'for', 'foreach', 'get', 'if',
  'in', 'is', 'lock', 'new', 'requires', 'return', 'set', 'sizeof', 'switch',
  'this', 'throw', 'throws', 'try', 'typeof', 'value', 'var', 'void', 'while',
  -- etc.
  'null', 'true', 'false'
})

-- types
local type = token('type', word_match {
  'bool', 'char', 'double', 'float', 'int', 'int8', 'int16', 'int32', 'int64',
  'long', 'short', 'size_t', 'ssize_t', 'string', 'uchar', 'uint', 'uint8',
  'uint16', 'uint32', 'uint64', 'ulong', 'unichar', 'ushort'
})

-- identifiers
local identifier = token('identifier', l.word)

-- operators
local operator = token('operator', S('+-/*%<>!=^&|?~:;.()[]{}'))

_rules = {
  { 'whitespace', ws },
  { 'keyword', keyword },
  { 'type', type },
  { 'identifier', identifier },
  { 'string', string },
  { 'comment', comment },
  { 'number', number },
  { 'operator', operator },
  { 'any_char', l.any_char },
}
