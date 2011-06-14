-- Copyright 2006-2011 Mitchell mitchell<att>caladbolg.net. See LICENSE.
-- Makefile LPeg lexer.

local l = lexer
local token, style, color, word_match = l.token, l.style, l.color, l.word_match
local P, R, S = l.lpeg.P, l.lpeg.R, l.lpeg.S

module(...)

-- Whitespace.
local ws = token(l.WHITESPACE, l.space^1)

local assign = token(l.OPERATOR, P(':')^-1 * '=')
local colon = token(l.OPERATOR, ':') * -P('=')

-- Comments.
local comment = token(l.COMMENT, '#' * l.nonnewline^0)

-- Preprocessor.
local preproc = token(l.PREPROCESSOR, '!' * l.nonnewline^0)

-- Targets.
local target = token('target', (l.any - ':')^1) * colon *
                     (ws * l.nonnewline^0)^-1

-- Commands.
local command = #P('\t') * token('command', l.nonnewline^1)

-- Lines.
local var_char = l.any - l.space - S(':#=')
local identifier = token(l.IDENTIFIER, var_char^1) * ws^0 * assign
local macro = token('macro', '$' * (l.delimited_range('()', nil, nil, true) +
                    S('<@')))
local regular_line = ws + identifier + macro + comment + l.any_char

_rules = {
  { 'comment', comment },
  { 'preprocessor', preproc },
  { 'target', target },
  { 'command', command },
  { 'whitespace', ws },
  { 'line', regular_line },
}

_tokenstyles = {
  { 'target', l.style_definition },
  { 'command', l.style_string },
  { 'identifier', l.style_nothing..{ bold = true } },
  { 'macro', l.style_keyword },
}

_LEXBYLINE = true
