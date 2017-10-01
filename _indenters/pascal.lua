--[[LUA rules]]
pascalrules = {}
pascalrules['uses']={beginstyle = {[SCE_PAS_WORD]=true},
  indent = 1,
  unindent = {['type'] = 1,['var'] = 1,['const%A'] = 1,['implementation'] = 1,
    ['function'] = 1,['procedure'] = 1}}
pascalrules['implementation']={beginstyle = {[SCE_PAS_WORD]=true},
  indent = 0,
  unindent = {['type'] = 1,['var'] = 1,['const%A'] = 1,['uses'] = 1}}
pascalrules['type']={beginstyle = {[SCE_PAS_WORD]=true},
  indent = 1,
  unindent = {['uses'] = 1,['type'] = 1,['var'] = 1,['const%A'] = 1,
    ['implementation'] = 1,['begin'] = 1}}
pascalrules['var']={beginstyle = {[SCE_PAS_WORD]=true},
  indent = 1,
  unindent = {['uses'] = 1,['type'] = 1,['var'] = 1,['const%A'] = 1,
    ['implementation'] = 1,['begin'] = 1}}
pascalrules['const%A']={beginstyle = {[SCE_PAS_WORD]=true},
  indent = 1,
  unindent = {['uses'] = 1,['type'] = 1,['var'] = 1,['const%A'] = 1,
    ['implementation'] = 1,['begin'] = 1}}
pascalrules['begin']={beginstyle = {[SCE_PAS_WORD]=true},
  indent = 1,
  unindent = {['if'] = 1, ['else'] = 1, ['while'] = 1,
    ['for'] = 1,['type'] = 1,['var'] = 1,
    ['const%A'] = 1,['uses'] = 1}}
pascalrules['end']={beginstyle = {[SCE_PAS_WORD]=true},
  indent = 0,
  unindent = {['begin'] = 1,['private'] = 1,['public'] = 1,['protected'] = 1,
    ['published'] = 1,['class'] = 1,['interface'] = 1}}
pascalrules['private']={beginstyle = {[SCE_PAS_WORD]=true},
  indent = 1,
  unindent = {['private'] = 1,['public'] = 1,['protected'] = 1,['published'] = 1}}
pascalrules['public']={beginstyle = {[SCE_PAS_WORD]=true},
  indent = 1,
  unindent = {['private'] = 1,['public'] = 1,['protected'] = 1,['published'] = 1}}
pascalrules['protected']={beginstyle = {[SCE_PAS_WORD]=true},
  indent = 1,
  unindent = {['private'] = 1,['public'] = 1,['protected'] = 1,['published'] = 1}}
pascalrules['published']={beginstyle = {[SCE_PAS_WORD]=true},
  indent = 1,
  unindent = {['private'] = 1,['public'] = 1,['protected'] = 1,['published'] = 1}}
pascalrules['if']={beginstyle = {[SCE_PAS_WORD]=true},
  indent = 1,
  unindent = {['else'] = 1}}
pascalrules['else']={beginstyle = {[SCE_PAS_WORD]=true},
  indent = 1,
  unindent = {['if'] = 1}}
pascalrules['while']={beginstyle = {[SCE_PAS_WORD]=true},
  indent = 1,
  unindent = {}}
pascalrules['repeat']={beginstyle = {[SCE_PAS_WORD]=true},
  indent = 1,
  unindent = {['until'] = 1}}
pascalrules['until']={beginstyle = {[SCE_PAS_WORD]=true},
  indent = 0,
  unindent = {['repeat'] = 1}}
pascalrules['function']={beginstyle = {[SCE_PAS_WORD]=true},
  indent = 0,
  unindent = {['uses'] = 1}}
pascalrules['procedure']={beginstyle = {[SCE_PAS_WORD]=true},
  indent = 0,
  unindent = {['uses'] = 1}}
-- pascalrules[';']={beginstyle = {[SCE_PAS_OPERATOR]=true},
  -- indent = 0,
  -- unindent = {['uses'] = 1,['if'] = 1, ['else'] = 1, ['while'] = 1,
    -- ['for'] = 1}}

-- Pascal styles
pascaldecide = {}
pascaldecide[SCE_PAS_DEFAULT]='pascal'
pascaldecide[SCE_PAS_IDENTIFIER]='pascal'
pascaldecide[SCE_PAS_COMMENT]='pascal'
pascaldecide[SCE_PAS_COMMENT2]='pascal'
pascaldecide[SCE_PAS_COMMENTLINE]='pascal'
pascaldecide[SCE_PAS_PREPROCESSOR]='pascal'
pascaldecide[SCE_PAS_PREPROCESSOR2]='pascal'
pascaldecide[SCE_PAS_NUMBER]='pascal'
pascaldecide[SCE_PAS_HEXNUMBER]='pascal'
pascaldecide[SCE_PAS_WORD]='pascal'
pascaldecide[SCE_PAS_STRING]='pascal'
pascaldecide[SCE_PAS_STRINGEOL]='pascal'
pascaldecide[SCE_PAS_CHARACTER]='pascal'
pascaldecide[SCE_PAS_OPERATOR]='pascal'
pascaldecide[SCE_PAS_ASM]='pascal'

t_langdecide[SCLEX_PASCAL] = pascaldecide
t_langrules['pascal'] = pascalrules
indent_init('pascal')
