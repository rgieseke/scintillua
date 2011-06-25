-- Copyright 2006-2011 Mitchell mitchell<att>caladbolg.net. See LICENSE.
-- Io LPeg lexer.

local l = lexer
local token, style, color, word_match = l.token, l.style, l.color, l.word_match
local P, R, S = l.lpeg.P, l.lpeg.R, l.lpeg.S

module(...)

-- Whitespace.
local ws = token(l.WHITESPACE, l.space^1)

-- Comments.
local line_comment = (P('#') + '//') * l.nonnewline^0
local block_comment = '/*' * (l.any - '*/')^0 * P('*/')^-1
local comment = token(l.COMMENT, line_comment + block_comment)

-- Strings.
local sq_str = l.delimited_range("'", '\\', true)
local dq_str = l.delimited_range('"', '\\', true)
local tq_str = '"""' * (l.any - '"""')^0 * P('"""')^-1
local string = token(l.STRING, tq_str + sq_str + dq_str)

-- Numbers.
local number = token(l.NUMBER, l.float + l.integer)

-- Keywords.
local keyword = token(l.KEYWORD, word_match {
  'block', 'method', 'while', 'foreach', 'if', 'else', 'do', 'super', 'self',
  'clone', 'proto', 'setSlot', 'hasSlot', 'type', 'write', 'print', 'forward'
})

-- Types.
local type = token(l.TYPE, word_match {
  'Block', 'Buffer', 'CFunction', 'Date', 'Duration', 'File', 'Future', 'List',
  'LinkedList', 'Map', 'Nop', 'Message', 'Nil', 'Number', 'Object', 'String',
  'WeakLink'
})

-- Identifiers.
local identifier = token(l.IDENTIFIER, l.word)

-- Operators.
local operator = token(l.OPERATOR, S('`~@$%^&*-+/=\\<>?.,:;()[]{}'))

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

_foldsymbols = {
  _patterns = { '[%(%)]', '/%*', '%*/', '#', '//' },
  [l.OPERATOR] = { ['('] = 1, [')'] = -1 },
  [l.COMMENT] = {
    ['/*'] = 1, ['*/'] = -1, ['#'] = l.fold_line_comments('#'),
    ['//'] = l.fold_line_comments('//')
  }
}
