slide_Command("summon|word_step|Ctrl+,")
slide_Command("summonb|word_step 1|Ctrl+Shift+,")

function word_step(ssback)

--rotate previous words before caret
--if word is in previouswords replace it with the preceeding
--until word is blank or not in all proceeding
--then replace it with first of previous
--sequence of prev words is before in this line
--after in this line 
	
	local unwanted= {"local","repeat","until","return","function","for","false","true","nil","not","and","or","while","do","then","end","else","elseif","if","to","int" }
	local pane=get_pane()
	local endline=pane:LineFromPosition(pane.Length)
	local preads= {}
	local placers= {}
	local wset={}
	local pnum=1
	local bl="" 
	local gl,gl2=nil,nil
	local wasseld	
	
	local botpos = pane.Anchor			--bottom is up but number low 
	local toppos = pane.CurrentPos  --its not this way its the other!
	local notcmmt = not shouldIgnorePos(pane.CurrentPos,pane,pane.Lexer)
	
	if botpos~=toppos then wasseld =true end
	if botpos>toppos then botpos,toppos=toppos,botpos end
	
	local botlin = pane:LineFromPosition(botpos)
	local botlnp = pane:PositionFromLine(botlin)
	
	local repls,reple = botpos-botlnp , toppos-botlnp
	--print("\neee ",repls,reple,botpos,toppos,botlnp)
	local replx = ""
	
	local toplin = pane:LineFromPosition(toppos)
	local tpin   = toppos-pane:PositionFromLine(toplin)
	local endlin = pane:LineFromPosition(pane.Length)

	local rline=0
	local dlines={0,-1,1,-2,2,-3,3,-4,4,-5,5,-3333}
	local fing1 , fing2
	
	gl2=pane:GetLine(toplin)
	if not gl2 then gl2="" end
	
	local pik
	
	while rline<12 do
		rline=rline+1
		pik=toplin+dlines[rline]
		gl=pane:GetLine(pik) 
	
		--set the apoint when line1 not empty	
		if rline==1 and (string.find(string.sub(gl2,1,repls),"[^%w]+$") )
		then string.sub(gl2,1,repls) wordcy = repls end

		while gl and rline<8 and pik>=0 and pik<=endlin 
		and (not string.find(gl,"[%w]")) 
		do --loop until a line got, or out of lines
			if dlines[rline]<0 then
				dlines[2]=dlines[2]-1  dlines[4]=dlines[4]-1
				dlines[6]=dlines[6]-1  dlines[8]=dlines[8]-1 
				dlines[10]=dlines[10]-1  dlines[12]=dlines[12]-1 
			elseif (dlines[rline]>0) then
				dlines[3]=dlines[3]+1  dlines[5]=dlines[5]+1 
				dlines[7]=dlines[7]+1  dlines[9]=dlines[9]+1
				dlines[11]=dlines[11]+1 
			else
				if rline==1 then --set the apoint when line1 empty 
					wordcy=repls	
				end 
				rline=rline+1 
			end
			
			pik=toplin+dlines[rline]
			gl=pane:GetLine(pik)	
		end
		--got valid gl 
		if gl then
			local pss=pane:PositionFromLine(pik)
			--print(pik.."h"..gl)
			local igx=string.len(gl)
			while igx>0 do
				if notcmmt and shouldIgnorePos(pss+igx-1,pane,pane.Lexer) then  -- igx 1 = pos 0
					gl=gl:sub(0,igx-1)..gl:sub(igx+1,-1)
					--print(gl)
				end
			igx=igx-1  --abcdefg 
			end
		end
		if rline==1 then --get caretword details and subtract ending 
		
			if pane==editor then
				fing1 ="([%a$_][%w_]*[.]?[%w_]+)$"
				fing2 ="([%w#][%w][%w]+[.]?[%w][%w][%w]+)$"
			else
				fing1 ="([%w#][:%w][%w\\]*)"
				fing2 ="([%a$_][%w_]*[.]?[%w_]+)$"
			end
			
			if repls==reple and not wordcy then
				--print(string.sub(gl2,1,repls))
				local rs,re=string.find(string.sub(gl2,1,repls),fing1)
				if re then repls,reple = rs-1,re else
					rs,re=string.find(string.sub(gl2,1,repls),fing2)
					if re then repls,reple = rs-1,re else
						repls,reple= repls,reple
					end
				end
				wordcy=repls
			else
				repls=wordcy
			end	
	
			replx=string.sub(gl2,repls+1,reple)
			
			if not gl then gl="" end
			--print(":"..replx..":") 
			bl=string.sub(gl,reple+1,-1) if not bl then bl="" end
			gl=string.sub(gl,0,repls) if not gl then gl="" end
			
		elseif rline==3 then --add ending of rline1
			if gl then gl=bl.." "..gl
			else gl=bl end
		end
		
		
		local wnum=1	--reset at every new gl	
		if gl then --a readline got 
		
			--get words from line ignoring unwanted
			for word in string.gmatch(gl, "[%a$_][%w_:]*[.]?[\%w_\\]+") do 
				if word and not wset[word] then
					
					for i, unw in ipairs(unwanted) do
						if word==unw then word=nil end
					end
					if word then 
						preads[wnum] = word
						--print(word,wnum)	
						wnum=wnum+1  --wnum is words in pread
					end					   --pnum is words in placers 
				end
			end
			--get words from line ignoring unwanted
			for word in string.gmatch(gl, "[%w#][%w][%w]+[.]?[%w][%w][%w]+") do 
				if word and not wset[word] then
					
					for i, unw in ipairs(unwanted) do
						if word==unw then word=nil end
					end
					if word then 
						preads[wnum] = word 
						--print(word,wnum)	
						wnum=wnum+1  --wnum is words in pread
					end					   --pnum is words in placers 
				end
			end
			
			--put line find i 
			if rline==1 and preads[1] then --reverse list order of finds
				for i=wnum-1,1,-1 do
					if not wset[preads[i]] then
						wset[preads[i]]=true
			--trace(" || "..pnum.." "..wnum.." "..preads[i].." || ")
						placers[pnum]=preads[i]
						pnum=pnum+1
					end
				end 
			elseif preads[1] then
				for i=1,wnum-1 do
					if not wset[preads[i]] then 
						wset[preads[i]]=true
			--trace(" || "..pnum.." "..wnum.." "..i.." "..preads[i].." || ")
						placers[pnum]=preads[i] 
						pnum=pnum+1
					end
				end
			end
			
			wnum=1
		end --readed latest rline
	
	end --readed all rlines   rlinesall	
	--print("\ngl2 :"..gl2..": replx :"..replx..": x ",repls,reple)
	
	local ix=1 --go to match in placers or last  or
	while ix<pnum and replx~=placers[ix] do ix=ix+1 end
	
	--trace(" "..replx.." "..pnum.." "..ix.." ")

	if ix==pnum then ix =0 end 

	if ssback~=1 then
		ix=((ix%(pnum-1))+1)
	else
		ix=ix-1
		if ix==-1 then ix=pnum-1 end
	end

	ssback=nil --cheap hack to go backwards
	
	if ix==1 and replx~="" then placers[ix]="" end --blank on cycle 

	repls,reple= repls+botlnp,reple+botlnp 
	pane:SetSel(repls,reple) 
	pane:ReplaceSel(placers[ix])

	if wasseld then pane:SetSel(pane.CurrentPos-string.len(placers[ix]),pane.CurrentPos) end
	
	return false
end
