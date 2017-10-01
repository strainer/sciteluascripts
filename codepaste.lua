slide_Command("Code Paste|wcode_paste|Ctrl+v")

--[[
Code Paste, inserts lines at the carets indent level
]]
function wcode_paste()
	get_pane():BeginUndoAction()
	code_paste()
	get_pane():EndUndoAction()
end

function code_paste ()
	
	local pane=get_pane()
	if pane.SelectionMode~=0 then return false end
	
	--false returns arent continuing paste handling for some reason
	undoact(pane)

	local tabw=pane.TabWidth
	local apos,cpos=pane.Anchor,pane.CurrentPos
	local ax,cx=apos,cpos
	
	local olcount=pane.LineCount
	local wassel=(cpos~=apos)
	local sflipped=false
			
	if cpos<apos then
		cpos,apos = apos,cpos
		sflipped=true
	end

	local ditch
	if pane:PositionFromLine(pane:LineFromPosition(cpos))==cpos and cpos==apos then
		ditch=true
	end
		
	local undercopy
	if pane:LineFromPosition(apos)~=pane:LineFromPosition(cpos) then
		undercopy=pane:textrange(apos,cpos)
		if cpos-apos<200 and not string.find(undercopy,"[%w%p]") then
			undercopy=nil
		end
	end
	
	pane:Paste()
	
	local pastend = pane.CurrentPos --it will be this if multiline..
	local multipaste=pane:LineFromPosition(apos)~=pane:LineFromPosition(pane.CurrentPos)	
	local stopStall = pane.CurrentPos-apos > 1000000
	
	--if a singleline pasted clear selection, return false end
	if (pane.LineCount)==olcount or stopStall or ditch or not multipaste then
		if not multipaste then --(still after clear first sel)
			pane.Anchor,pane.CurrentPos=pastend,pastend
		else
			pane.Anchor,pane.CurrentPos=pastend,pastend
		end
		undoact(pane)
		if undercopy then pane:CopyText(undercopy) end
		keytrap(0, nil, nil, nil, apos, pastend)
		return true
	end

	local pEnd=pastend

	--isolate pasted text with newlines (for tab shifting )
	pane:AddText("\n")
	pane:SetSel(apos,apos)
	pane:AddText("\n")

	local pBeg=apos+1
	local pEnd=pastend	-- +1 ??
	local destin = indent_of_range(pane,line_anchor(pane,apos),apos)

	--note indent of first paste line       --caution fine wove spagetti...
	local fpasti=indent_in_line(pane,pBeg)

	--start of 2nd paste line
	local en=pane:PositionFromLine(pane:LineFromPosition(pBeg)+1) 
	local fpasti2=indent_in_line(pane,en)
	
	--use 2nd line i when 1st seems clipped
	--better to read the line and estimate if it indents...
	if fpasti==0 and fpasti2>1 then fpasti=fpasti2 end 
	
	local lenA=pane.Length
	local shiA=destin-fpasti
	
	local tEnd --sometime pEnd is not on newline when end of paste was?? fdg..
	if pane:PositionFromLine(pane:LineFromPosition(pEnd))==pEnd then
		tEnd=pEnd
	else
		tEnd = pane:PositionFromLine(pane:LineFromPosition(pEnd)+1)
	end
	
	tab_mov(pane,pBeg,tEnd,shiA)	
	tab_mov(pane, pane:PositionFromLine(pane:LineFromPosition(pBeg))
							, pane:PositionFromLine(pane:LineFromPosition(pBeg)+1)
							, 0-destin) --move first line by -first.indent

	local lendiff=pane.Length-lenA
		
	pEnd=pEnd+lendiff
	
	pane:SetSel(pEnd+1,pEnd+2)
	
	pane:Clear()
	pane:SetSel(apos,apos+1)
	pane:Clear() --take out the newline
	
	--if on a newline ,insert the indent:destin
	local ls = pane:LineFromPosition(pEnd+1)
	if (pane:PositionFromLine(ls)-pEnd)==0 and (pane.LineEndPosition[ls]-pEnd)>0 then
		pane:SetSel(pEnd,pEnd)
		pane:ReplaceSel(
		string.sub("\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t",0,destin)
		)
	end
	
	undoact(pane)

	if undercopy then pane:CopyText(undercopy) end
	keytrap(0, nil, nil, nil, pBeg-1, pEnd)
	pane:SetSel(pEnd,pEnd)
	return true
end


function indent_of_range(pane,a,c) --counts indents to a position through letters and wspace
	local gark,cnttab=string.gsub(pane:textrange(a,c),"[\t]","")
	local indy=cnttab+math.floor(string.len(gark)/pane.TabWidth)	--calcued tab indents at anchor
	return indy
end

function tab_mov(pane,a,c,indy) --mov on a selection
	if a>c then a,c=c,a end
	pane:SetSel(a,c)
	indy=math.floor(indy)
	while indy~=0 do
		if indy>0 then
			pane:Tab() indy=indy-1
		else
			pane:BackTab() indy=indy+1
		end
	end
end

function starts_line(pane,mpos)
	return mpos==line_anchor(pane,mpos)
end

function line_anchor(pane,mpos)
	return pane:PositionFromLine(pane:LineFromPosition(mpos))
end

function indent_in_line(pane,zpos)
	local indy=0
	local tabww=pane.TabWidth
	
	zpos=line_anchor(pane,zpos)

	while pane:textrange(zpos,zpos+1)==" "
	or pane:textrange(zpos,zpos+1)=="\t"
	do
		if pane:textrange(zpos,zpos+1)=="\t" then
			indy=indy+tabww
		else
			indy=indy+1
		end
		zpos=zpos+1
	end
	return math.floor(indy/tabww)
end

