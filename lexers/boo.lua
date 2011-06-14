-- Copyright 2006-2011 Mitchell mitchell<att>caladbolg.net. See LICENSE.
-- Boo LPeg lexer.

local l = lexer
local token, style, color, word_match = l.token, l.style, l.color, l.word_match
local P, R, S = l.lpeg.P, l.lpeg.R, l.lpeg.S

module(...)

-- Whitespace.
local ws = token(l.WHITESPACE, l.space^1)

-- Comments.
local line_comment = '#' * l.nonnewline_esc^0
local block_comment = '/*' * (l.any - '*/')^0 * P('*/')^-1
local comment = token(l.COMMENT, line_comment + block_comment)

-- Strings.
local sq_str = l.delimited_range("'", '\\', true, false, '\n')
local dq_str = l.delimited_range('"', '\\', true, false, '\n')
local triple_dq_str = '"""' * (l.any - '"""')^0 * P('"""')^-1
local regex = l.delimited_range('/', '\\', false, false, '\n')
local string = token(l.STRING, triple_dq_str + sq_str + dq_str + regex)

-- Numbers.
local number = token(l.NUMBER, (l.float + l.integer) *
                     (S('msdhsfFlL') + 'ms')^-1)

-- Keywords.
local keyword = token(l.KEYWORD, word_match {
  'and', 'break', 'cast', 'continue', 'elif', 'else', 'ensure', 'except', 'for',
  'given', 'goto', 'if', 'in', 'isa', 'is', 'not', 'or', 'otherwise', 'pass',
  'raise', 'ref', 'try', 'unless', 'when', 'while',
  -- Definitions.
  'abstract', 'callable', 'class', 'constructor', 'def', 'destructor', 'do',
  'enum', 'event', 'final', 'get', 'interface', 'internal', 'of', 'override',
  'partial', 'private', 'protected', 'public', 'return', 'set', 'static',
  'struct', 'transient', 'virtual', 'yield',
  -- Namespaces.
  'as', 'from', 'import', 'namespace',
  -- Other.
  'self', 'super', 'null', 'true', 'false'
})

-- Types.
local type = token(l.TYPE, word_match {
  'bool', 'byte', 'char', 'date', 'decimal', 'double', 'duck', 'float', 'int',
  'long', 'object', 'operator', 'regex', 'sbyte', 'short', 'single', 'string',
  'timespan', 'uint', 'ulong', 'ushort'
})

-- Functions.
local func = token(l.FUNCTION, word_match {
  'array', 'assert', 'checked', 'enumerate', '__eval__', 'filter', 'getter',
  'len', 'lock', 'map', 'matrix', 'max', 'min', 'normalArrayIndexing', 'print',
  'property', 'range', 'rawArrayIndexing', 'required', '__switch__', 'typeof',
  'unchecked', 'using', 'yieldAll', 'zip'
})

-- Identifiers.
local identifier = token(l.IDENTIFIER, l.word)

-- Operators.
local operator = token(l.OPERATOR, S('!%^&*()[]{}-=+/|:;.,?<>~`'))

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
