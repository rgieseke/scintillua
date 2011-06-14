-- Copyright 2006-2011 Robert Gieseke. See LICENSE.
-- Lilypond LPeg lexer.
-- TODO Embed Scheme; Notes?, Numbers?

local l = lexer
local token, style, color, word_match = l.token, l.style, l.color, l.word_match
local P, R, S = l.lpeg.P, l.lpeg.R, l.lpeg.S

module(...)

-- Whitespace.
local ws = token(l.WHITESPACE, l.space^1)

-- Comments.
local line_comment = '%' * l.nonnewline^0
-- TODO: block comment.
local comment = token(l.COMMENT, line_comment)

-- Strings.
local string = token(l.STRING, l.delimited_range('"'))

-- Keywords, commands.
local keyword = token(l.KEYWORD, '\\' * l.word)

-- Identifiers.
local identifier = token(l.IDENTIFIER, l.word)

-- Operators.
local operator = token(l.OPERATOR, S("{}'~<>|"))

_rules = {
  { 'whitespace', ws },
  { 'comment', comment },
  { 'string', string },
  { 'keyword', keyword },
  { 'operator', operator },
  { 'identifier', identifier},
  { 'any_char', l.any_char },
}
