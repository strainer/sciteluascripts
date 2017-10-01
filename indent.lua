--[[ indentation for SciTE version 1.1 - copyleft by Prim, Andras : do with this code whatever you want
Handled languages: HTML, PHP, C, CPP,  JavaScript, embedded JavaScript, XML
This script uses the syntax highlight info, so it works correctly, when the correct lexer is used.

Put something like this in your User options file (SciTEUser.properties)

ext.lua.startup.script= /home/bandi/scite/indent.lua
command.name.1.*=indent
command.1.*=do_indent
command.subsystem.1.*=3
command.mode.1.*=savebefore:no

This will make a menu item in your "Tools" menu, that can be used with Control+1 shortcut
]]

scite_Command 'Indent|do_indent|Ctrl+Shift+i'

--[[ just a helper for me ]]
function showstyle()
	print ('lexer: ' .. editor:GetLexerLanguage() .. ' style: ' .. editor.StyleAt[editor.CurrentPos])
end

	function do_indent()
		langdecide = t_langdecide[editor.Lexer]
		if nil == langdecide then
			print 'Don\'t understand how to indent this language'
			return
		end
		editor:Colourise(0,-1)
		undoact(editor)
		
		--////
		local dc=editor.CurrentPos
		local da=editor.Anchor
		local dz=dc
		if dc<da then dc=da da=dz end
		
		local st=0
		local nd=editor.LineCount

		local onselx=(editor:PositionFromLine(editor:LineFromPosition(editor.CurrentPos)-1)-editor.CurrentPos)/2
		
		onselx=3 --borked
		
		if dc~=da then
			st=editor:LineFromPosition(da)
			nd=editor:LineFromPosition(dc)
		else
			onselx=0
		end
		
		for i = st, nd, 1 do
		iline = i+1 -- global for linenum
		--~     print (iline)
		local startpos = editor.LineIndentPosition[i]
		
		-- $lang: language of current line, according to the style of the first character
		local lang = langdecide[editor.StyleAt[startpos]]
		-- indent only if the language is known
		if (lang) then
			c_context = context[lang] -- current context
			local indent = c_context.indent+onselx  --!!hacky tweak to push selections over
			local nextindent = c_context.nextindent
			local pstack = c_context.pstack
			local langrules = t_langrules[lang]

			editor.LineIndentation[i]=0 -- this is needed to uniformize the space/tabs in indentation
			startpos = editor.LineIndentPosition[i]
			local line = editor:GetLine(i)

			if (line) then
				--[[ $beginpos holds the beginning of found patterns
				i.e. beginpos[10]='if' means there is an 'if' beginning at 10 in the line ]]
				local linelength = string.len(line)
				local beginpos = {}
				for i = 1, linelength, 1 do beginpos[i] = false end

				for pattern,struct in pairs(langrules) do
					local bp, ep = string.find(line, pattern, 1)
					while bp do
						local match = string.sub(line, bp, ep)
						-- put in $beginpos only if it starts with correct Scintilla style
						if struct.beginstyle[editor.StyleAt[startpos + bp - 1]] then
							beginpos[bp] = {pattern , match}
						end
						bp, ep = string.find(line, pattern, bp + 1)
					end
				end

				-- now we found all the positions, let's count indentation
				for i = 1, linelength, 1 do
					if beginpos[i] then
						pattern = beginpos[i][1]
						match = beginpos[i][2]
						local go = true

						-- unindent things in the stack
						while go and table.getn(pstack) > 0 do
							local uni = langrules[pattern].unindent[pstack[table.getn(pstack)]]
							if 'function' == type(uni) then uni = uni(match) end

							if uni then
								if i == 1 then indent = indent - 1 end
								nextindent = nextindent - 1
								if 0 ~= uni then go = false; end
								pstack[ table.getn(pstack) ] = nil -- removes last
							else
								go = false
							end
						end

						-- count the indentation
						local sti = langrules[pattern].indent
						if 'function' == type(sti) then sti = sti(match) end

						if 0 ~= sti then
							nextindent = nextindent + sti
							pstack[table.getn(pstack) + 1] = pattern
							end
						end -- if beginpos[i]
					end -- for i = 1, linelength, 1
				end -- if line

			editor.LineIndentation[i]=editor.Indent * indent
			indent = nextindent

			-- save non-reference type members of context
			c_context.indent = nextindent
			c_context.nextindent = nextindent
		end --  if (indentstyles[editor.StyleAt[startpos]])
	end -- for i = 1 to linenum

	undoact(editor)
	editor.CurrentPos=editor.LineEndPosition[editor:LineFromPosition(editor.CurrentPos)]
end

--[[Here goes stuff, that must be done before each indentation run]]
function indent_init(lang)
	-- initialize context for a given language
	context[lang] = {['indent'] = 0, ['nextindent'] = 0, ['pstack'] = {} }
end

--[[Rules and rule functions]]
--[[
semantics of    *rules[<pattern>]: (where * is the name of the language)
<pattern> is a lua string.find pattern
where this pattern is found in the indented source code, the followings should be done:

1. It must be checked whether the SciTE style at the beginning of the found pattern
is a key in *rules[<pattern>].beginstyle, and it's value evaluates to true. If not,
this match should not be handled.

2. If the innermost pattern, that still has indentation effect is <patt2>, and there is
a key value pair: *rules[<pattern>].unindent[<patt2>] = <value>
then the indentation effect of <patt2> ends in this line.

If <value>==0 then the next innermost pattern is also checked. (And so on, while
the <value> for that pattern is still 0.)
(This way we can unindent nested one-line conrulesions at the innermost statement like
if(a)
if(b)
echo 'a and b';
)
If <value> is a function, it should be called and the return value is to be used. When the
return value is nil, it is treated as if there was no <patt2> key in the table.

3. The next line should be indented additional *rules[<pattern>].indent levels.
If this field is a function, it is called and the return value is used.
(currently only 0 and 1 are treated well)
]]

-- t_langdecide[<Scintilla-lexer>][<line-begin-style>]='<langstring>'
t_langdecide = {}
t_langrules = {}
context = {}

local GTK = scite_GetProp('PLAT_GTK')
local dirsep

if GTK then
	dirsep = '/'
else
	dirsep = '\\'
end

local extman_path = path_of(props['ext.lua.startup.script'])
local lua_path = scite_GetProp('ext.lua.directory',extman_path)
local indenter_path = lua_path..dirsep..'_indenters'

--~ local script_list = scite_Files(indenter_path..dirsep..'*.lua')
--~ load_script_list(script_list,indenter_path)

dofile(indenter_path..dirsep..'cpp.lua')
dofile(indenter_path..dirsep..'html.lua')
dofile(indenter_path..dirsep..'lua.lua')
dofile(indenter_path..dirsep..'pascal.lua')
dofile(indenter_path..dirsep..'php.lua')
dofile(indenter_path..dirsep..'xml.lua')
