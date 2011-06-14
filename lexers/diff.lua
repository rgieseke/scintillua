-- Copyright 2006-2011 Mitchell mitchell<att>caladbolg.net. See LICENSE.
-- Diff LPeg lexer.

local l = lexer
local token, style, color, word_match = l.token, l.style, l.color, l.word_match
local P, R, S = l.lpeg.P, l.lpeg.R, l.lpeg.S

module(...)

-- Text, separators, and file headers.
local index = token(l.COMMENT, 'Index: ' * l.any^0 * P(-1))
local separator = token(l.COMMENT, ('---' + P('*')^4 + P('=')^1) * l.space^0 *
                        P(-1))
local header = token('header', (P('*** ') + '--- ' + '+++ ') * l.any^1 * P(-1))

-- Location.
local location = token(l.NUMBER, ('@@' + l.digit^1 + '****') * l.any^1 * P(-1))

-- Additions, deletions, and changes.
local addition = token('addition', S('>+') * l.any^0 * P(-1))
local deletion = token('deletion', S('<-') * l.any^0 * P(-1))
local change   = token('change', '! ' * l.any^0 * P(-1))

_rules = {
  { 'index', index },
  { 'separator', separator },
  { 'header', header },
  { 'location', location },
  { 'addition', addition },
  { 'deletion', deletion },
  { 'change', change },
  { 'any_line', token('default', l.any^1) },
}

_tokenstyles = {
  { 'header', l.style_nothing..{ bold = true } },
  { 'addition', l.style_nothing..{ fore = l.colors.green } },
  { 'deletion', l.style_nothing..{ fore = l.colors.red } },
  { 'change', l.style_nothing..{ fore = l.colors.yellow } },
}

_LEXBYLINE = true
