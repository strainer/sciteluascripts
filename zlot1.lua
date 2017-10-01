slide_Command("Line Delete|delSelLines|Ctrl+Shift+l")

local find = string.find 
local match=string.match
local gsub = string.gsub
local insert = table.insert 
local sub=string.sub

--typical locals
local tdum,tdee,swp  --tweedles, swapped
local tsline,tslpos  --thisline thislineposition
local tpath          --this path
local str            --a string
local pane           --the pane
local _,a,b,ua,ub      --transients
local hit, fpos, cnt --hit, found pos, count 

function delSelLines() --deletes lines containing selection
	pane=get_pane()
	local a,c =pane.Anchor,pane.CurrentPos
	if a>c then a,c=c,a end
	a=pane:PositionFromLine(pane:LineFromPosition(a))
	c=pane:PositionFromLine(pane:LineFromPosition(c)+1)
	if c<0 then c=pane.Length end
	pane:SetSel(a,c)
	pane:Clear()
	return true
end

function isfilepath2(str)
	
	local s=string.match((str or ""),"^[%s]*([%a]:[\\/][\\/%w.@~&%-_ ]+[%w.@~&-_])[%s]*$")
	
	if not s then return false end
	local e = io.open(s)
	if not e then return false end
	e:close()
	return s
end

function seemspath(str)
	local s=(str or ""):match("^[%s]*([%a]:[\\/][\\/%w.@~&%-_ ]+[%w.@~&-_])[%s]*$")
	return s
end

slide_Command("CopyPth|copypathq|Ctrl+p")
function copypathq()
	
	lasttap=thistap
	thistap=os.time()
	if lasttap then
		if lasttap>thistap-3 then
			cptaps=cptaps+1
		else
			cptaps=1
		end
	else
		cptaps=1
	end
	
	local bb=fhistory(nil,cptaps)
	editor:CopyText(bb[cptaps])
	cptaps=cptaps+1
end

slide_Command("Open|opensez|Ctrl+o")

function pathinStr(pline)
	local t=pline:match("([%a][%:][\\/][^;\(\"\':\>\/]+[%w])")
	if t and not isfilepath2(t) then
		t=pline:match(".*[%:].*([%a][%:][\\/][^;\(\"\':\>\/]+[%w])")
	end
	if t and not isfilepath2(t) then
		t=pline:match(".*[%:].*[%:].*([%a][%:][\\/][^;\(\"\':\>\/]+[%w])")
	end
	return t
end

function opensez(t)
	local pane=get_pane()
	
	if not t or t=="" then t=pane:GetSelText() end
	
	if not t or t=="" then 
		local tt=pane:GetLine(pane:LineFromPosition(pane.CurrentPos)) 
		t= pathinStr(tt)
		if not t then
			t=tt:match("([%w][^;\(\"\':\>]+[%w])[%s]*")
		end
		if not t then
			t="missing"
		end
	end
	--print(t)
	if isfilepath2(t) then
		scite.Open(t)
		return true
	else
		print ("\n-Not a file [ "..t.."]")
		tracePrompt()
		scite.MenuCommand(102) --idm_open
		return true
	end 
end

--scite_Command("|abbrevhk")
--quick note for an abbreviation catcher, to indent it

--function abbrevhk()
	--get term behind caret
	--match inside $[]
	--case this or that setting replacement
	--if no replacement, try the props
	--if replacement set, replace it and return false
	--if not return true
--end

--~ scite_Command("Open API|OpenAPIFile|Ctrl+Shift+n")
--~ function OpenAPIFile()
--~ 	scite.Open(props["APIPath"])
--~ end

slide_Command("Open Abrev|OpenAbrev|Ctrl+Shift+b")
function OpenAbrev()
	scite.Open(props["AbbrevPath"])
	return true
end

--~ scite_Command("Open Atrium|OpenAbrev|Ctrl+Shift+m")
--~ function OpenAbrev()
--~ 	scite.Open(props["AbbrevPath"])
--~ end

function exporthtml()
	exporters:SaveToHTML()
	print()
end

slide_Command("Slide down|slidemove 's'|Alt+/")
slide_Command("Slide up|slidemove|Alt+'")

