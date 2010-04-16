-- Copyright 2006-2010 Mitchell Foral mitchell<att>caladbolg.net. See LICENSE.
-- Rexx LPeg Lexer

local l = lexer
local token, style, color, word_match = l.token, l.style, l.color, l.word_match
local P, R, S = l.lpeg.P, l.lpeg.R, l.lpeg.S

module(...)

local ws = token('whitespace', l.space^1)

-- comments
local line_comment = '--' * l.nonnewline_esc^0
local block_comment = l.nested_pair('/*', '*/', true)
local comment = token('comment', line_comment + block_comment)

-- strings
local sq_str = l.delimited_range("'", '\\', true, false, '\n')
local dq_str = l.delimited_range('"', '\\', true, false, '\n')
local string = token('string', sq_str + dq_str)

-- numbers
local number = token('number', l.float + l.integer)

-- preprocessor
local preproc = token('preprocessor', #P('#') * l.starts_line('#' * l.nonnewline^0))

-- keywords
local keyword = token('keyword', word_match({
  'address', 'arg', 'by', 'call', 'class', 'do', 'drop', 'else', 'end', 'exit',
  'expose', 'forever', 'forward', 'guard', 'if', 'interpret', 'iterate',
  'leave', 'method', 'nop', 'numeric', 'otherwise', 'parse', 'procedure',
  'pull', 'push', 'queue', 'raise', 'reply', 'requires', 'return', 'routine',
  'result', 'rc', 'say', 'select', 'self', 'sigl', 'signal', 'super', 'then',
  'to', 'trace', 'use', 'when', 'while', 'until'
}, nil, true))

-- functions
local func = token('function', word_match({
  'abbrev', 'abs', 'address', 'arg', 'beep', 'bitand', 'bitor', 'bitxor', 'b2x',
  'center', 'changestr', 'charin', 'charout', 'chars', 'compare', 'consition',
  'copies', 'countstr', 'c2d', 'c2x', 'datatype', 'date', 'delstr', 'delword',
  'digits', 'directory', 'd2c', 'd2x', 'errortext', 'filespec', 'form',
  'format', 'fuzz', 'insert', 'lastpos', 'left', 'length', 'linein', 'lineout',
  'lines', 'max', 'min', 'overlay', 'pos', 'queued', 'random', 'reverse',
  'right', 'sign', 'sourceline', 'space', 'stream', 'strip', 'substr',
  'subword', 'symbol', 'time', 'trace', 'translate', 'trunc', 'value', 'var',
  'verify', 'word', 'wordindex', 'wordlength', 'wordpos', 'words', 'xrange',
  'x2b', 'x2c', 'x2d', 'rxfuncadd', 'rxfuncdrop', 'rxfuncquery', 'rxmessagebox',
  'rxwinexec', 'sysaddrexxmacro', 'sysbootdrive', 'sysclearrexxmacrospace',
  'syscloseeventsem', 'sysclosemutexsem', 'syscls', 'syscreateeventsem',
  'syscreatemutexsem', 'syscurpos', 'syscurstate', 'sysdriveinfo',
  'sysdrivemap', 'sysdropfuncs', 'sysdroprexxmacro', 'sysdumpvariables',
  'sysfiledelete', 'sysfilesearch', 'sysfilesystemtype', 'sysfiletree',
  'sysfromunicode', 'systounicode', 'sysgeterrortext', 'sysgetfiledatetime',
  'sysgetkey', 'sysini', 'sysloadfuncs', 'sysloadrexxmacrospace', 'sysmkdir',
  'sysopeneventsem', 'sysopenmutexsem', 'sysposteventsem', 'syspulseeventsem',
  'sysqueryprocess', 'sysqueryrexxmacro', 'sysreleasemutexsem',
  'sysreorderrexxmacro', 'sysrequestmutexsem', 'sysreseteventsem', 'sysrmdir',
  'syssaverexxmacrospace', 'syssearchpath', 'syssetfiledatetime',
  'syssetpriority', 'syssleep', 'sysstemcopy', 'sysstemdelete', 'syssteminsert',
  'sysstemsort', 'sysswitchsession', 'syssystemdirectory', 'systempfilename',
  'systextscreenread', 'systextscreensize', 'sysutilversion', 'sysversion',
  'sysvolumelabel', 'syswaiteventsem', 'syswaitnamedpipe', 'syswindecryptfile',
  'syswinencryptfile', 'syswinver'
}, '2', true))

-- identifiers
local word = l.alpha * (l.alnum + S('@#$\\.!?_')^0)
local identifier = token('identifier', word)

-- operators
local operator = token('operator', S('=!<>+-/\\*%&|^~.,:;(){}'))

_rules = {
  { 'whitespace', ws },
  { 'keyword', keyword },
  { 'function', func },
  { 'identifier', identifier },
  { 'string', string },
  { 'comment', comment },
  { 'number', number },
  { 'preproc', preproc },
  { 'operator', operator },
  { 'any_char', l.any_char },
}
