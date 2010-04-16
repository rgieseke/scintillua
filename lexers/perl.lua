-- Copyright 2006-2010 Mitchell Foral mitchell<att>caladbolg.net. See LICENSE.
-- Perl LPeg lexer

local l = lexer
local token, style, color, word_match = l.token, l.style, l.color, l.word_match
local P, R, S, V = l.lpeg.P, l.lpeg.R, l.lpeg.S, l.lpeg.V

module(...)

local ws = token('whitespace', l.space^1)

-- comments
local line_comment = '#' * l.nonnewline_esc^0
local block_comment = #P('=') *
  l.starts_line('=' * l.alpha * (l.any - l.newline * '=cut')^0 * (l.newline * '=cut')^-1)
local comment = token('comment', block_comment + line_comment)

local delimiter_matches = { ['('] = ')', ['['] = ']', ['{'] = '}', ['<'] = '>' }
local literal_delimitted = P(function(input, index) -- for single delimiter sets
  local delimiter = input:sub(index, index)
  if not delimiter:find('%w') then -- only non alpha-numerics
    local match_pos, patt
    if delimiter_matches[delimiter] then -- handle nested delimiter/matches in strings
      local s, e = delimiter, delimiter_matches[delimiter]
      patt = l.delimited_range(s..e, '\\', true, true)
    else
      patt = l.delimited_range(delimiter, '\\', true)
    end
    match_pos = l.lpeg.match(patt, input, index)
    return match_pos or #input + 1
  end
end)
local literal_delimitted2 = P(function(input, index) -- for 2 delimiter sets
  local delimiter = input:sub(index, index)
  if not delimiter:find('%w') then -- only non alpha-numerics
    local match_pos, patt
    if delimiter_matches[delimiter] then -- handle nested delimiter/matches in strings
      local s, e = delimiter, delimiter_matches[delimiter]
      patt = l.delimited_range(s..e, '\\', true, true)
    else
      patt = l.delimited_range(delimiter, '\\', true)
    end
    first_match_pos = l.lpeg.match(patt, input, index)
    final_match_pos = l.lpeg.match(patt, input, first_match_pos - 1)
    if not final_match_pos then -- using (), [], {}, or <> notation
      final_match_pos = l.lpeg.match(l.space^0 * patt, input, first_match_pos)
    end
    return final_match_pos or #input + 1
  end
end)

-- strings
local sq_str = l.delimited_range("'", '\\', true)
local dq_str = l.delimited_range('"', '\\', true)
local cmd_str = l.delimited_range('`', '\\', true)
local regex = l.delimited_range('/', '\\', false, true, '\n') * S('imosx')^0
local heredoc = '<<' * P(function(input, index)
  local s, e, delimiter = input:find('([%a_][%w_]*)[\n\r\f;]+', index)
  if s == index and delimiter then
    local end_heredoc = '[\n\r\f]+'
    local _, e = input:find(end_heredoc..delimiter, e)
    return e and e + 1 or #input + 1
  end
end)
local lit_str = 'q' * P('q')^-1 * literal_delimitted
local lit_array = 'qw' * literal_delimitted
local lit_regex = 'qr' * literal_delimitted * S('imosx')^0
local lit_cmd = 'qx' * literal_delimitted
local lit_match = 'm' * literal_delimitted * S('cgimosx')^0
local lit_sub = 's' * literal_delimitted2 * S('ecgimosx')^0
local lit_tr = (P('tr') + 'y') * literal_delimitted2 * S('cds')^0
local string = token('string', sq_str + dq_str + cmd_str + regex + heredoc +
  lit_str + lit_array + lit_regex + lit_cmd + lit_match + lit_sub + lit_tr)

-- numbers
local number = token('number', l.float + l.integer)

-- keywords
local keyword = token('keyword', word_match {
  'STDIN', 'STDOUT', 'STDERR', 'BEGIN', 'END', 'CHECK', 'INIT',
  'require', 'use',
  'break', 'continue', 'do', 'each', 'else', 'elsif', 'foreach', 'for', 'if',
  'last', 'local', 'my', 'next', 'our', 'package', 'return', 'sub', 'unless',
  'until', 'while', '__FILE__', '__LINE__', '__PACKAGE__',
  'and', 'or', 'not', 'eq', 'ne', 'lt', 'gt', 'le', 'ge'
})

