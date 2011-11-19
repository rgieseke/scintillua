-- Copyright 2006-2011 Mitchell mitchell<att>caladbolg.net. See LICENSE.
-- APDL LPeg lexer.

local l = lexer
local token, style, color, word_match = l.token, l.style, l.color, l.word_match
local P, R, S = l.lpeg.P, l.lpeg.R, l.lpeg.S

module(...)

-- Whitespace.
local ws = token(l.WHITESPACE, l.space^1)

-- Comments.
local comment = token(l.COMMENT, '!' * l.nonnewline^0)

-- Strings.
local string = token(l.STRING, l.delimited_range("'", nil, true, false, '\n'))

-- Numbers.
local number = token(l.NUMBER, l.float + l.integer)

-- Keywords.
local keyword = token(l.KEYWORD, word_match({
  '*abbr', '*abb', '*afun', '*afu', '*ask', '*cfclos', '*cfc', '*cfopen',
  '*cfo', '*cfwrite', '*cfw', '*create', '*cre', '*cycle', '*cyc', '*del',
  '*dim', '*do', '*elseif', '*else', '*enddo', '*endif', '*end', '*eval',
  '*eva', '*exit', '*exi', '*get', '*go', '*if', '*list', '*lis', '*mfouri',
  '*mfo', '*mfun', '*mfu', '*mooney', '*moo', '*moper', '*mop', '*msg',
  '*repeat', '*rep', '*set', '*status', '*sta', '*tread', '*tre', '*ulib',
  '*uli', '*use', '*vabs', '*vab', '*vcol', '*vco', '*vcum', '*vcu', '*vedit',
  '*ved', '*vfact', '*vfa', '*vfill', '*vfi', '*vfun', '*vfu', '*vget', '*vge',
  '*vitrp', '*vit', '*vlen', '*vle', '*vmask', '*vma', '*voper', '*vop',
  '*vplot', '*vpl', '*vput', '*vpu', '*vread', '*vre', '*vscfun', '*vsc',
  '*vstat', '*vst', '*vwrite', '*vwr', '/anfile', '/anf', '/angle', '/ang',
  '/annot', '/ann', '/anum', '/anu', '/assign', '/ass', '/auto', '/aut',
  '/aux15', '/aux2', '/aux', '/axlab', '/axl', '/batch', '/bat', '/clabel',
  '/cla', '/clear', '/cle', '/clog', '/clo', '/cmap', '/cma', '/color', '/col',
  '/com', '/config', '/contour', '/con', '/copy', '/cop', '/cplane', '/cpl',
  '/ctype', '/cty', '/cval', '/cva', '/delete', '/del', '/devdisp', '/device',
  '/dev', '/dist', '/dis', '/dscale', '/dsc', '/dv3d', '/dv3', '/edge', '/edg',
  '/efacet', '/efa', '/eof', '/erase', '/era', '/eshape', '/esh', '/exit',
  '/exi', '/expand', '/exp', '/facet', '/fac', '/fdele', '/fde', '/filname',
  '/fil', '/focus', '/foc', '/format', '/for', '/ftype', '/fty', '/gcmd',
  '/gcm', '/gcolumn', '/gco', '/gfile', '/gfi', '/gformat', '/gfo', '/gline',
  '/gli', '/gmarker', '/gma', '/golist', '/gol', '/gopr', '/gop', '/go',
  '/graphics', '/gra', '/gresume', '/gre', '/grid', '/gri', '/gropt', '/gro',
  '/grtyp', '/grt', '/gsave', '/gsa', '/gst', '/gthk', '/gth', '/gtype', '/gty',
  '/header', '/hea', '/input', '/inp', '/larc', '/lar', '/light', '/lig',
  '/line', '/lin', '/lspec', '/lsp', '/lsymbol', '/lsy', '/menu', '/men',
  '/mplib', '/mpl', '/mrep', '/mre', '/mstart', '/mst', '/nerr', '/ner',
  '/noerase', '/noe', '/nolist', '/nol', '/nopr', '/nop', '/normal', '/nor',
  '/number', '/num', '/opt', '/output', '/out', '/page', '/pag', '/pbc', '/pbf',
  '/pcircle', '/pci', '/pcopy', '/pco', '/plopts', '/plo', '/pmacro', '/pma',
  '/pmeth', '/pme', '/pmore', '/pmo', '/pnum', '/pnu', '/polygon', '/pol',
  '/post26', '/post1', '/pos', '/prep7', '/pre', '/psearch', '/pse', '/psf',
  '/pspec', '/psp', '/pstatus', '/pst', '/psymb', '/psy', '/pwedge', '/pwe',
  '/quit', '/qui', '/ratio', '/rat', '/rename', '/ren', '/replot', '/rep',
  '/reset', '/res', '/rgb', '/runst', '/run', '/seclib', '/sec', '/seg',
  '/shade', '/sha', '/showdisp', '/show', '/sho', '/shrink', '/shr', '/solu',
  '/sol', '/sscale', '/ssc', '/status', '/sta', '/stitle', '/sti', '/syp',
  '/sys', '/title', '/tit', '/tlabel', '/tla', '/triad', '/tri', '/trlcy',
  '/trl', '/tspec', '/tsp', '/type', '/typ', '/ucmd', '/ucm', '/uis', '/ui',
  '/units', '/uni', '/user', '/use', '/vcone', '/vco', '/view', '/vie',
  '/vscale', '/vsc', '/vup', '/wait', '/wai', '/window', '/win', '/xrange',
  '/xra', '/yrange', '/yra', '/zoom', '/zoo'
}, '*/', true))

-- Identifiers.
local identifier = token(l.IDENTIFIER, l.word)

-- Functions.
local func = token(l.FUNCTION, l.delimited_range('%', nil, false, false, '\n'))

-- Operators.
local operator = token(l.OPERATOR, S('+-*/$=,;()'))

-- Labels.
local label = token(l.LABEL, #P(':') * l.starts_line(':' * l.word))

_rules = {
  { 'whitespace', ws },
  { 'keyword', keyword },
  { 'identifier', identifier },
  { 'string', string },
  { 'number', number },
  { 'function', func },
  { 'label', label },
  { 'comment', comment },
  { 'operator', operator },
  { 'any_char', l.any_char },
}

_foldsymbols = {
  _patterns = { '%*[A-Za-z]+', '!' },
  [l.KEYWORD] = {
    ['*if'] = 1, ['*IF'] = 1, ['*do'] = 1, ['*DO'] = 1, ['*dowhile'] = 1,
    ['*DOWHILE'] = 1,
    ['*endif'] = -1, ['*ENDIF'] = -1, ['*enddo'] = -1, ['*ENDDO'] = -1
  },
  [l.COMMENT] = { ['!'] = l.fold_line_comments('!') }
}
