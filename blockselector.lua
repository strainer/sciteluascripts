scite_Command("Line Block Select|select_tool|Ctrl+K")

--[[

if output use, existing output func

if editor>>

if not multiline
	calc the subline
if smaller than subline, set as subline  return  (was smaller than sub)
if larger then set full (multiline)      return  (was larger than sub)

if multiline
	calc linelevels
if same linelevels
	calc space expansion within same level
	
if space expansion was not limited by level
	set it                                      (was sublevel space expansion)
	
all else
															
do level expansion
	know lowest level
	travel up and down while all lowestlevel or higher are encountered
	if there was no movement, do again for lowlev-1
	unless lowlev-1= 0 in which case do the zero expansion
	
	if no move and lowlevel-1 = 0
		then take all comments above


]]


-- mnamna

function select_tool()
	local pane=get_pane()
	
	local aft = pane.Anchor			--bottom is up but number low 
	local fre = pane.CurrentPos  --its not this way its the other!
	local ank,cur=select_tool2(pane,aft,fre)	
	
	pane:SetSel(ank, cur)
	keytrap(0, nil, nil, nil, ank, cur)
end

function select_tool2(pane,pluPos,minuPos)  --begs rewritten
	local cpp = editor.Lexer == SCLEX_CPP

	local pluPos = pluPos or pane.Anchor			--bottom is up but number low 
	local minuPos = minuPos or pane.CurrentPos  --its not this way its the other!
	local pluLine = pane:LineFromPosition(pluPos)
	local minuLine = pane:LineFromPosition(minuPos)

	local line = pluLine
			
	local aswitched=false
	if pluPos<minuPos then   --bot and top pos are switched
		aswitched=true
		pluPos,minuPos = minuPos,pluPos
		pluLine,minuLine = minuLine,pluLine	
	end 

	local minuTxp, pluTxp = text_part(pane,minuPos)
	if minuLine==pluLine and 
	not (minuPos==minuTxp and pluPos==pluTxp) 
	then --term or blanks select and return 
		return minuTxp, pluTxp
	end  --end of response to no selection 
	
	local lroota = pane:PositionFromLine(minuLine) --is lineroot anchor
	
	local minuGo = pane:PositionFromLine(minuLine)
	local pluGo = pane:PositionFromLine(pluLine+1)
	
	if minuGo<minuPos or pluPos~=pane:PositionFromLine(pluLine) 
	then
	--select to pluLine start and minuLine end...
		if true then return minuGo, pluGo
		else return pluGo,minuGo end
	end                 --line and box selection finnished
	 
	local go_on=not fold_line(minuLine)
	local flipit= go_on
	local wasMli,wasPli=minuLine,pluLine
	
	--taking lines up
	local ucount=0
	while (minuLine>0 ) and go_on and
	((pane==editor and is_white(pane:GetLine(minuLine))==is_white(pane:GetLine(minuLine-1)))
	or (pane==output and (ucount==0 or string.sub(pane:GetLine(minuLine-1),1,1)~=">") ))

	do
		if pane==editor then
			if ( ((pane.FoldParent[pluLine-1]>pane.FoldParent[minuLine])) )
			then go_on=false 
			else minuLine=minuLine-1
			end
		else	
			minuLine=minuLine-1
			ucount=ucount+1
		end
	end	

	--editor specific line stepping down
	go_on=pane.FoldParent[pluLine+1]==pane.FoldParent[pluLine]
	while (pluLine<pane.LineCount-1 )
	and is_white(pane:GetLine(pluLine))==is_white(pane:GetLine(minuLine))
	and go_on
	do
		if pane==editor and ( editor.FoldParent[pluLine]~=editor.FoldParent[pluLine-1] 
		or fold_line(pluLine) ) then go_on=false
		else	
			pluLine=pluLine+1
		end
	end	
	
	--if sel moved already finnish for editor
	if pane==editor and wasMli~=minuLine or wasPli~=pluLine
	then
		if aswitched and flipit then 
			 return pane:PositionFromLine(pluLine), pane:PositionFromLine(minuLine) 
		else
			 return pane:PositionFromLine(minuLine), pane:PositionFromLine(pluLine) 
		end