function slidemove(smaller)
	
	if smaller=="s" then 
		local vis=isCursorVis(output) 
		scite.MenuCommand(424) 
		if vis then
			output:ScrollCaret()
		end
	else
		local vis=isCursorVis(editor)
		scite.MenuCommand(423) 
		if vis then
			editor:ScrollCaret()
		end
	end
	return true;
end

slide_Command("Toggle Terminal|toggterm|Ctrl+.")

function toggterm() --toggles terminal
	
	local ovis=isCursorVis(output)
--~ 	local evis=isCursorVis(editor)
	
	if get_pane()~=output then  --from editor
		
		--note time and fromeditor
		Slide.togtime=os.clock()
		scite.MenuCommand(421)   --421 just toggles focus
		output:ScrollCaret()

--~ 		output:GotoPos(output.CurrentPos)
	else --goto editor
		if (os.clock()-(Slide.togtime or -1000))<4 then 
			Slide.togtime=-1000
			output.CurrentPos,output.Anchor=output.Length,output.Length
			output:ScrollCaret()
			return true
		end
		
		if output.CurrentPos<output.Length then  -- floating upslide
			scite.MenuCommand(421)   --421 just toggles focus
			--replace with better
			editor:ScrollCaret()
		else
			--scite.MenuCommand(422)   --422 sets output size to small
			--output:ScrollCaret()
			scite.MenuCommand(421)   --421 just toggles focus
			editor:ScrollCaret()
			if ovis then output:ScrollCaret() end
		end
	end
	return true
end

slide_Command("line down|pushlinedown|Shift+Enter")

