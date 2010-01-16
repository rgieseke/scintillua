-- Copyright 2006-2010 Mitchell Foral mitchell<att>caladbolg.net. See LICENSE.
-- Shell LPeg lexer

module(..., package.seeall)
local P, R, S = lpeg.P, lpeg.R, lpeg.S

local ws = token('whitespace', space^1)

-- comments
local comment = token('comment', '#' * nonnewline^0)

-- strings
local sq_str = delimited_range("'", nil, true)
local dq_str = delimited_range('"', '\\', true)
local ex_str = delimited_range('`', '\\', true)
local heredoc = '<<' * P(function(input, index)
  local s, e, _, delimiter = input:find('(["\']?)([%a_][%w_]*)%1[\n\r\f;]+', index)
  if s == index and delimiter then
    local _, e = input:find('[\n\r\f]+'..delimiter, e)
    return e and e + 1 or #input + 1
  end
end)
local string = token('string', sq_str + dq_str + ex_str + heredoc)

-- numbers
local number = token('number', float + integer)

-- keywords
local keyword = token('keyword', word_match(word_list{
  'if', 'then', 'elif', 'else', 'fi', 'case', 'in', 'esac', 'while', 'for',
  'do', 'done', 'continue', 'local', 'return',
  -- operators
  '-a', '-b', '-c', '-d', '-e', '-f', '-g', '-h', '-k', '-p', '-r', '-s', '-t',
  '-u', '-w', '-x', '-O', '-G', '-L', '-S', '-N', '-nt', '-ot', '-ef', '-o',
  '-z', '-n', '-eq', '-ne', '-lt', '-le', '-gt', '-ge'
}, '-'))

-- identifiers
local identifier = token('identifier', word)

-- variables
local variable = token('variable', '$' * (S('!#?*@$') +
  delimited_range('()', nil, true, false, '\n') +
  delimited_range('[]', nil, true, false, '\n') +
  delimited_range('{}', nil, true, false, '\n') +
  delimited_range('`', nil, true, false, '\n') +
  digit^1 +
  word))

-- operators
local operator = token('operator', S('=!<>+-/*^~.,:;?()[]{}'))

function LoadTokens()
  local shell = bash
  add_token(shell, 'whitespace', ws)
  add_token(shell, 'keyword', keyword)
  add_token(shell, 'identifier', identifier)
  add_token(shell, 'string', string)
  add_token(shell, 'comment', comment)
  add_token(shell, 'number', number)
  add_token(shell, 'variable', variable)
  add_token(shell, 'operator', operator)
  add_token(shell, 'any_char', any_char)
end
