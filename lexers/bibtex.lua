-- Copyright 2006-2011 Mitchell mitchell<att>caladbolg.net. See LICENSE.
-- Bibtex LPeg lexer.

local l = lexer
local token, style, color, word_match = l.token, l.style, l.color, l.word_match
local P, R, S = l.lpeg.P, l.lpeg.R, l.lpeg.S

module(...)

-- Whitespace.
local ws = token(l.WHITESPACE, l.space^1)

-- Strings.
local string = token(l.STRING, l.delimited_range('"', '\\', true) +
                               l.delimited_range('{}', nil, true, true))

-- Fields.
local field = token('field', word_match {
  'author', 'title', 'journal', 'year', 'volume', 'number', 'pages', 'month',
  'note', 'key', 'publisher', 'editor', 'series', 'address', 'edition',
  'howpublished', 'booktitle', 'organization', 'chapter', 'school',
  'institution', 'type', 'isbn', 'issn', 'affiliation', 'issue', 'keyword',
  'url'
})

-- Identifiers.
local identifier = token(l.IDENTIFIER, l.word)

-- Operators.
local operator = token(l.OPERATOR, S(',='))

_rules = {
  { 'whitespace', ws },
  { 'field', field },
  { 'identifier', identifier },
  { 'string', string },
  { 'operator', operator },
  { 'any_char', l.any_char }
}

-- Embedded in Latex.
local latex = l.load('latex')
_lexer = latex

-- Embedded Bibtex.
local entry = token('entry', P('@') * word_match({
  'book', 'article', 'booklet', 'conference', 'inbook', 'incollection',
  'inproceedings', 'manual', 'mastersthesis', 'lambda', 'misc', 'phdthesis',
  'proceedings', 'techreport', 'unpublished'
}, nil, true))
local bibtex_start_rule = entry * ws^0 * token(l.OPERATOR, P('{'))
local bibtex_end_rule = token(l.OPERATOR, P('}'))
l.embed_lexer(latex, _M, bibtex_start_rule, bibtex_end_rule)

_tokenstyles = {
  { 'field', l.style_constant },
  { 'entry', l.style_preproc }
}
