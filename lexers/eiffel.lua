-- Copyright 2006-2011 Mitchell mitchell<att>caladbolg.net. See LICENSE.
-- Eiffel LPeg lexer.

local l = lexer
local token, style, color, word_match = l.token, l.style, l.color, l.word_match
local P, R, S = l.lpeg.P, l.lpeg.R, l.lpeg.S

module(...)

-- Whitespace.
local ws = token(l.WHITESPACE, l.space^1)

-- Comments.
local comment = token(l.COMMENT, '--' * l.nonnewline^0)

-- Strings.
local sq_str = l.delimited_range("'", '\\', true, false, '\n')
local dq_str = l.delimited_range('"', '\\', true, false, '\n')
local string = token(l.STRING, sq_str + dq_str)

-- Numbers.
local number = token(l.NUMBER, l.float + l.integer)

-- Keywords.
local keyword = token(l.KEYWORD, word_match {
  'alias', 'all', 'and', 'as', 'check', 'class', 'creation', 'debug',
  'deferred', 'do', 'else', 'elseif', 'end', 'ensure', 'expanded', 'export',
  'external', 'feature', 'from', 'frozen', 'if', 'implies', 'indexing', 'infix',
  'inherit', 'inspect', 'invariant', 'is', 'like', 'local', 'loop', 'not',
  'obsolete', 'old', 'once', 'or', 'prefix', 'redefine', 'rename', 'require',
  'rescue', 'retry', 'select', 'separate', 'then', 'undefine', 'until',
  'variant', 'when', 'xor',
  'current', 'false', 'precursor', 'result', 'strip', 'true', 'unique', 'void'
})

-- Types.
local type = token(l.TYPE, word_match {
  'character', 'string', 'bit', 'boolean', 'integer', 'real', 'none', 'any'
})

-- Identifiers.
local identifier = token(l.IDENTIFIER, l.word)

-- Operators.
local operator = token(l.OPERATOR, S('=!<>+-/*%&|^~.,:;?()[]{}'))

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
  _patterns = { '[a-z]+', '%-%-' },
  [l.KEYWORD] = {
    check = 1, debug = 1, deferred = 1, ['do'] = 1, from = 1, ['if'] = 1,
    inspect = 1, once = 1, class = function(text, pos, line, s)
      return line:find('deferred%s+class') and 0 or 1
    end, ['end'] = -1
  },
  [l.COMMENT] = { ['--'] = l.fold_line_comments('--') }
}
