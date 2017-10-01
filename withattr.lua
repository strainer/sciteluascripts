-- a set of useful block operations for SciTE
-- Steve Donovan, 2008
-- block_end() is bound to Ctrl+E and allows you to skip
-- between the start and end of a block.
-- For curly-brace languages, use the SciTE implementation
-- of this command.
-- It works fine for Lua, and probably for any language
-- with explicit block markers, but tends to get confused
-- with Python.

-- note that we explicitly have to compare the result to zero, since
-- a zero value is NOT considered false in Lua!
function fold_line(line)
	local lev = editor.FoldLevel[line]
--~ 	return bit.band(lev,SC_FOLDLEVELHEADERFLAG) ~= 0
	return asinglebitand(lev,SC_FOLDLEVELHEADERFLAG)
end

--mod by 2 is and by1, mod by4, and by 3  mod by16 is and by 15 so..
function asinglebitand(a,bita)
	return a%(bita*2)>bita-1 --should work given bita has only single bit
end

function goto_line_start(line)
	local pos = editor:PositionFromLine(line)
	editor:GotoPos(pos)
	return pos
end 

slide_Command("Match Block End|block_end|Ctrl+E")

function block_end ()
		-- let SciTE handle the curly braces case!
		if editor.Lexer == SCLEX_CPP then
				scite.MenuCommand(IDM_MATCHBRACE)
		else
				local line = current_line()
				local lno
				if fold_line(line) then
						lno = editor:GetLastChild(line,-1) 
				else
						lno = editor.FoldParent[line] 
						if lno == -1 then
								lno = editor.FoldParent[line-1]
						end
				end
				if lno == -1 then return end 
				goto_line_start(lno)
		end
end

-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
-- from scitediting.lua by Mitchell Foral
-- scite_Command("Auto tag close|tagclose|Ctrl+Shift+t")

function tagclose()
	if (props["command.name.49.*"] == "turn CloseTags off") then
		props["xml.auto.close.tags"] = '0'
		props["command.name.49.*"] = "turn CloseTags on"
	else
		props["xml.auto.close.tags"] = '1'
		props["command.name.49.*"] = "turn CloseTags off"
	end
end


-------------------------------------
-- Ben Fisher, 2006, Public Domain
-- Modified by Mario Ray M., 2008

function ASCIITable()
	print("-- ASCII Table --")
	local showCodeInHex = true
	-- white space characters
	local whitespaces = {
		[0]  = "NUL",[1]  = "SOH",[2]  = "STX",[3]  = "ETX",
		[4]  = "EOT",[5]  = "ENQ",[6]  = "ACK",[7]  = "BEL",
		[8]  = "BS ",[9]  = "HT ",[10] = "NL ",[11] = "VT ",
		[12] = "FF ",[13] = "RET",[14] = "SO ",[15] = "SI ",
		[16] = "DLE",[17] = "DC1",[18] = "DC2",[19] = "DC3",
		[20] = "DC4",[21] = "NAK",[22] = "SYN",[23] = "ETB",
		[24] = "CAN",[25] = "EM ",[26] = "SUB",[27] = "ESC",
		[28] = "FS ",[29] = "GS ",[30] = "PS ",[31] = "US ",
		[32] = "SPC"
	}
	-- and the function begins ...
	for i = 0,31 do
		for j = 0,7 do
			local c
			local idx = i+(j*32)
			if whitespaces[idx] then
				c = whitespaces[idx]
			else
				c = string.char(idx)
			end
			if not showCodeInHex then
				s = string.format("%3d %3s",idx,c)
			else
				s = string.format("%2x %3s",idx,c)
			end
			trace("| "..s.." ")
		end
		print()
	end
end

---------------

