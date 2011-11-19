-- Copyright 2006-2011 Mitchell mitchell<att>caladbolg.net. See LICENSE.
-- Pike LPeg lexer.

local l = lexer
local token, style, color, word_match = l.token, l.style, l.color, l.word_match
local P, R, S = l.lpeg.P, l.lpeg.R, l.lpeg.S

module(...)

-- Whitespace.
local ws = token(l.WHITESPACE, l.space^1)

-- Comments.
local line_comment = '//' * l.nonnewline_esc^0
local nested_comment = l.nested_pair('/*', '*/', true)
local comment = token(l.COMMENT, line_comment + nested_comment)

-- Strings.
local sq_str = l.delimited_range("'", '\\', true, false, '\n')
local dq_str = l.delimited_range('"', '\\', true, false, '\n')
local lit_str = '#' * l.delimited_range('"', '\\', true)
local string = token(l.STRING, sq_str + dq_str + lit_str)

-- Numbers.
local number = token(l.NUMBER, (l.float + l.integer) * S('lLdDfF')^-1)

-- Preprocessors.
local preproc = token(l.PREPROCESSOR,
                      #P('#') * l.starts_line('#' * l.nonnewline^0))

-- Keywords.
local keyword = token(l.KEYWORD, word_match {
  'break', 'case', 'catch', 'continue', 'default', 'do', 'else', 'for',
  'foreach', 'gauge', 'if', 'lambda', 'return', 'sscanf', 'switch', 'while',
  'import', 'inherit',
  -- Type modifiers.
  'constant', 'extern', 'final', 'inline', 'local', 'nomask', 'optional',
  'private', 'protected', 'public', 'static', 'variant'
})

-- Types.
local type = token(l.TYPE, word_match {
  'array', 'class', 'float', 'function', 'int', 'mapping', 'mixed', 'multiset',
  'object', 'program', 'string', 'void'
})

-- Identifiers.
local identifier = token(l.IDENTIFIER, l.word)

-- Operators.
local operator = token(l.OPERATOR, S('<>=!+-/*%&|^~@`.,:;()[]{}'))

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

_foldsymbols = {
  _patterns = { '[{}]', '/%*', '%*/', '//' },
  [l.OPERATOR] = { ['{'] = 1, ['}'] = -1 },
  [l.COMMENT] = { ['/*'] = 1, ['*/'] = -1, ['//'] = l.fold_line_comments('//') }
}
