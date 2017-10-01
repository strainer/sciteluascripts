--[[HTML rule functions]]
--[[ $html_indentable
keys like this mean that the content between <body ...> and </body> should be indented
  ['body'] = true
This line means, that content between <tr ...> and </tr> should be indented, and
1. the first table tells, what should be done, when parsing the <tr> tag
1.a. ['td'] = 0, ['th'] = 0  means, that if the last unended tag is a <td> or <th> then that tag must
be implicite ended (and unindented) and the next unended tag must be checked too (and so on)
1.b. ['tr'] = 1  means, that if the last unended tag is a <tr>, that must be ended, and other
unended tags should not be checked
2. The second table tells what should be done, when parsing the </tr> tag
  ['tr'] = {{['td'] = 0, ['th'] = 0, ['tr'] = 1}, {['td'] = 0, ['td'] = 0, ['tr'] = 1} }
]]
html_indentable = {['address'] = true,
  ['blockquote'] = true,
  ['body'] = true,
  ['center'] = true,
  ['dir'] = true,
  ['div'] = true,
  ['dd'] = {{['dd'] = 1, ['dt'] = 1}, {['dd'] = 1} },
  ['dl'] = true,
  ['dt'] = {{['dd'] = 1, ['dt'] = 1}, {['dt'] = 1} },
  ['fieldset'] = true,
  ['form'] = true,
  ['frameset'] = true,
  ['h1'] = true,
  ['h2'] = true,
  ['h3'] = true,
  ['h4'] = true,
  ['h5'] = true,
  ['h6'] = true,
  ['head'] = true,
  ['html'] = true,
  ['isindex'] = true,
  ['li'] = true,
  ['menu'] = true,
  ['noframes'] = true,
  ['noscript'] = true,
  ['ol'] = true,
-- <p> behaves oddly, so I don't indent it
--~   ['p'] = {{['p'] = 1}, {['p'] = 1} },
  ['pre'] = true,
  ['span'] = true,
  ['style'] = true,
  ['table'] = {false, {['td'] = 0, ['th'] = 0, ['tr'] = 0, ['table'] = 1} },
  ['tbody'] = true,
  ['td'] = {{['td'] = 1, ['th'] = 1}, {['td'] = 1} },
  ['tfoot'] = true,
  ['th'] = {{['th'] = 1, ['td'] = 1}, {['th'] = 1} },
  ['thead'] = true,
  ['tr'] = {{['td'] = 0, ['th'] = 0, ['tr'] = 1}, {['td'] = 0, ['td'] = 0, ['tr'] = 1} },
  ['ul'] = true
}

function html_bt_indent (match)
  local tagstack = c_context.tagstack
  local tag = string.lower(string.sub(match, 2))
  if html_indentable[tag] then
    c_context.tagstack[table.getn(c_context.tagstack) + 1] = tag
    return 1
  end
  return 0
end


function html_bt_unindent(match)
  local tagstack = c_context.tagstack
  local tag = string.lower(string.sub(match, 2))
  if 'table' ~= type(html_indentable[tag]) then return nil end
  local stable = html_indentable[tag][1]
  if 'table' ~= type(stable) then return nil end

  local htl = table.getn(c_context.tagstack)
  local retval

  retval = stable[c_context.tagstack[htl]]
  if retval then c_context.tagstack[htl] = nil end

  return retval
end


function html_et_unindent(match)
  local tagstack = c_context.tagstack
  local tag = string.lower(string.sub(match, 3))
  if not html_indentable[tag] then return nil end

  local htl = table.getn(c_context.tagstack)
  local retval
  if 'table' == type(html_indentable[tag]) then
    local stable = html_indentable[tag][2]
    retval = stable[c_context.tagstack[htl]]
  else
    if tag == c_context.tagstack[htl] then
      retval = 1
    else
      retval = 0
    end
  end

  c_context.tagstack[htl] = nil
  return retval
end

--[[HTML rules]]
htmlrules = {}
htmlrules['<%a+']={beginstyle = {[SCE_H_TAG]=true},
  indent = html_bt_indent,
  unindent = {['<%a+'] = html_bt_unindent}}
htmlrules['</%a+']={beginstyle = {[SCE_H_TAG]=true},
  indent = 0,
  unindent = {['<%a+'] = html_et_unindent}}

--[[information for deciding what language does the document contain ]]
htmldecide={}
-- PHP styles: only lines that begin with one of these styles are treated as PHP
htmldecide[SCE_HPHP_COMPLEX_VARIABLE] = 'php'
htmldecide[SCE_HPHP_DEFAULT] = 'php'
htmldecide[SCE_HPHP_HSTRING] = 'php'
htmldecide[SCE_HPHP_SIMPLESTRING] = 'php'
htmldecide[SCE_HPHP_WORD] = 'php'
htmldecide[SCE_HPHP_NUMBER] = 'php'
htmldecide[SCE_HPHP_VARIABLE] = 'php'
htmldecide[SCE_HPHP_COMMENT] = 'php'
htmldecide[SCE_HPHP_COMMENTLINE] = 'php'
htmldecide[SCE_HPHP_HSTRING_VARIABLE] = 'php'
htmldecide[SCE_HPHP_OPERATOR] = 'php'

-- HTML styles
htmldecide[SCE_H_DEFAULT]='html'
htmldecide[SCE_H_TAG]='html'
htmldecide[SCE_H_TAGUNKNOWN]='html'
htmldecide[SCE_H_ATTRIBUTE]='html'
htmldecide[SCE_H_ATTRIBUTEUNKNOWN]='html'
htmldecide[SCE_H_NUMBER]='html'
htmldecide[SCE_H_DOUBLESTRING]='html'
htmldecide[SCE_H_SINGLESTRING]='html'
htmldecide[SCE_H_OTHER]='html'
htmldecide[SCE_H_COMMENT]='html'
htmldecide[SCE_H_ENTITY]='html'
htmldecide[SCE_H_TAGEND]='html'

-- embedded JavaScript styles
htmldecide[SCE_HJ_START]='cpp'
htmldecide[SCE_HJ_DEFAULT]='cpp'
htmldecide[SCE_HJ_COMMENT]='cpp'
htmldecide[SCE_HJ_COMMENTLINE]='cpp'
htmldecide[SCE_HJ_COMMENTDOC]='cpp'
htmldecide[SCE_HJ_NUMBER]='cpp'
htmldecide[SCE_HJ_WORD]='cpp'
htmldecide[SCE_HJ_KEYWORD]='cpp'
htmldecide[SCE_HJ_DOUBLESTRING]='cpp'
htmldecide[SCE_HJ_SINGLESTRING]='cpp'
htmldecide[SCE_HJ_SYMBOLS]='cpp'
htmldecide[SCE_HJ_STRINGEOL]='cpp'
htmldecide[SCE_HJ_REGEX]='cpp'

t_langdecide[SCLEX_HTML] = htmldecide
t_langrules['html'] = htmlrules
indent_init('html')
context['html'].tagstack = {}
