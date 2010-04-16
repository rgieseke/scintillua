-- Copyright 2006-2010 Mitchell Foral mitchell<att>caladbolg.net. See LICENSE.
-- Scheme LPeg lexer

local l = lexer
local token, style, color, word_match = l.token, l.style, l.color, l.word_match
local P, R, S = l.lpeg.P, l.lpeg.R, l.lpeg.S

module(...)

local ws = token('whitespace', l.space^1)

local word = l.alpha * (l.alnum + S('_-!?'))^0

-- comments
local line_comment = ';' * l.nonnewline^0
local block_comment = '#|' * (l.any - '|#')^0 * '|#'
local comment = token('comment', line_comment + block_comment)

-- strings
local literal = (P("'") + '#' * S('\\bdox')) * l.word
local dq_str = l.delimited_range('"', '\\', true)
local string = token('string', literal + dq_str)

-- numbers
local number = token('number', P('-')^-1 * l.digit^1 * (S('./') * l.digit^1)^-1)

-- keywords
local keyword = token('keyword', word_match({
  'and', 'begin', 'case', 'cond', 'cond-expand', 'define', 'define-macro',
  'delay', 'do', 'else', 'fluid-let', 'if', 'lambda', 'let', 'let*', 'letrec',
  'or', 'quasiquote', 'quote', 'set!',
}, '-*!'))

-- functions
local func = token('function', word_match({
  'abs', 'acos', 'angle', 'append', 'apply', 'asin', 'assoc', 'assq', 'assv',
  'atan', 'car', 'cdr', 'caar', 'cadr', 'cdar', 'cddr', 'caaar', 'caadr',
  'cadar', 'caddr', 'cdaar', 'cdadr', 'cddar', 'cdddr',
  'call-with-current-continuation', 'call-with-input-file',
  'call-with-output-file', 'call-with-values', 'call/cc', 'catch', 'ceiling',
  'char->integer', 'char-downcase', 'char-upcase', 'close-input-port',
  'close-output-port', 'cons', 'cos', 'current-input-port',
  'current-output-port', 'delete-file', 'display', 'dynamic-wind', 'eval',
  'exit', 'exact->inexact', 'exp', 'expt', 'file-or-directory-modify-seconds',
  'floor', 'force', 'for-each', 'gcd', 'gensym', 'get-output-string', 'getenv',
  'imag-part', 'integer->char', 'lcm', 'length', 'list', 'list->string',
  'list->vector', 'list-ref', 'list-tail', 'load', 'log', 'magnitude',
  'make-polar', 'make-rectangular', 'make-string', 'make-vector', 'map', 'max',
  'member', 'memq', 'memv', 'min', 'modulo', 'newline', 'nil', 'not',
  'number->string', 'open-input-file', 'open-input-string', 'open-output-file',
  'open-output-string', 'peek-char', 'quotient', 'read', 'read-char',
  'read-line', 'real-part', 'remainder', 'reverse', 'reverse!', 'round',
  'set-car!', 'set-cdr!', 'sin', 'sqrt', 'string', 'string->list',
  'string->number', 'string->symbol', 'string-append', 'string-copy',
  'string-fill!', 'string-length', 'string-ref', 'string-set!', 'substring',
  'symbol->string', 'system', 'tan', 'truncate', 'values', 'vector',
  'vector->list', 'vector-fill!', 'vector-length', 'vector-ref', 'vector-set!',
  'with-input-from-file', 'with-output-to-file', 'write', 'write-char',
  'boolean?', 'char-alphabetic?', 'char-ci<=?', 'char-ci<?', 'char-ci=?',
  'char-ci>=?', 'char-ci>?', 'char-lower-case?', 'char-numeric?', 'char-ready?',
  'char-upper-case?', 'char-whitespace?', 'char<=?', 'char<?', 'char=?',
  'char>=?', 'char>?', 'char?', 'complex?', 'eof-object?', 'eq?', 'equal?',
  'eqv?', 'even?', 'exact?', 'file-exists?', 'inexact?', 'input-port?',
  'integer?', 'list?', 'negative?', 'null?', 'number?', 'odd?', 'output-port?',
  'pair?', 'port?', 'positive?', 'procedure?', 'rational?', 'real?',
  'string-ci<=?', 'string-ci<?', 'string-ci=?', 'string-ci>=?', 'string-ci>?',
  'string<=?', 'string<?', 'string=?', 'string>=?', 'string>?', 'string?',
  'symbol?', 'vector?', 'zero?',
  '#t', '#f'
}, '-/<>!?=#'))

-- identifiers
local word = (l.alpha + S('-!?')) * (l.alnum + S('-!?'))^0
local identifier = token('identifier', word)

-- operators
local operator = token('operator', S('<>=*/+-`@%:()'))

-- entity
local entity = token('entity', '&' * word)

_rules = {
  { 'whitespace', ws },
  { 'keyword', keyword },
  { 'identifier', identifier },
  { 'string', string },
  { 'comment', comment },
  { 'number', number },
  { 'operator', operator },
  { 'entity', entity },
  { 'any_char', l.any_char },
}

_tokenstyles = {
  { 'entity', l.style_variable },
}
