-- Copyright 2006-2011 Mitchell mitchell<att>caladbolg.net. See LICENSE.
-- ASP LPeg lexer.

local l = lexer
local token, style, color, word_match = l.token, l.style, l.color, l.word_match
local P, R, S = l.lpeg.P, l.lpeg.R, l.lpeg.S

module(...)

-- Embedded in HTML.
local html = l.load('hypertext')
_lexer = html

-- Embedded VB.
local vb = l.load('vb')
local vb_start_rule = token('asp_tag', '<%' * P('=')^-1)
local vb_end_rule = token('asp_tag', '%>')
l.embed_lexer(html, vb, vb_start_rule, vb_end_rule)

-- Embedded VBScript.
local vbs = l.load('vbscript')
local script_element = word_match({ 'script' }, nil, html.case_insensitive_tags)
local vbs_start_rule = #(P('<') * script_element *
  P(function(input, index)
    if input:find('[^>]+language%s*=%s*(["\'])vbscript%1') then return index end
  end)) * html._RULES['tag'] -- <script language="vbscript">
local vbs_end_rule = #('</' * script_element * l.space^0 * '>') *
                     html._RULES['tag'] -- </script>
l.embed_lexer(html, vbs, vbs_start_rule, vbs_end_rule)

_tokenstyles = {
  { 'asp_tag', l.style_embedded },
}

local _foldsymbols = html._foldsymbols
_foldsymbols._patterns[#_foldsymbols._patterns + 1] = '<%%'
_foldsymbols._patterns[#_foldsymbols._patterns + 1] = '%%>'
_foldsymbols.asp_tag = { ['<%'] = 1, ['%>'] = -1 }
