--[[XML rules]]
xmlrules = {}
xmlrules['<%a+']={beginstyle = {[SCE_H_TAG]=true},
  indent = 1,
  unindent = {}}
xmlrules['</%a+']={beginstyle = {[SCE_H_TAG]=true},
  indent = 0,
  unindent = {['<%a+'] = 1}}
xmlrules['/>']={beginstyle = {[SCE_H_TAGEND]=true},
  indent = 0,
  unindent = {['<%a+'] = 1}}

-- XML styles
xmldecide = {}
xmldecide[SCE_H_DEFAULT]='xml'
xmldecide[SCE_H_TAG]='xml'
xmldecide[SCE_H_TAGUNKNOWN]='xml'
xmldecide[SCE_H_ATTRIBUTE]='xml'
xmldecide[SCE_H_ATTRIBUTEUNKNOWN]='xml'
xmldecide[SCE_H_NUMBER]='xml'
xmldecide[SCE_H_DOUBLESTRING]='xml'
xmldecide[SCE_H_SINGLESTRING]='xml'
xmldecide[SCE_H_OTHER]='xml'
xmldecide[SCE_H_COMMENT]='xml'
xmldecide[SCE_H_ENTITY]='xml'
xmldecide[SCE_H_TAGEND]='xml'

t_langdecide[SCLEX_XML] = xmldecide
t_langrules['xml'] = xmlrules
indent_init('xml')