-- functions
local func = token('function', word_match({
  'abs', 'accept', 'alarm', 'atan2', 'bind', 'binmode', 'bless', 'caller',
  'chdir', 'chmod', 'chomp', 'chop', 'chown', 'chr', 'chroot', 'closedir',
  'close', 'connect', 'cos', 'crypt', 'dbmclose', 'dbmopen', 'defined',
  'delete', 'die', 'dump', 'each', 'endgrent', 'endhostent', 'endnetent',
  'endprotoent', 'endpwent', 'endservent', 'eof', 'eval', 'exec', 'exists',
  'exit', 'exp', 'fcntl', 'fileno', 'flock', 'fork', 'format', 'formline',
  'getc', 'getgrent', 'getgrgid', 'getgrnam', 'gethostbyaddr', 'gethostbyname',
  'gethostent', 'getlogin', 'getnetbyaddr', 'getnetbyname', 'getnetent',
  'getpeername', 'getpgrp', 'getppid', 'getpriority', 'getprotobyname',
  'getprotobynumber', 'getprotoent', 'getpwent', 'getpwnam', 'getpwuid',
  'getservbyname', 'getservbyport', 'getservent', 'getsockname', 'getsockopt',
  'glob', 'gmtime', 'goto', 'grep', 'hex', 'import', 'index', 'int', 'ioctl',
  'join', 'keys', 'kill', 'lcfirst', 'lc', 'length', 'link', 'listen',
  'localtime', 'log', 'lstat', 'map', 'mkdir', 'msgctl', 'msgget', 'msgrcv',
  'msgsnd', 'new', 'oct', 'opendir', 'open', 'ord', 'pack', 'pipe', 'pop',
  'pos', 'printf', 'print', 'prototype', 'push', 'quotemeta', 'rand', 'readdir',
  'read', 'readlink', 'recv', 'redo', 'ref', 'rename', 'reset', 'reverse',
  'rewinddir', 'rindex', 'rmdir', 'scalar', 'seekdir', 'seek', 'select',
  'semctl', 'semget', 'semop', 'send', 'setgrent', 'sethostent', 'setnetent',
  'setpgrp', 'setpriority', 'setprotoent', 'setpwent', 'setservent',
  'setsockopt', 'shift', 'shmctl', 'shmget', 'shmread', 'shmwrite', 'shutdown',
  'sin', 'sleep', 'socket', 'socketpair', 'sort', 'splice', 'split', 'sprintf',
  'sqrt', 'srand', 'stat', 'study', 'substr', 'symlink', 'syscall', 'sysread',
  'sysseek', 'system', 'syswrite', 'telldir', 'tell', 'tied', 'tie', 'time',
  'times', 'truncate', 'ucfirst', 'uc', 'umask', 'undef', 'unlink', 'unpack',
  'unshift', 'untie', 'utime', 'values', 'vec', 'wait', 'waitpid', 'wantarray',
  'warn', 'write'
}, '2'))

-- identifiers
local identifier = token('identifier', l.word)

-- variables
local special_var = '$' * ('^' * S('ADEFHILMOPSTWX')^-1 +
  S('\\"[]\'&`+*.,;=%~?@$<>(|/!-') + ':' * (l.any - ':') + l.digit^1)
local plain_var = ('$#' + S('$@%')) * P('$')^0 * l.word
local variable = token('variable', special_var + plain_var)

-- operators
local operator = token('operator', S('-<>+*!~\\=/%&|^&.?:;()[]{}'))

_rules = {
  { 'whitespace', ws },
  { 'keyword', keyword },
  { 'function', func },
  { 'string', string },
  { 'identifier', identifier },
  { 'comment', comment },
  { 'number', number },
  { 'variable', variable },
  { 'operator', operator },
  { 'any_char', l.any_char },
}
