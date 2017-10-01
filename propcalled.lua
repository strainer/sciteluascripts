--these funs added in scite properties

--cuts and pastes selection from one pane to the other
function movetoout()
	
	local pane=get_pane()
	local tx,ql 
	local ap=pane.Anchor
	local cp=pane.CurrentPos
	--if nothing selected do the current line
	if ap>cp then ap,cp=cp,ap end
	
	if ap==cp then
		local ql=pane:LineFromPosition(pane.CurrentPos)
		ap=pane:PositionFromLine(ql)
		cp=pane.LineEndPosition[ql]
	end
		
	tx=pane:textrange(ap,cp)
	
	if pane==editor then
		local ql=output:LineFromPosition(output.CurrentPos)
		ap=output:PositionFromLine(ql)
		cp=output.LineEndPosition[ql]
		if cp~=ap then output:AppendText("\n") end
		print(tx)
	else
		editor:insert(editor.CurrentPos,tx)
	end
	
	return true
end

--jumps to the end of command pane and appends p, and if p is set
--adds selected or the word around current position (for li: and sp:)
function traceCmd(p)
	
	local r=""
	local pane=get_pane()
	if p~="" then
		r=pane:GetSelText()
		if r=="" then
			r=get_word(pane)
			if (pane.CurrentPos == wordstart(pane))
			or (pane.CurrentPos == wordend(pane))
			then r="" end --only word select here if actually inside a word
		end
	end
	if r:find("[\r\n]") or r:find(" ~") then r="" end 
	trace(p..r)
	scite.MenuCommand(421)   --421 just toggles focus
	return true
end

slide_Command("Move selection|movetoout|Ctrl+m")
slide_Command("Spots|traceCmd 'spot,'|Ctrl+Shift+j")
