-- Copyright 2006-2010 Mitchell Foral mitchell<att>caladbolg.net. See LICENSE.
-- Boo LPeg lexer

local l = lexer
local token, style, color, word_match = l.token, l.style, l.color, l.word_match
local P, R, S = l.lpeg.P, l.lpeg.R, l.lpeg.S

module(...)

local ws = token('whitespace', l.space^1)

local lit_newline = P('\r')^-1 * P('\n')

-- comments
local line_comment = '#' * l.nonnewline_esc^0
local block_comment = '/*' * (l.any - '*/')^0 * P('*/')^-1
local comment = token('comment', line_comment + block_comment)

-- strings
local sq_str = l.delimited_range("'", '\\', true, false, '\n')
local dq_str = l.delimited_range('"', '\\', true, false, '\n')
local triple_dq_str = '"""' * (l.any - '"""')^0 * P('"""')^-1
local regex = l.delimited_range('/', '\\', false, false, '\n')
local string = token('string', triple_dq_str + sq_str + dq_str + regex)

-- numbers
local number =
  token('number', (l.float + l.integer) * (S('msdhsfFlL') + 'ms')^-1)

-- keywords
local keyword = token('keyword', word_match {
  'and', 'break', 'cast', 'continue', 'elif', 'else', 'ensure', 'except', 'for',
  'given', 'goto', 'if', 'in', 'isa', 'is', 'not', 'or', 'otherwise', 'pass',
  'raise', 'ref', 'try', 'unless', 'when', 'while',
  -- definitions
  'abstract', 'callable', 'class', 'constructor', 'def', 'destructor', 'do',
  'enum', 'event', 'final', 'get', 'interface', 'internal', 'of', 'override',
  'partial', 'private', 'protected', 'public', 'return', 'set', 'static',
  'struct', 'transient', 'virtual', 'yield',
  -- namespaces
  'as', 'from', 'import', 'namespace',
  -- other
  'self', 'super', 'null', 'true', 'false'
})

-- types
local type = token('type', word_match {
  'bool', 'byte', 'char', 'date', 'decimal', 'double', 'duck', 'float', 'int',
  'long', 'object', 'operator', 'regex', 'sbyte', 'short', 'single', 'string',
  'timespan', 'uint', 'ulong', 'ushort'
})

-- functions
local func = token('function', word_match {
  'array', 'assert', 'checked', 'enumerate', '__eval__', 'filter', 'getter',
  'len', 'lock', 'map', 'matrix', 'max', 'min', 'normalArrayIndexing', 'print',
  'property', 'range', 'rawArrayIndexing', 'required', '__switch__', 'typeof',
  'unchecked', 'using', 'yieldAll', 'zip'
})

-- identifiers
local identifier = token('identifier', l.word)

-- operators
local operator = token('operator', S('!%^&*()[]{}-=+/|:;.,?<>~`'))

_rules = {
  { 'whitespace', ws },
  { 'keyword', keyword },
  { 'type', type },
  { 'function', func },
  { 'identifier', identifier },
  { 'string', string },
  { 'comment', comment },
  { 'number', number },
  { 'operator', operator },
  { 'any_char', l.any_char },
}
