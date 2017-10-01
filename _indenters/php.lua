--[[PHP rules]]
phprules = {}
phprules['if']={beginstyle = {[SCE_HPHP_WORD]=true}, -- SCITE styles that are acceptable at the beginning of the pattern
  indent = 1, -- how much it indents
  unindent = {['else'] = 1}} -- which patterns does this end
--[[ 'elseif' can be parsed the same way as 'else if', but we have to put
unindent = {['else'] = 1} in phprules['if'] to avoid double indentation ]]
phprules['else']={beginstyle = {[SCE_HPHP_WORD]=true},
  indent = 1,
  unindent = {}}
phprules['while']={beginstyle = {[SCE_HPHP_WORD]=true},
  indent = 1,
  unindent = {['do'] = 1}}
phprules['do']={beginstyle = {[SCE_HPHP_WORD]=true},
  indent = 1,
  unindent = {}}
phprules['for']={beginstyle = {[SCE_HPHP_WORD]=true},
  indent = cstyle_for_indent,
  unindent = {}}
--[[ TODO if 'foreach' gets inserted later in phprules than 'for', it will
be checked later in the script, therefore it will overwrite the match result of 'for'.
That is fine, since we don't want to handle a 'for' where a 'foreach' appears in the source,
but I don't know whether we can trust in this behaviour, or we should do something more
to assure this order of 'for' and 'foreach' ]]
phprules['foreach']={beginstyle = {[SCE_HPHP_WORD]=true},
  indent = 1,
  unindent = {}}
phprules['declare']={beginstyle = {[SCE_HPHP_WORD]=true},
  indent = 1,
  unindent = {}}
phprules['case']={beginstyle = {[SCE_HPHP_WORD]=true},
  indent = 1,
  unindent = {['case'] = 1, ['default'] = 1}}
phprules['default']={beginstyle = {[SCE_HPHP_WORD]=true},
  indent = 1,
  unindent = {['case'] = 1, ['default'] = 1}}
phprules['{']={beginstyle = {[SCE_HPHP_OPERATOR]=true},
  indent = 1,
  unindent = {['if'] = 1, ['else'] = 1, ['while'] = 1,
    ['do'] = 1, ['for'] = cstyle_ob_for_unindent, ['foreach'] = 1, ['declare'] = 1}}
phprules['}']={beginstyle = {[SCE_HPHP_OPERATOR]=true},
  indent = 0,
  unindent = {['{'] = 1, ['case'] = 0, ['default'] = 0}}
phprules[';']={beginstyle = {[SCE_HPHP_OPERATOR]=true},
  indent = 0,
  unindent = {['if'] = 0, ['else'] = 0, ['while'] = 0,
    ['for'] = cstyle_sc_for_unindent, ['foreach'] = 0, ['declare'] = 0}}
phprules['%(']={beginstyle = {[SCE_HPHP_OPERATOR]=true},
  indent = 1,
  unindent = {['%('] = 1}}
phprules['%)']={beginstyle = {[SCE_HPHP_OPERATOR]=true},
  indent = 0,
  unindent = {['%('] = 1}}

t_langrules['php'] = phprules
indent_init('php')
context['php'].forstack = {}
