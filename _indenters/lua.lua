--[[LUA rules]]
luarules = {}
luarules['if']={beginstyle = {[SCE_LUA_WORD]=true},
  indent = 1,
  unindent = {['else'] = 1,['elseif'] = 1}}
luarules['else']={beginstyle = {[SCE_LUA_WORD]=true},
  indent = 1,
  unindent = {['if'] = 1}}
luarules['elseif']={beginstyle = {[SCE_LUA_WORD]=true},
  indent = 1,
  unindent = {['if'] = 1}}
luarules['while']={beginstyle = {[SCE_LUA_WORD]=true},
  indent = 1,
  unindent = {}}
luarules['for']={beginstyle = {[SCE_LUA_WORD]=true},
  indent = 1,
  unindent = {}}
luarules['function']={beginstyle = {[SCE_LUA_WORD]=true},
  indent = 1,
  unindent = {}}
luarules['end']={beginstyle = {[SCE_LUA_WORD]=true},
  indent = 0,
  unindent = {['if'] = 1, ['function'] = 1, ['else'] = 1, ['elseif'] = 1,
    ['while'] = 1, ['for'] = 1}}
luarules['until']={beginstyle = {[SCE_LUA_WORD]=true},
  indent = 0,
  unindent = {['repeat'] = 1}}
luarules['%(']={beginstyle = {[SCE_LUA_OPERATOR]=true},
  indent = 1,
  unindent = {}}
luarules['%)']={beginstyle = {[SCE_LUA_OPERATOR]=true},
  indent = 0,
  unindent = {['%('] = 1}}
luarules['{']={beginstyle = {[SCE_LUA_OPERATOR]=true},
  indent = 1,
  unindent = {}}
luarules['}']={beginstyle = {[SCE_LUA_OPERATOR]=true},
  indent = 0,
  unindent = {['{'] = 1}}

-- LUA styles
luadecide = {}
luadecide[SCE_LUA_DEFAULT]='lua'
luadecide[SCE_LUA_COMMENT]='lua'
luadecide[SCE_LUA_COMMENTLINE]='lua'
luadecide[SCE_LUA_COMMENTDOC]='lua'
luadecide[SCE_LUA_NUMBER]='lua'
luadecide[SCE_LUA_WORD]='lua'
luadecide[SCE_LUA_WORD2]='lua'
luadecide[SCE_LUA_WORD3]='lua'
luadecide[SCE_LUA_WORD4]='lua'
luadecide[SCE_LUA_WORD5]='lua'
luadecide[SCE_LUA_WORD6]='lua'
luadecide[SCE_LUA_WORD7]='lua'
luadecide[SCE_LUA_WORD8]='lua'
luadecide[SCE_LUA_STRING]='lua'
luadecide[SCE_LUA_CHARACTER]='lua'
luadecide[SCE_LUA_LITERALSTRING]='lua'
luadecide[SCE_LUA_PREPROCESSOR]='lua'
luadecide[SCE_LUA_OPERATOR]='lua'
luadecide[SCE_LUA_IDENTIFIER]='lua'
luadecide[SCE_LUA_STRINGEOL]='lua'

t_langdecide[SCLEX_LUA] = luadecide
t_langrules['lua'] = luarules
indent_init('lua')
