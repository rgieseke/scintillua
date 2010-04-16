-- Copyright 2006-2010 Mitchell Foral mitchell<att>caladbolg.net. See LICENSE.
-- Lua LPeg lexer

-- Original written by Peter Odding, 2007/04/04

local l = lexer
local token, style, color, word_match = l.token, l.style, l.color, l.word_match
local P, R, S = l.lpeg.P, l.lpeg.R, l.lpeg.S

module(...)

local ws = token('whitespace', l.space^1)

local longstring = #('[[' + ('[' * P('=')^0 * '['))
local longstring = longstring * P(function(input, index)
  local level = input:match('^%[(=*)%[', index)
  if level then
    local _, stop = input:find(']'..level..']', index, true)
    return stop and stop + 1 or #input + 1
  end
end)

-- comments
local line_comment = '--' * l.nonnewline^0
local block_comment = '--' * longstring
local comment = token('comment', block_comment + line_comment)

-- strings
local sq_str = l.delimited_range("'", '\\', true)
local dq_str = l.delimited_range('"', '\\', true)
local string = token('string', sq_str + dq_str + longstring)

-- numbers
local lua_integer = P('-')^-1 * (l.hex_num + l.dec_num)
local number = token('number', l.float + lua_integer)

-- keywords
local keyword = token('keyword', word_match {
  'and', 'break', 'do', 'else', 'elseif', 'end', 'false', 'for',
  'function', 'if', 'in', 'local', 'nil', 'not', 'or', 'repeat',
  'return', 'then', 'true', 'until', 'while'
})

-- functions
local func = token('function', word_match {
  'assert', 'collectgarbage', 'dofile', 'error', 'getfenv', 'getmetatable',
  'gcinfo', 'ipairs', 'loadfile', 'loadlib', 'loadstring', 'next', 'pairs',
  'pcall', 'print', 'rawequal', 'rawget', 'rawset', 'require', 'setfenv',
  'setmetatable', 'tonumber', 'tostring', 'type', 'unpack', 'xpcall'
})

-- constants
local constant = token('constant', word_match {
  '_G', '_VERSION', 'LUA_PATH', '_LOADED', '_REQUIREDNAME', '_ALERT',
  '_ERRORMESSAGE', '_PROMPT'
})

-- identifiers
local word = (R('AZ', 'az', '\127\255') + '_') * (l.alnum + '_')^0
local identifier = token('identifier', word)

-- operators
local operator = token('operator', '~=' + S('+-*/%^#=<>;:,.{}[]()'))

_rules = {
  { 'whitespace', ws },
  { 'keyword', keyword },
  { 'function', func },
  { 'constant', constant },
  { 'identifier', identifier },
  { 'string', string },
  { 'comment', comment },
  { 'number', number },
  { 'operator', operator },
  { 'any_char', l.any_char },
}
