-- Copyright 2006-2011 Mitchell mitchell<att>caladbolg.net. See LICENSE.
-- Fortran LPeg lexer.

local l = lexer
local token, style, color, word_match = l.token, l.style, l.color, l.word_match
local P, R, S = l.lpeg.P, l.lpeg.R, l.lpeg.S

module(...)

-- Whitespace.
local ws = token(l.WHITESPACE, l.space^1)

-- Comments.
local c_comment = #S('Cc') * l.starts_line(S('Cc') * l.nonnewline^0)
local d_comment = #S('Dd') * l.starts_line(S('Dd') * l.nonnewline^0)
local ex_comment = #P('!') * l.starts_line('!' * l.nonnewline^0)
local ast_comment = #P('*') * l.starts_line('*' * l.nonnewline^0)
local line_comment = '!' * l.nonnewline^0
local comment = token(l.COMMENT, c_comment + d_comment + ex_comment +
                      ast_comment + line_comment)

-- Strings.
local sq_str = l.delimited_range("'", nil, true, false, '\n')
local dq_str = l.delimited_range('"', nil, true, false, '\n')
local string = token(l.STRING, sq_str + dq_str)

-- Numbers.
local number = token(l.NUMBER, (l.float + l.integer) * -l.alpha)

-- Keywords.
local keyword = token(l.KEYWORD, word_match({
  'include', 'program', 'module', 'subroutine', 'function', 'contains', 'use',
  'call', 'return',
  -- Statements.
  'case', 'select', 'default', 'continue', 'cycle', 'do', 'while', 'else', 'if',
  'elseif', 'then', 'elsewhere', 'end', 'endif', 'enddo', 'forall', 'where',
  'exit', 'goto', 'pause', 'stop',
  -- Operators.
  '.not.', '.and.', '.or.', '.xor.', '.eqv.', '.neqv.', '.eq.', '.ne.', '.gt.',
  '.ge.', '.lt.', '.le.',
  -- Logical.
  '.false.', '.true.'
}, '.', true))

-- Functions.
local func = token(l.FUNCTION, word_match({
  -- I/O.
  'backspace', 'close', 'endfile', 'inquire', 'open', 'print', 'read', 'rewind',
  'write', 'format',
  -- Type conversion, utility, and math.
  'aimag', 'aint', 'amax0', 'amin0', 'anint', 'ceiling', 'cmplx', 'conjg',
  'dble', 'dcmplx', 'dfloat', 'dim', 'dprod', 'float', 'floor', 'ifix', 'imag',
  'int', 'logical', 'modulo', 'nint', 'real', 'sign', 'sngl', 'transfer',
  'zext', 'abs', 'acos', 'aimag', 'aint', 'alog', 'alog10', 'amax0', 'amax1',
  'amin0', 'amin1', 'amod', 'anint', 'asin', 'atan', 'atan2', 'cabs', 'ccos',
  'char', 'clog', 'cmplx', 'conjg', 'cos', 'cosh', 'csin', 'csqrt', 'dabs',
  'dacos', 'dasin', 'datan', 'datan2', 'dble', 'dcos', 'dcosh', 'ddim', 'dexp',
  'dim', 'dint', 'dlog', 'dlog10', 'dmax1', 'dmin1', 'dmod', 'dnint', 'dprod',
  'dreal', 'dsign', 'dsin', 'dsinh', 'dsqrt', 'dtan', 'dtanh', 'exp', 'float',
  'iabs', 'ichar', 'idim', 'idint', 'idnint', 'ifix', 'index', 'int', 'isign',
  'len', 'lge', 'lgt', 'lle', 'llt', 'log', 'log10', 'max', 'max0', 'max1',
  'min', 'min0', 'min1', 'mod', 'nint', 'real', 'sign', 'sin', 'sinh', 'sngl',
  'sqrt', 'tan', 'tanh'
}, nil, true))

-- Types.
local type = token(l.TYPE, word_match({
  'implicit', 'explicit', 'none', 'data', 'parameter', 'allocate',
  'allocatable', 'allocated', 'deallocate', 'integer', 'real', 'double',
  'precision', 'complex', 'logical', 'character', 'dimension', 'kind',
}, nil, true))

-- Identifiers.
local identifier = token(l.IDENTIFIER, l.alnum^1)

-- Operators.
local operator = token(l.OPERATOR, S('<>=&+-/*,()'))

_rules = {
  { 'whitespace', ws },
  { 'comment', comment },
  { 'keyword', keyword },
  { 'function', func },
  { 'type', type },
  { 'number', number },
  { 'identifier', identifier },
  { 'string', string },
  { 'operator', operator },
  { 'any_char', l.any_char },
}
