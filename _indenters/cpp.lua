--[[functions to handle C-style for]]
-- functions for handling for (; ;) in which the two semicolons does not unindent the for
function cstyle_for_indent()
  local forstack = c_context.forstack
  forstack[table.getn(forstack) + 1] = 2
  return 1 -- it always increments indentation level
end

function cstyle_sc_for_unindent()
  local forstack = c_context.forstack
  if 0 == table.getn(forstack) then
    -- it's some syntax error
    return nil -- no unindentation
  end
  local i = forstack[table.getn(forstack)]

  if i == 0 then
    -- this semicolon is the third after the 'for'
    forstack[table.getn(forstack)] = nil
    return 0 -- unindentation
  else
    forstack[table.getn(forstack)] = i-1
    return nil -- no unindentation
  end
end

function cstyle_ob_for_unindent()
  local forstack = c_context.forstack
  if 0 == table.getn(forstack) then
    -- it's some syntax error
    return nil -- no unindentation
  end

  forstack[table.getn(forstack)] = nil
  return 1 -- unindentation
end

--[[CPP rules]]
cpprules = {}
cpprules['if']={beginstyle = {[SCE_C_WORD]=true},
  indent = 1,
  unindent = {['else'] = 1}}
cpprules['else']={beginstyle = {[SCE_C_WORD]=true},
  indent = 1,
  unindent = {}}
cpprules['while']={beginstyle = {[SCE_C_WORD]=true},
  indent = 1,
  unindent = {['do%A'] = 1}}
-- 'do%A' to avoid match of "double"
cpprules['do%A']={beginstyle = {[SCE_C_WORD]=true},
  indent = 1,
  unindent = {}}
cpprules['for']={beginstyle = {[SCE_C_WORD]=true},
  indent = cstyle_for_indent,
  unindent = {}}
cpprules['case']={beginstyle = {[SCE_C_WORD]=true},
  indent = 1,
  unindent = {['case'] = 1, ['default'] = 1}}
cpprules['default']={beginstyle = {[SCE_C_WORD]=true},
  indent = 1,
  unindent = {['case'] = 1, ['default'] = 1}}
cpprules['{']={beginstyle = {[SCE_C_OPERATOR]=true},
  indent = 1,
  unindent = {['if'] = 1, ['else'] = 1, ['while'] = 1,
    ['do%A'] = 1, ['for'] = cstyle_ob_for_unindent}}
cpprules['}']={beginstyle = {[SCE_C_OPERATOR]=true},
  indent = 0,
  unindent = {['{'] = 1, ['case'] = 0, ['default'] = 0}}
cpprules[';']={beginstyle = {[SCE_C_OPERATOR]=true},
  indent = 0,
  unindent = {['if'] = 0, ['else'] = 0, ['while'] = 0,
    ['for'] = cstyle_sc_for_unindent}}
cpprules['%(']={beginstyle = {[SCE_C_OPERATOR]=true},
  indent = 1,
  unindent = {}}
cpprules['%)']={beginstyle = {[SCE_C_OPERATOR]=true},
  indent = 0,
  unindent = {['%('] = 1}}

--[[ add embedded JavaScript styles to cpprules ]]
for k,v in pairs(cpprules) do
  if v.beginstyle[SCE_C_OPERATOR] then v.beginstyle[SCE_HJ_SYMBOLS] = true end
  if v.beginstyle[SCE_C_WORD] then v.beginstyle[SCE_HJ_KEYWORD] = true end
end

-- CPP styles
cppdecide = {}
cppdecide[SCE_C_DEFAULT]='cpp'
cppdecide[SCE_C_COMMENT]='cpp'
cppdecide[SCE_C_COMMENTLINE]='cpp'
cppdecide[SCE_C_COMMENTDOC]='cpp'
cppdecide[SCE_C_NUMBER]='cpp'
cppdecide[SCE_C_WORD]='cpp'
cppdecide[SCE_C_STRING]='cpp'
cppdecide[SCE_C_CHARACTER]='cpp'
cppdecide[SCE_C_UUID]='cpp'
cppdecide[SCE_C_PREPROCESSOR]='cpp'
cppdecide[SCE_C_OPERATOR]='cpp'
cppdecide[SCE_C_IDENTIFIER]='cpp'
cppdecide[SCE_C_STRINGEOL]='cpp'
cppdecide[SCE_C_VERBATIM]='cpp'
cppdecide[SCE_C_REGEX]='cpp'
cppdecide[SCE_C_COMMENTLINEDOC]='cpp'
cppdecide[SCE_C_WORD2]='cpp'
cppdecide[SCE_C_COMMENTDOCKEYWORD]='cpp'
cppdecide[SCE_C_COMMENTDOCKEYWORDERROR]='cpp'
cppdecide[SCE_C_GLOBALCLASS]='cpp'

t_langdecide[SCLEX_CPP] = cppdecide
t_langrules['cpp'] = cpprules
indent_init('cpp')
context['cpp'].forstack = {}
