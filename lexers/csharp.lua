-- Copyright 2006-2010 Mitchell Foral mitchell<att>caladbolg.net. See LICENSE.
-- C# LPeg Lexer

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
local ml_str = P('@')^-1 * l.delimited_range('"', nil, true)
local string = token('string', sq_str + dq_str + ml_str)

-- numbers
local number = token('number', (l.float + l.integer) * S('lLdDfFMm')^-1)

-- preprocessor
local preproc_word = word_match {
  'define', 'elif', 'else', 'endif', 'error', 'if', 'line', 'undef', 'warning',
  'region', 'endregion'
}
local preproc = token('preprocessor',
  #P('#') * l.starts_line('#' * S('\t ')^0 * preproc_word *
  (l.nonnewline_esc^1 + l.space * l.nonnewline_esc^0)))

-- keywords
local keyword = token('keyword', word_match {
  'class', 'delegate', 'enum', 'event', 'interface', 'namespace', 'struct',
  'using', 'abstract', 'const', 'explicit', 'extern', 'fixed', 'implicit',
  'internal', 'lock', 'out', 'override', 'params', 'partial', 'private',
  'protected', 'public', 'ref', 'sealed', 'static', 'readonly', 'unsafe',
  'virtual', 'volatile', 'add', 'as', 'assembly', 'base', 'break', 'case',
  'catch', 'checked', 'continue', 'default', 'do', 'else', 'finally', 'for',
  'foreach', 'get', 'goto', 'if', 'in', 'is', 'new', 'remove', 'return', 'set',
  'sizeof', 'stackalloc', 'super', 'switch', 'this', 'throw', 'try', 'typeof',
  'unchecked', 'value', 'void', 'while', 'yield',
  'null', 'true', 'false'
})

-- types
local type = token('type', word_match {
  'bool', 'byte', 'char', 'decimal', 'double', 'float', 'int', 'long', 'object',
  'operator', 'sbyte', 'short', 'string', 'uint', 'ulong', 'ushort'
})

-- identifiers
local identifier = token('identifier', l.word)

-- operators
local operator = token('operator', S('~!.,:;+-*/<>=\\^|&%?()[]{}'))

_rules = {
  { 'whitespace', ws },
  { 'keyword', keyword },
  { 'type', type },
  { 'identifier', identifier },
  { 'string', string },
  { 'comment', comment },
  { 'number', number },
  { 'preproc', preproc },
  { 'operator', operator },
  { 'any_char', l.any_char },
}