--~ 			if pane==editor then return true end
	end
	
	--finnish with output pane functionality
	if pane==output then 
		--if ucount<2 then 
		minuLine=minuLine-1 
		if minuLine<0 then minuLine = pane.Length end
		if pane.CurrentPos==pane:PositionFromLine(pluLine)
		then
			 return pane.Length ,pane:PositionFromLine(minuLine) 
		else
			 return pane.LineEndPosition[pluLine] ,pane:PositionFromLine(minuLine) 
		end	
		 
	end 
			
	local eline = line
--~ 		if pane.Anchor > pane.CurrentPos then eline=pane:LineFromPosition(pane.CurrentPos) end
	
--give this the right line...
	
	if fold_line(eline) then --if on fold line
			parent = line
	else
			parent = editor.FoldParent[line]
	end
	-- (1) in C-style languages, the control statement is often just before the 
	-- fold point. See (2)
	if parent == -1 and cpp and fold_line(line+1) then
			parent = line+1
	end
	if parent ~= -1 then
			local lastl = editor:GetLastChild(parent,-1)  --NB!
			local posE = editor:PositionFromLine(lastl+1)
			-- (2) it is common practice for the open brace in C-style languages to be
			-- on its own line. Adjust our upper line for this case.
			if  cpp and editor:GetLine(parent):find('^%s*{%s*$') then
					parent = parent - 1
			end
			
			local pos = editor:PositionFromLine(parent)
			
			local lowest=pane.Anchor
			local highest=pane.CurrentPos
			if lowest>posE then lowest=posE end
			if lowest>pos then lowest=pos end
			if highest<posE then highest=posE end
			if highest<pos then highest=pos end
			 return highest,lowest
	end
	
--~ 		--more hacks...
--~ 		local nlin=editor:LineFromPosition(minuPos)
--~ 		local glin=editor:LineFromPosition(pluPos)
--~ 
--~ 		while nlin > 0 and editor.FoldParent[nlin-1]==-1 do
--~ 					nlin=nlin-1
--~ 			end
--~ 
--~ 		if nlin==editor:LineFromPosition(minuPos) then
--~ 				local goon=true
--~ 				while glin+1<editor.LineCount
--~ 				and goon
--~ 				do
--~ 						if editor.FoldParent[glin+1]==-1
--~ 						then
--~ 								glin=glin+1
--~ 						else
--~ 								goon=false 
--~ 						end
--~ 				end
--~ 				pluPos=minuPos
--~ 				minuPos=editor:PositionFromLine(glin)
--~ 		else
--~ 				minuPos=editor:PositionFromLine(nlin)
--~ 		end
		
	 return pluPos,minuPos	
end

function text_part(pane,cpos)
	
	--[[ return start to end of non whitespace in line,
				must select for incremental select tool
				but to use as a tool to skip to the other side
				arrange anchor and pos	
	]]
	
	local toplin=pane:LineFromPosition(cpos)
	local lp=pane:PositionFromLine(toplin)
	local l=pane:GetLine(toplin) --nil if lastline
	
	if not l then --take care of end of doc
		if toplin >0 then local ss=pane:PositionFromLine(toplin-1)	
		else ss=pane:PositionFromLine(toplin+1) end
		local ee=pane:PositionFromLine(toplin)
		return ss,ee
	end
				
	local e=string.len(l)
	
	while e>0 
	and (string.find(string.sub(l,e-1,e-1),"[\t\n\r ]")
	or shouldIgnorePos(lp+e-1,pane,pane.Lexer) )
	do e=e-1 end
	
	local k="[^\t\n ]"
	if pane==output then k=";[ ]?([^\t\n ])" end
	local d,s=string.find(l,k) --first non white 
	if not s then --all white or no semi-colon
		s=0
	else
		s=s-1
	end 
	e=string.len(string.match(l,"(.-)[\n\r]*$"))
	
	local ss=lp+s 
	local ee=lp+e
	
	--if e==0 then ee=pane:PositionFromLine(toplin+1) end
	
	local jin=cpos-lp
	if (jin-s)<(e-jin) then
		return ss,ee --anchor,position
	else
		return ee,ss
	end
end