function pushlinedown()  --this doesnt do much really
	local pane=get_pane()
	
	if pane==output then --normal behaviour in output
		output:ReplaceSel(nlchar())
		return false end

	local clf,cla =poslinestfn()
	local clt=pane:textrange(clf,cla)
	local indy=match(clt,"([%s]*)" ) or ""--indent 
	
	if #indy==0 then
		local clf2,cla2 =poslinestfn(tc,editor,-1)
		clt=pane:textrange(clf2,cla2)
		indy=match(clt,"([%s]*)" ) or ""
	end
	
	pane:SetSel(clf,clf)
	pane:ReplaceSel( indy..nlchar())
	pane:SetSel(clf+#indy,clf+#indy)
	return true
end

---paste to river
slide_Command("Paste across|pasteinriver|Ctrl+Shift+m")
function pasteinriver()
	output:AppendText("\n")
	output:Paste()
	return true
end

--scite_Command("New Test|otonew|Ctrl+Alt+t")

function otonew() --cant style new untitled buffer ?
	scite.Open("")
	scite.MenuCommand(IDM_LANGUAGE + 9)

	undoact(editor)

	editor:AppendText(output:textrange(0,output.Length))
	editor:Colourise(0, editor.Length)
	
	undoact(editor)

	undoact(output)
	output:SetSel(0,output:PositionFromLine(output.LineCount-1))
	output:Clear()
	output:GotoPos(output.Length-1)
	undoact(output)
end

slide_Command("Quit|scitequit|Ctrl+Alt+z")

function scitequit()
	scite.MenuCommand(IDM_QUIT)
end


scite_Command("List BkMarks|dumpmarks")

--lists all bookmarks in command pane
function dumpmarks()
	print('\n- Bookmark list -')
	local lc=editor.LineCount
	local bufy=props["FilePath"]
	for li=0,lc do
		local t=editor:MarkerGet(li)
		if t==2 then trace(bufy..":"..(li+1)..":"..editor:GetLine(li)) end
	end
	tracePrompt()
end


slide_Command("Last position|goback|Ctrl+#")

--sends caret back to previous undo point or 2 before if same (toggles)
local gobp={}
function goback()
	local pane=get_pane()

	gobp[props["gg"..'FilePath']]=gobp[props['FilePath']]
	gobp[props['FilePath']]=pane.CurrentPos
	
	local gpos=pane.CurrentPos
	local tpos=pane.CurrentPos
	if pane:CanUndo() then pane:Undo()
		tpos=pane.CurrentPos
		if pane:CanUndo() then pane:Undo()
		tpos=pane.CurrentPos
		pane:Redo()
		end
		pane:Redo()
	end
	
	if tpos==gpos then
		pane:GotoPos(gobp[props["gg"..'FilePath']] or tpos)
	else
--~ 		gobp[props['FilePath']]=gobp[props["gg"..'FilePath']]
		if tpos==gobp[props['FilePath']] then tpos=gobp[props["gg"..'FilePath']] end
		pane:GotoPos(tpos)
	end

end

local function sendmess(pane,val)
	if pane==output then
		scite.SendOutput(val)
	else
		scite.SendEditor(val)
	end
end

function homeendkeyp( homek )
	local pane=get_pane()
	if homek then
		local edg=pane:PositionFromLine(pane:LineFromPosition(pane.CurrentPos))
		if	pane.CurrentPos== edg then 
			pane:GotoPos(0) 
		else
			sendmess(pane,2453)
		end
	else
		local edg=pane.LineEndPosition[pane:LineFromPosition(pane.CurrentPos)]
		if pane.CurrentPos==edg then
			pane:GotoPos(pane.Length) 
		elseif find(pane:textrange(pane.CurrentPos,pane.CurrentPos+1),"%s")
		and pane.CurrentPos==pane:PositionFromLine(pane:LineFromPosition(pane.CurrentPos))
		then
			sendmess(pane,2453)	
		else
			sendmess(pane,2451)
		end
	end
end

slide_Command("Home Key|homeendkeyp 1|Home")
slide_Command("End Key|homeendkeyp|End")    --stupid already configable

slide_Command("Leap up|fleap 1|Ctrl+g")
slide_Command("Leap up other|fleap 2|Ctrl+Shift+g")
slide_Command("Leap down|fleap 3|Ctrl+h")
slide_Command("Leap down other|fleap 4|Ctrl+Shift+h")

--~ function findupdownxe() 	findupdownx("n")      1  end  --up
--~ function findupdownxed() 	findupdownx("n",true) 3  end  --down
--~ function findupdownxo() 	findupdownx("y")      2  end
--~ function findupdownxod() 	findupdownx("y",true) 4  end

local twofind
local lastfind
local fclock

--quick jump back find in either pane
function fleap(m)

	--print(m)	
	local pane=get_pane()
	local pane2=pane
	local fdown
	if m==3 or m==4 then fdown=true end
	if m==2 or m==4 then if pane2==output then pane2=editor else pane2=output end end
	
	local ecp=pane.CurrentPos
	local eap=pane.Anchor
	if eap>ecp then eap,ecp=ecp,eap end

	local sely=pane:textrange(eap,ecp)
	if sely=="" then sely=get_word(pane) end

	if (sely or "")=="" then sely=lastfind else lastfind=sely end
	if (sely or "")=="" then return false end

	pane=pane2 --twist for otherpane
	ecp=pane.CurrentPos
	eap=pane.Anchor
	if eap>ecp then eap,ecp=ecp,eap end

	local fna,fnc
	
	if fdown then
		fna,fnc = pane:findtext(sely,0,ecp)
		if (not fna) and (not (twofind and (os.clock()-(fclock or 100000)>0.11))) then 
			twofind=true fclock=os.clock()
			return false 
		end
		
		if not fna then fna,fnc = pane:findtext(sely,0,0) 
			if fna==nil then print("\n+Couldnt find "..sely) tracePrompt() return false end
		end
	else
		--complicated upwards	
		fna,fnc = pane:findtext(sely,0,0)

		if fna==nil then print("\n+Couldnt find "..sely) tracePrompt() return false end

		local limi=eap-1
		if fna>=eap then
			if (not (twofind and (os.clock()-(fclock or 100000)>0.11))) then 
				twofind=true fclock=os.clock()
				return false 
			end	
			limi=pane.LineEndPosition[pane.LineCount-1]
		end

		local la,lc,lx  --last good find
		la=fna
		lc=fnc
		lx=0

		--~ 		if true then print("la "..la.." ,lc "..lc.." ,fna "..fna) end

		while fna and la<limi and lx<100 do
			la=fna --record last, and find next
			lc=fnc
			lx=lx+1
			fna, fnc = pane:findtext(sely,0,la+1,limi )
		end

		--~     if true then print("la "..la.." ,lc "..lc.." ,lx "..lx) end

		if fna==nil then
			fna=la fnc=lc
		end
	end
	
	twofind=nil
	pane:GotoPos(fna)
	pane:SetSel(fna,fnc)
	return true
end

--------

slide_Command("Term Select|innersel|Ctrl+i")

function innersel()
	local pane=get_pane()
	local e,s=caret_land(pane)
	pane:SetSel(s,e)
	return true
end

 --select usefull terms when pressed without selection
 --when pressed with selection complete terms and complete braks
 --if no expansion, then expand usefully
 --ss,ee = caret_land(pane,cp,"%s",true) 
				
function caret_land(pane,pin, gopatt, nord)
	pane = pane or editor
	pin = pin or pane.CurrentPos
	local simp=gopatt
	if gopatt then gopatt="[^"..gopatt.."]"
	else
		gopatt="[$%w%_%.]"        --gopatt is foodtext 
	end 
	local gopatt2="[$%w.:%_-+/*%^&|~@#;]"
	local gopatt3="[$%w.:%_%(%){}[%]-+/*%^&\\\?<>|~@#;]"
--~ 	local gopatt4="[$%w%s,.:%_%(%){}[%]-+/*%^&\\<>|~@#;]"
	local nopatt="  "
	
	local ginAn,ginCu,swp
	if pin then ginAn,ginCu=pin,pin end
	ginAn,ginCu,swp=pane.Anchor,pane.CurrentPos
	if ginCu<(ginAn or 0) then ginCu,ginAn=ginAn,ginCu  swp=true  end
	
	local anli=pane:LineFromPosition(ginAn)
	local plen=pane.Length
	
	if (ginCu-ginAn>4) and not simp and 
	(ginAn==pane:PositionFromLine(anli) and ( ginCu==pane:PositionFromLine(anli+1)
	or ginCu==pane.LineEndPosition[anli])) 
	or (ginAn==pane.LineEndPosition[anli] and ginCu==pane.LineEndPosition[anli+1]  )
	then
		if ginAn==pane.LineEndPosition[anli] then
			ginAn=pane:PositionFromLine(anli+1)
		end
		local iscom=shouldIgnorePos
		ginCu=pane.LineEndPosition[anli]
		while ginCu>ginAn and
		(find(pane:textrange(ginCu-1,ginCu),"%s") 
		or iscom(ginCu,pane,pane.Lexer) ) do
			ginCu=ginCu-1
		end
		
		while ginAn<ginCu and
		(find(pane:textrange(ginAn,ginAn+1),"%s") 
		or iscom(ginAn,pane,pane.Lexer) ) do
			ginAn=ginAn+1
		end
		
		if swp then ginCu,ginAn=ginAn,ginCu end
		return ginAn,ginCu
	end
	local tdum,tdee=ginAn,ginCu
	local linen=pane.LineEndPosition[pane:LineFromPosition(ginCu)]
	
	if tdum~=tdee then
		tdum,tdee=pleatrange(pane,tdum,tdee) 
	else
		tdum,tdee=spreadpos(pane,tdee,gopatt)
	end
	
	if simp then
		return tdum,tdee
	end
	
	if tdum==ginAn and tdee==ginCu 
	then _,tdee=spreadpos(pane,tdee,gopatt2) end
	if tdum==ginAn and tdee==ginCu 
	then tdum=spreadpos(pane,tdum,gopatt2) end

	if tdum==ginAn and tdee==ginCu then 
		if pane:textrange(tdee,tain(tdee+1,0,plen))==","
		or pane:textrange(tain(tdum-1),tdum)=="," then
			if pane:textrange(tdee,tain(tdee+1,0,plen))=="," 
			then 
				tdee=tdee+1
				_,tdee=spreadpos(pane,tdee,gopatt2)
			else 
				tdum=tdum-1
				tdum=spreadpos(pane,tdum,gopatt2)
			end
			tdum,tdee=pleatrange(pane,tdum,tdee)
		end
	end	
	
	if tdum==ginAn and tdee==ginCu 
	then _,tdee=spreadpos(pane,tdee,gopatt3)
		tdum,tdee=pleatrange(pane,tdum,tdee)	end
	if tdum==ginAn and tdee==ginCu 
	then tdum=spreadpos(pane,tdum,gopatt3) 
		tdum,tdee=pleatrange(pane,tdum,tdee) end

--~ 	if tdum==ginAn and tdee==ginCu 
--~ 	then _,tdee=spreadpos(pane,tdee,gopatt4,nopatt) end
--~ 	if tdum==ginAn and tdee==ginCu 
--~ 	then tdum=spreadpos(pane,tdum,gopatt4,nopatt) end
		
	
	if tdum==ginAn and tdee==ginCu then 
		tdee=tain(tdee+1,0,linen)
		--print(pane:textrange(tdee,tdee+1))
		while tdee<=linen and 
		pane:textrange(tdee-1,tdee)==pane:textrange(tdee,tdee+1)
		do	tdee=tdee+1  end
		
		local rd=tdee
		--print("\n"..pane:textrange(tdum,tdee))
		_,tdee=spreadpos(pane,tdee,gopatt2)
		tdum,tdee=pleatrange(pane,tdum,tdee)
		if tdum==ginAn and tdum>0 and tdee==rd
		then 
			tdee=ginCu  tdum=tdum-1
			while tdum>0 and 
			pane:textrange(tdum-1,tdum)==pane:textrange(tdum,tdum+1)
			do	tdum=tdum-1  end
	
			tdum=spreadpos(pane,tdum,gopatt2)
			--print("\n"..pane:textrange(tdum,tdee))
			tdum,tdee=pleatrange(pane,tdum,tdee) 
		end
	end
	
	if swp then tdum,tdee=tdee,tdum end 
	
	if not nord and tdum>tdee then tdee,tdum=tdum,tdee end
	
	return tdum,tdee
end

function spreadpos(pane,inpos,patt,nopatt) --origin is 0, chars come after pz 

	local tsline=pane:LineFromPosition(inpos)
	local tslpos=pane:PositionFromLine(tsline)
	local a, b= inpos-tslpos+1, inpos-tslpos+1	
	local st=pane:GetLine(tsline) --nil if on lastline
	--print(st)
	if st==nil then --if last line, fix and return
		return inpos,inpos
	end
 
	while a<=#st and find(sub(st,a,a) ,patt) 
	and not (nopatt and find(sub(st,a,a+1) ,nopatt)) do
		a=a+1
	end --first white before pin, b = 0 to pin-1, or pin if none

	while ((b>1) and (b<=#st)) and find(sub(st,b-1,b-1),patt)
	and not( nopatt and find(sub(st,tain(b-2,0),tain(b-1,0)) ,nopatt)) do
		b=b-1
	end --first white before pin, b = 0 to pin-1, or pin if none
	return b-1+tslpos,a-1+tslpos
end

function pleatrange(pane,an,cu)

	local jack= 
	{ ['['] = { ['n']=  1, ['c']= '[' },
		[']'] = { ['n']= -1, ['c']= '[' },
		['('] = { ['n']=  1, ['c']= '(' },
		[')'] = { ['n']= -1, ['c']= '(' },
		['{'] = { ['n']=  1, ['c']= '{' },
		['}'] = { ['n']= -1, ['c']= '{' },
		}

	local nn,cc='n','c' 
	
	local iscom=shouldIgnorePos
	local isquo=isquoted
	
	local lex=pane.Lexer
	local nocom = not( iscom(an,pane,lex) and iscom(cu,pane,lex) )

	local plen=pane.Length
	local ch,hunt
	local face,dee=an,cu
	
	local covdlen=0
	local acjack,acjacklev ="",0
	
	local db=200000
	
	local function backjack()
		rear=face-covdlen
		
--~ 		print("\nBeginBack "..rear,face)
		
		while acjacklev~=0 and rear>-1 and db>0 do 
			db=db-1
			
			if (nocom and iscom(rear,pane,lex)) 
			then ch=" " else 
				ch=pane:textrange(rear,rear+1)
			end --just blanking comments 
			
--~ 			trace("-"..acjack..acjacklev..ch.."|")
			
			if true and (ch=="'" or ch=='"') then
			--weve run into a quote going back,
				
				--if it goes back, just extend the rear,
				if isquo(rear-1,pane,lex) then
					while(isquo(face-covdlen-1,pane,lex)) do
						covdlen=covdlen+1
					end
				else
					while(isquo(face-covdlen+1,pane,lex)) do
						covdlen=covdlen-1
					end
					acjack="" acjacklev=0 
					if covdlen<0 then face=face-covdlen end
--~ 					print("\nEndBack quo:")
					return
				end
				--if it goes forward extend forward 
				--reset jack and restart face in front of it
			end
			
			if jack[ch] and (jack[ch][cc]==acjack) then   --huntback
				acjacklev=acjacklev+jack[ch][nn]
				--trace("*"..acjacklev.."*")
			end
			
			covdlen=covdlen+1	
			rear=face-covdlen
		end
--~ 		print("\nEndBack:"..rear,face.."\n |")
		return
	end
	
--~ 	print("\nBeginFor:"..face.." |")
	
	while (db~=0) and (face<plen) and (face<dee or acjacklev~=0) do
		
		db=db-1
		covdlen=covdlen+1
		
		if (nocom and iscom(face,pane,lex))
		then ch=" " else 
			ch=pane:textrange(face,face+1)	
		end
--~ 		trace("+"..acjack..acjacklev..ch.."|")  --focus is range pos0 , pos0+1
		--   ""

		if true and (ch=="'" or ch=='"') then
		--weve run into a quote going back,
			
			--if it goes back, just extend the rear,
			if isquo(face-1,pane,lex) then
				ncov=0
				while(isquo(face-ncov,pane,lex)) do
					ncov=ncov+1
				end
				if ncov>covdlen then covdlen=ncov end -- should be a given
				acjack=""  acjacklev=0  ch=" "
			else 
				--if in goes forward just extend forward and face
				while(isquo(face+1,pane,lex)) do
					face=face+1  covdlen=covdlen+1
				end
				ch=" "
--~ 				print("\nEndforw quo:")
			end
		end

		if (jack[ch] and acjacklev==0 ) or (jack[ch] and jack[ch][cc]==acjack) 
		then 
			if acjacklev==0 then
				acjack=jack[ch][cc]
				acjacklev=jack[ch][nn]
				--print("JJJ"..acjack,acjacklev.."JJJ")
				if acjacklev==-1 then
					backjack(jack[ch].cc)
				end
			else
				acjacklev=acjacklev+jack[ch][nn]
				if acjacklev==0 then acjack="" end
			end
		end
		
		face=face+1
	end
	
	--print(db)
	return face-covdlen , face
end

--bruce dobson's fix indentation

function fixIndentation()
	local tabWidth = editor.TabWidth
	local count = 0
	if editor.UseTabs then
		local preindentSize=-1
		-- for each piece of indentation that includes at least one space
		for m in editor:match("^[\\t]*[ ]+[\\t]+", SCFIND_REGEXP) do

			local indentSize = editor.LineIndentation[editor:LineFromPosition(m.pos)]
			
			if string.find(m.text,"%{[\\t ]*$") then
				preindentSize=preindentSize+tabWidth
			elseif string.find(m.text,"^[\\t ]*%}[\\t ]*$") then
				preindentSize=preindentSize-tabWidth
			end
			
			if preindentSize>-1 then indentSize=tain(indentSize,0,preindentSize) end
			
			local spaceCount = math.mod(indentSize, tabWidth)
			local tabCount = (indentSize - spaceCount) / tabWidth
			local fixedIndentation = string.rep('\t', tabCount) .. string.rep(' ', spaceCount)

			if fixedIndentation ~= m.text then
				m:replace(fixedIndentation)
				count = count + 1
			end
		end
	else
		-- for each piece of indentation that includes at least one tab
		for m in editor:match("^[\\t ]*\t[\\t ]*", SCFIND_REGEXP) do
			-- just change all of the indentation to spaces
			m:replace(string.rep(' ', editor.LineIndentation[editor:LineFromPosition(m.pos)]))
			count = count + 1
		end
	end
	return count
end
		
fixind = fixIndentation
-----------------------------------------------------
-- Strip Trailing Spaces
-- Filename endings set here or in scite properties:
-- Luax.StripTrailSpaceEnds=.lua|.foo|readme
-- Luax.StripTLeaveEmpties=1   to leave empty lines
-- Luax.StripTReportStrips=1   to leave empty lines

local function isTrailingFile()
	-- register here the extensions (endings) that shall be parsed
	tt=props["luax.StripsTrailSpaceEnds"].."|"
	if tt=="|" then tt=".lua|.py|" end

	return find(tt, ((match( props["FilePath"],"[.].+$") or "-").."|") )
end


--~ function safeline()
--~ function safepos()

function fixshftab()
	p=get_pane()
	if p.Anchor~=p.CurrentPos then
		local a,c=p.Anchor, p.CurrentPos
		if a<c then
			c=p.LineEndPosition[p:LineFromPosition(c)]
			a=p:PositionFromLine(p:LineFromPosition(a))
		else
			a=p.LineEndPosition[p:LineFromPosition(a)]
			c=p:PositionFromLine(p:LineFromPosition(c))
		end
	end
	return false
end

--~ scite_Command("fixtab|fixshftab|Tab")
--~ scite_Command("fixtab2|fixshftab|Shift+Tab")

function stripTrailSpaces()
	local ed=editor
	--(dunno syntax for testing props simply)
	local LeaveEmptyLines=true
	if tonumber(props['luax.StripsTLeaveEmpties'])==0 then LeaveEmptyLines=false end
	local ReportStrips=true
	if tonumber(props['luax.StripsTReportStrips'])==0 then ReportStrips=false end

	if not isTrailingFile() then return end
	noteSelection()
		 
	local icount=fixIndentation()

	local hit,fpos,cnt = -1, 0,  0
	
	hit,fpos=ed:findtext("[\t ][\t ]+$", SCFIND_REGEXP, hit+1 )
	while hit do

		if LeaveEmptyLines and ed:PositionFromLine(ed:LineFromPosition(hit))==hit
		then
			hit=fpos --skip
		else
			if hit+1~=fpos then ed:remove(hit+1,fpos) end
			cnt=cnt+1
		end

		hit,fpos=ed:findtext("[\t ][\t ]+$", SCFIND_REGEXP, hit+1 )
	end

	restoreSelection()
	
	if ReportStrips and cnt>5 then
		trace("\n- "..cnt.." runs of trailing spaces were stripped")
	end

	if ReportStrips and icount > 5 then
		trace("\n- Fixed indentation for " .. icount .. " line(s).")
	end

	if ReportStrips and (icount>0 or cnt>0) then
		print() tracePrompt()
		output:ScrollCaret()
	end
end
scite_OnBeforeSave( stripTrailSpaces )

--abcd ef abcd ef abcd ef

-- lua.org globals.lua
-- show all global variables

-- Print contents of `tbl`, with indentation.
-- `indent` sets the initial level of indentation.
function dumptable(tbl, indent)
	tbl=tbl or _G
	indent = indent or 0
	for k, v in pairs(tbl) do
		formatting = string.rep("  ", indent) .. k .. ": "
		if type(v) == "table" then
			print(formatting)
			if indent>6 then 
				print("TooDeepTable")
			else
				if v==_G then print("_G!!!") else
					dumptable(v, indent+1)
				end
			end
		elseif type(v) == 'boolean' then
			print(formatting .. tostring(v)) 
		else
			print(formatting .. type(v))
		end
	end
end

function shallow_clone(t)
	local t2 = {}
	for k,v in pairs(t) do t2[k] = v end
	return t2
end

function deep_clone(obj, seen)
	if type(obj) ~= 'table' then return obj end
	if seen and seen[obj] then return seen[obj] end
	local s = seen or {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
	return res
end

function bug(name)
	if not Slide['dobug'] then return end
	
	local info = debug.getinfo(2)

	if info.what == "C" then   -- is a C function?
		print("C function debug?:")
		return
	end
	local value, found

	-- try local variables
	local i = 1
	while true do
		local n, v = debug.getlocal(2, i)
		if not n then break end
		if n == name then
			value = v
			found = true
		end
		i = i + 1
	end
	if found then return value end

	-- try upvalues
	local func = info.func
	i = 1
	while true do
		local n, v = debug.getupvalue(func, i)
		if not n then break end
		if n == name then return v end
		i = i + 1
	end
	local val=getfenv(func)[name]
	if output.CurrentPos~=output:PositionFromLine(output.Length) then
		print()
	end
	print(string.format("%s:%d:%s-%s",
				info.short_src, info.currentline,info.namewhat or "glob",info.name or "anon"))
	print(string.format("%s='%s'",name,val))
end
