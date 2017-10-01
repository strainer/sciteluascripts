sDirCmd="dir/w"

local doingeliza=false
local insert=table.insert
local sub = string.sub
local match = string.match
--local tain=tain


function iocatfile(filen,pane,dir,src)
	print() local filenm
--~ 	print(filenm,dir)
--~ 	if true then return end
	if not string.match(filen,"^[%a][%:][\\][^\\]") then
		filenm=dir.."\\"..filen
	else
		filenm=filen
	end
	local tt
	local sc ="output"
	if pane==editor then sc="'"..props['FileNameExt'].."'" end
	if src=="clip" then sc="clipboard" end
	
	local fio,msg = io.open(filenm, "r")
	--if msg then print(msg) return end
	if fio then
		fio:close()
		fio,msg = io.open(filenm, "ab")
		if msg then print(msg) end
		print("-Appending "..sc.." to "..filenm)
	else
		fio,msg = io.open(filenm, "wb")
		if msg then print(msg) end
		print("-Copying "..sc.." as "..filenm)
		tt=true
	end
	if src~="clip" then 
		fio:write(pane:textrange(0, pane.Length))
	else
		fio:write(foreclip(0))
	end
	fio:close()
	if tt and pane==editor and filen~="temp" then
		scite.Open(filenm)
		tracePrompt("Li,"..props['FileName'].." ~"
			..string.match(filen,"[^.]*"),nil,1) 
		scite.MenuCommand(421)
		return true
	end	
end


function prevline(pane,pos)
	local l=pane:LineFromPosition(pos)
	if l>0 then l=l-1 end
	return l
end

function linefnp(pos,pane)
	pane=pane or editor
	pos = pos or pane.CurrentPos
	return pane.LineEndPosition[pane:LineFromPosition(pos)]
end

function poslinestfn(cp,pane,off,ln) --rtrns ps: lineSt, linefn, line
	off= off or 0
	pane=pane or editor 
	cp=cp or pane.CurrentPos
	ln=ln or pane:LineFromPosition(tain(cp,0,pane.Length))
	ln=tain(ln+off,0,pane.LineCount)
	return  pane:PositionFromLine(ln),
					pane.LineEndPosition[ln],
					ln
end 

function undoact(pane)
	--pane:EndUndoAction()
	--pane:BeginUndoAction()
end

function tain(v,bot,top)  --contain v=tain(v,10,100)
	bot=bot or 0
	if v<bot then v=bot end
	if top and v>top then v=top end
	return v
end
		
function prints(txt)
	while string.find(txt, "\n") do
		trace(string.sub(txt, 0, string.find(txt, "\n")))
		--output:GotoPos(output.CurrentPos+5) make a sleep
		txt=string.sub(txt, string.find(txt, "\n")+1,-1)
	end
	if string.len(txt)>0 then trace(txt) end
end

function rtrace(s,up,ins)
	if not up then up=0 end
	local ol=output:LineFromPosition(output.CurrentPos)-up
	if ol<0 then ol=0 end
	local lee
	if ins then lee=output:PositionFromLine(ol)
	else lee=output.LineEndPosition[ol] end
	output:SetSel( output:PositionFromLine(ol),lee )
	output:ReplaceSel(s)
end

function uptrace(txt,upmv,updl) 
	upmv = upmv or 1  updl= updl or 0

	output:SetSel(
		output.LineEndPosition[
		tain(output:LineFromPosition(output.Length)-(upmv+updl),0) ],
		output.LineEndPosition[
		tain(output:LineFromPosition(output.Length)-upmv,0) ]
	)
	output:ReplaceSel(txt)
	output.CurrentPos, output.Anchor= output.Length, output.Length
	output:ScrollCaret()
end

function tracePrompt(a,b,c) --aft str,fore str, dirsup
	a=a or "" 
	b=b or ""
	trace( b..getdirectory(nil,nil,c).."; "..a )
	output:ScrollCaret()
	output:EnsureVisible(output.LineCount-1)
end

function closebuf(fp)
	local s=props["FilePath"]
	Slide['justclosing']=true
	scite.Open(fp)
	local pause=editor:GetCurLine()
	scite.MenuCommand(105)
	Slide['justclosing']=false
	if s~=fp then scite.Open(s) end
	return
end


function dircomp(a,b)
	local ap= match(a or" ","^(.-)[^\\]*$")
	local bp= match(b or" ","^(.-)[^\\]*$")
	return ap< bp
end

function drivcomp(a,b)  --driveletter
	local ap= match(a or" ",".") or ""
	local bp= match(b or" ",".") or ""
	return ap< bp
end

function driv1comp(a,b)  --drive w direcory len
	local apa= match(a or" ",".") or ""
	local bpa= match(b or" ",".") or ""
	local ap= match(a or" ","^(.-)[^\\]*$") or ""
	local bp= match(b or" ","^(.-)[^\\]*$") or ""
	return (apa==bpa) and (#ap< #bp) 
end

function driv2comp(a,b)  --drive w direcory len and alpha
	local apa= match(a or" ",".") or ""
	local bpa= match(b or" ",".") or ""
	local ap= match(a or" ","^(.-)[^\\]*$") or ""
	local bp= match(b or" ","^(.-)[^\\]*$") or ""
	return (apa==bpa) and (#ap== #bp) and (ap<bp) 
end



function lencomp(a,b)
	local ap= match(a or" ","^(.-)[^\\]*$")
	local bp= match(b or" ","^(.-)[^\\]*$")
	return #ap< #bp
end

function ldircomp(a,b)
	local ap= match(a or" ","^(.-)[^\\]*$")
	local bp= match(b or" ","^(.-)[^\\]*$")
	return (#ap== #bp) and (ap<bp) 
end

function filcomp(a,b)
	local af= match(a or" ","^.-([^\\]*)$")
	local bf= match(b or" ","^.-([^\\]*)$")
	return af<bf
end


spaceS=[[                                                                                                                                                                                                                        ]]

local ntSel

function noteSelection(pane)
	pane=pane or editor
	local c,a=pane.CurrentPos , pane.Anchor
	local swp=c<a
	if swp then a,c=c,a end
	local cl,al=pane:LineFromPosition(c) , pane:LineFromPosition(a)

	local ntSel =
	{ ['topl'] =pane.FirstVisibleLine,
		['acol'] =a -pane:PositionFromLine(al),
		['aline']=al,
		['ccol'] =pane.LineEndPosition[cl]-c,
		['cline']=cl,
		['swp']=swp,
		['same']= cl==al		}
		
	Slide['nt']=ntSel
end

function restoreSelection(pane)
	local ntSel=Slide['nt']
	pane=pane or editor
	
	pane.Anchor =
	tain(ntSel.acol+pane:PositionFromLine(ntSel.aline),	0
	, pane.LineEndPosition[ntSel.aline])
	if ntSel.same then 
		pane.CurrentPos = pane.Anchor
	else
		pane.CurrentPos =
			tain(pane.LineEndPosition[ntSel.cline]-ntSel.ccol,	0
			,pane.LineEndPosition[ntSel.cline])	
		if ntSel.swp then pane.Anchor,pane.CurrentPos=pane.CurrentPos,pane.Anchor end
	end
	pane.FirstVisibleLine=tain(ntSel.topl)
end

function nlchar()
	if editor.EOLMode==0 then return "\r\n" end
	if editor.EOLMode==1 then return "\r" end
	return "\n" 
end

function isCursorVis(pane)
	local fst=pane.FirstVisibleLine
	local crr=pane:LineFromPosition(pane.CurrentPos)
	
	local r=((crr-fst)*100)/(pane.LinesOnScreen+0.1)
	if r<0 or r>1 then r=nil end
	return r 
end

function pairscopy(t,t2)
	local t2 = t2 or {}
	for k,v in pairs(t) do t2[k] = v end
	return t2
end

--local function string:unconcat(sep)
function unConcat(hay, sep)
    
	local fi, ult, sep, tbl, pattern = 1, 1, sep or "", {}

  if #sep>1 then --slower multichar pattern separator
  
    local aa,cc= string.find(hay,sep) 
    local dd=0 
    while cc do
      tbl[#tbl+1]=hay:sub(dd,aa-1)
      dd=cc+1
      aa,cc= string.find(hay,sep,dd)
    end
    tbl[#tbl+1]=hay:sub(dd)
    
    return tbl
  end
  
  --fast single char non-pattern separator 
	if sep~="" 
	then pattern = string.format("([^%s]*)[%s]?", sep,sep)
	else pattern ="(.)" end
	
	if hay:sub(#hay-#sep+1)~=sep 
	then ult=0 end
	
	local function cc(c)  tbl[fi] = c  fi=fi+1  end
	hay:gsub(pattern, cc)
	
	if ult==0 then tbl[#tbl]=nil end
	return tbl
end


function truthTab(self, sep)
local fi, ult, sep, fields, pattern = 1, 1, sep or "", {}

if sep~="" 
then pattern = string.format("([^%s]*)[%s]?", sep,sep)
else pattern ="([^%s]+)" end

if self:sub(#self-#sep+1)~=sep 
then ult=0 end

local function cc(c)  fields[c] = true  end
self:gsub(pattern, cc)

if ult==0 then fields[#fields]=nil end
return fields
end

--buffer ring---------------------------------------
--[[
local bufring={}
local ringc=0
local iniswitch

function unringc()
	ringc=(ringc+63)%64
end

function retbuffs(li)
	local cb=0
	local bb,bbb={},{}
	for i=ringc+63,ringc+2,-1 do
		local b=bufring[(i%64)+1]
		if b and not bb[b] then 
			bb[b]=true insert(bbb,b)
			cb=cb+1 
			if li and cb>li then break end
		end
	end
	return bbb
end
]]
-----------------------------------

math.randomseed(os.time())

function do_enter() 
	
	if editor:AutoCActive() then return false end
	
	if output.Focus then
		if output:AutoCActive() then return false end
		noteSelection()
		return m_readline()
	end 

	local cp=editor.CurrentPos
	local ap,ep,lnn=poslinestfn(cp,editor)
	local bt=editor:textrange(ap,cp)
	
	--eat trailing whitespace to fix auto indent after newline
--~   if string.find( string.sub(ct,(cp-ap)) , "%s+") then
--~ 	  ct=string.sub(ct,(cp-ap))
--~ 		editor:remove(cp,ep)
--~ 	end

  local ind,oud=0,0
	
	for _ in string.gfind(bt, "%{") do ind=ind+1 end
	for _ in string.gfind(bt, "%}") do ind=ind-1 end
	if string.match(bt,"^%s*%}")  then ind=ind+1 end

	local mt=string.match(bt,"^%s*%/%/%/?%~?%s*") or string.match(bt,"^%s*") or ""
--~ 	if mt then mt= string.sub(mt,1,cp-ap) end
	
	while ind<0 do 
	  if     string.sub(mt,1,1)=="\t" then   mt=string.sub(mt,2)
	  elseif string.sub(mt,1,2)=="%s%s" then mt=string.sub(mt,3)
	  else ind=0 
	  end
	  ind=ind+1
	end

	if ind>0 then  mt=string.sub("\t\t\t\t\t\t\t\t\t\t",1,ind)..mt end
		
	local nlch=nlchar()
	
	editor:insert(cp,nlch)
	editor.CurrentPos=cp+#nlch
	editor.Anchor=editor.CurrentPos

	if #mt~=0 then
		editor:insert(editor.CurrentPos, mt  )
		editor.CurrentPos=editor.CurrentPos+#mt
		editor.Anchor=editor.CurrentPos
	end
	
	editor:EnsureVisible(lnn+1)
	editor:ScrollCaret()
	return true
	
end


function indenthook()
	local indd=indent_in_line(editor,editor.CurrentPos)
end


function getoutdirs(frst)
	local dr,drs,gotdr=nil, {[1]=frst}, { [frst]=true }
	local pz=output.Length
	repeat 
		dr,pz=getdirectory(output,pz)
		if not gotdr[dr] then
			gotdr[dr]=true
			table.insert(drs,dr)
		end
	until pz<5
	return drs
end

function getofiles(n)
	local fr,frs,gotfr=nil, {}, {}
	local pz=poslinestfn(output.Length,output)
	repeat 
		fr,pz=getofile(output,pz)
		if fr and not gotfr[fr] then
			gotfr[fr]=true
			table.insert(frs,fr)
		end
	until (not fr) or (pz<5) or (#frs==n)
	return frs
end

function getdirectory(pane,tpos, nid) --pane,cp,ups
	nid=nid or 0
	pane =pane or output
	tpos=tpos or pane.CurrentPos
	local lks=pane:LineFromPosition(tpos)-1 --this is -ve safe
	local diza =false
	while nid~=-1 and lks>-1 do
		diza=false 
		tlk=pane:textrange(pane:PositionFromLine(lks),pane.LineEndPosition[lks])
		diza=tlk:match("[%>]([%a][%:][\\/][^\(\"\':\>]+)[%;]")
--~ weirdbug!!		print("ddd",tlk,diza,"ddd")
		if not diza then diza=string.match(tlk,"^%s*Directory.of.([^\n\r]+)") 
		end
		if diza then nid=nid-1 end
		lks=lks-1
--~ 		print("\n"..(diza or "f").." "..nid)
--~ 		print(tlk)
	end
	return (diza or props['FileDir']) , pane:PositionFromLine(lks+1)
end

function getdirectory2(pane,tpos, nid) --pane,cp, skipfinds

	nid=nid or 0
	pane =pane or output
	tpos=tpos or pane.CurrentPos
	local lks=pane:LineFromPosition(tpos)-1 --this is -ve safe
	local diza =false
	while nid~=-1 and lks>-1 do
		diza=false 
		tlk=pane:textrange(pane:PositionFromLine(lks),pane.LineEndPosition[lks])
		diza=tlk:match("^[%>]?([%a][%:][\\/][^\(\"\':\;>]+[%w])[\\/;]")
		if not diza then diza=string.match(tlk,"^%s*Directory.of.([^\n\r]+)") 
		end
		if diza then nid=nid-1 end
		lks=lks-1
	end
--~ 	if not diza then print("sent fildir") end

	return (diza or props['FileDir']) , pane:PositionFromLine(lks+1)
end

local makoot=(math.random(4,18)*math.random(7,10)) 
	--makoot random sayings...
local function sayrandie(ppos,gpos)
	makoot=makoot+(math.random(0,4)*math.random(0,4))
	if(makoot>240) and not upscreen then
		makoot=(math.random(2,14)*math.random(4,7))
		local inatp= poslinestfn(ppos,output,-1) 
		local klen=#randomk-1  --my magicD random distribution...
		local klen12a,klen12b=math.floor(klen/2),math.floor((klen+1)/2)	
		local c=math.floor(
		(
		(math.abs(math.random(0,klen12b)-math.random(0,klen12a))+klen12a)*2
		+math.random(0,klen))
		/3) 
		local zum="-:-   ((-(-_(-_-)_-)-))   -:-\n"..randomk[c+1]
		output:insert(inatp,zum)
		output:GotoPos(gpos+#zum)
		return true
	end
end

befr=-5


function bjumper(f,n)
	local bfoc=output.Focus
	scite.Open(f)
	editor:GotoPos(editor:PositionFromLine(tain(n-1)))
	
	MARK_LISTJUMP=6
	editor:MarkerSetBack(MARK_LISTJUMP, 0x092939)
	editor:MarkerSetFore(MARK_LISTJUMP, 0x2288BB)
	editor:MarkerAdd(tain(n-1),MARK_LISTJUMP)
	if bfoc and editor.Focus then scite.MenuCommand(421) end
	return true
end

function jjumper(readln,cp)

	local f,n=readln:match("([%w_].-):([%d]+):")
	if f then
		if not f:match("^[%a]:") then
			local q=getofile(output,cp,0)
			if q then f=q end
		end
		return bjumper(f,n)
	end
end

function m_readline()
	
	local pane=output
	local cp = pane.CurrentPos
	local lanc,lend,le=poslinestfn(cp,pane)
	undoact(pane)
	
	local readln=pane:textrange(lanc,lend)
	
	if readln:find("^#") or readln:find("^[%s]*[!?]") then return end
	
	--splits accidental mssgs from prmpt
	if readln:find("^[>]?[%a][%:][%\\/][^\(\"\':%>]+[%;][%s]*[%a][:][%\\/][^\(\"\':%>]+[:][%d]+[:]") then
		local _,pp=readln:find("^[>]?[%a][%:][%\\/][^\(\"\':%>]+[%;][%s]*")
		pane:insert(lanc+pp, "\n")
--~ 		pane:insert(pane.LineEndPosition[pane:LineFromPosition(lanc+pp+1)],"\n")
		pane:GotoPos(pane.LineEndPosition[pane:LineFromPosition(lanc+pp+1)])
		return
	end
	
	--fills empty prompt, toggles others
	local promDir=readln:match( "^([%a][%:][%\\/][^\(\"\':%>]+)[%;][%s]$" )
	
	if promDir then
		local gm2=props['FileDir']
		if (os.time()-(befr or -5))<5
		then 
			local bfs=getoutdirs(gm2)
			for i=1,#bfs-1 do
				if promDir==bfs[i] then
					gm2=bfs[i+1]
				end
			end
			if gm2=="." then gm2=props['FileDir'] end
		end
		uptrace("\n"..gm2.."; ",0,1)
		befr=os.time()
		return true
	else
		promDir=props['FileDir']
	end

	local upscreen=false  --non empty lines below current
	local linesupp=pane:LineFromPosition(pane.Length)-pane:LineFromPosition(pane.CurrentPos)
	if linesupp>20 then upscreen=true
	else --check for whitespace
		if linesupp>0 and string.find(pane:textrange(pane.CurrentPos,pane.Length),"[%S]")
		then upscreen=true
		end
	end

	--or not (readln:find("[%;%(%)%,%>%=]") or readln:find("^[^.]*.[^:]*:[^:]*:")) 
	--do directory type navs
	if upscreen then 
		
		local custp,la,lb,lf=readln:match("(Between lines )(%d+) and (%d+) in (.+)")
		if custp then
			scite.Open(lf)
			editor:SetSel(editor:PositionFromLine(la-1),editor:PositionFromLine(lb))
			editor:GotoPos(editor:PositionFromLine(la-1))
			return true
		end
		local pane=output
		local formpath=readln:match(".-%-[-~]%s%[(%w.+)%s%]$")
		local nik=pane:textrange(cp-1,cp+1)
--~ 		if true then
--~ 			print("\n>"..nik.."< "..readln..(formpath or "shit"))
--~ 			return true
--~ 		end
		if formpath then	
			if nik=="--" and formpath then
				wdroprec(formpath)
			end
			if nik=="-~" and formpath then
				closebuf(formpath)
			end
			if formpath and (nik=="-~" or nik=="--") then
				pane:SetSel(pane:PositionFromLine(le),pane:PositionFromLine(le+1))
				pane:ReplaceSel("")
				pane:GotoPos(tain(cp,0,pane.Length))
				return true
			end	
			scite.Open(formpath)
			if editor.Focus then scite.MenuCommand(421) end
			return true
		end

		local boady,gotdirectory
		gotdirectory=getdirectory(output)

		if not readln:match(":[%d]*:") then
			local ss,ee = caret_land(pane,cp,"%[%]",true)
			if ss then carbrak=pane:textrange(ss,ee) end
			boady=readln:match("[%<]+DIR[%>]+[%s]+([%S][^\n\r]*)")
			if boady or readln:find("["..carbrak.."]",1,true) then --do remaining directory nav
				boady=boady or carbrak
				if gotdirectory then
					trace("\n"..gotdirectory.."\\"..boady.."; "..sDirCmd)
					return false
				end
			end
		end
		
		--do scite.open or multi column shuffling
		local normp=readln:match("^(.*[^%s])%s*$")
		if normp and normp:find("%s%s") then                --long dir file name pattern
			normp=readln:match("^[%d][%d].[%d][%d].-:[%d][%d].-[%d] (.*)$") end
		
		if not (readln:find("^[%s]*[-+>!?#]") ) then 

			if jjumper(readln) then return true end	
			
			boady=normp or pane:textrange(caret_land(pane,cp,"%s",true))
			
			local noopens=truthTab("exe com mp3 bmp jpg jpeg gif lnk")
			if boady and not noopens[(string.lower(boady):match("[^.]*$"))] then
				--print("\n"..gotdirectory.."\\"..boady.."   "..boady:match("[^.]*$") )
				if not boady:match("^[%a]:") then
					boady=gotdirectory.."\\"..boady end
				scite.Open(boady)
				scite.MenuCommand(421)
				return true
			end
			
			--print(boady)
			--if true then return true end
			local sx,ex = boady:find("[%w]+[%.][%w]+")
			local sy,ey = readln:find(boady,1,true)
			if sx and #readln>(#boady+3)
				and not readln:find("[%:%/%,]")	then
				if sy>1 then pane:insert(ss, "\n") ee=ee+1 le=le+1 end
				if ey<#readln then
					pane:insert(ee, "\n")
					pane:insert(ee+1,string.sub(spaceS,1,#boady))
				end
				local u,v=pane:PositionFromLine(le-1),pane.LineEndPosition[le-1]
				if not string.find( pane:textrange(u,v),"[%w]") then
					pane:SetSel(u,pane:PositionFromLine(le))
					pane:ReplaceSel("")
					le=le-1
				end

				pane:SetSel(pane:PositionFromLine(le),pane:PositionFromLine(le))
			end
		end

	--put cwd in upscreen hits
		if not (readln:find("^[%s]*[%a]:") or readln:find("^[^.]*.[^:]*:[^:]*:"))  then
			if props['FileDir']~=gotdirectory then
				pane:insert(pane:PositionFromLine(le),gotdirectory.."\\")
			end
			pane:GotoPos(pane.LineEndPosition[le])
			return false
		end
		return false
	end 
	
	--finnished upscreen
	local cp2= pane.LineEndPosition[le]
	
	--puts nl at end of current line for scite nl handling
	pane:GotoPos(cp2) --output:ReplaceSel("\n")
	--
	local inp=readln

--~ 	  print(inp)
	local ia,ib=string.find(inp,"^[^%;]*;[%s]*")
	if ia then inp=inp:sub(ib+1) end --remove prompt
--~ 	  print(inp)
	local il=string.len(inp)
	ia,ib=string.find(inp,"[%s]*$")
	if ia then inp=inp:sub(1,ia) end  --remove whitespace
--~ 	  print(inp)

	local MyBreevies={
		['d']='dir/w', ['s']='lu,wsummary("s")', ['l']='lu,wsummary("l")',
		['api,']='lu,scite.Open(props["APIPath"])',
		['abr,']='lu,scite.Open(props["AbbrevPath"])',
		['usr,']='lu,scite.Open(props["SciteDefaultHome"].."\\\\user.props")',
		['glo,']='lu,scite.Open(props["SciteDefaultHome"].."\\\\glob.props")',
		['scd?']='\nO:\\hub\\plat\\win\\scitejoin\\scdoc; dir',
		['git?']='type O:\\hub\\plat\\win\\scitejoin\\lua\\git.out',
		['f']='li,function'
		}

	--replaces aliases
	if inp then
		for i,v in pairs(MyBreevies) do
			--print(i,v,inp)
			if inp==i then
				pane:SetSel(cp2-il,cp2)
				pane:DeleteBack()
				trace(v) 
				cp=output.CurrentPos
				readln=pane:textrange(lanc,pane.LineEndPosition[le])
			end
		end
	end

	--does surviving extra tools

	local _,_,kl=readln:find("^[%>]?[%a][%:][^%;]+[%;][%s]*(.-)[%s]*$")
	if not kl then
		_,_,kl=readln:find("([^%s].-)[%s]*$")
	end
	kl=kl or ""
	if kl=="?" then --tracePrompt()
		trace('\ntype O:\\hub\\plat\\win\\scitejoin\\lua\\help.out')
		return false
	elseif kl=="?git" then --tracePrompt()
		trace('\ntype O:\\hub\\plat\\win\\scitejoin\\lua\\git.out')
		return false
	elseif kl=="?list" then --tracePrompt()
		trace('\ntype O:\\hub\\plat\\win\\scitejoin\\lua\\list.out')
		return false
	elseif kl=="?tron" then --tracePrompt()
		trace('\ntype O:\\hub\\plat\\win\\scitejoin\\lua\\tron.out')
		return false
	elseif kl:find("^d,") then
		uptrace("\n",0,1)
		demork(string.sub(kl,3))
		tracePrompt()
	end

	if readln=="SEE YOU AGAIN SOME TIME." then
		tracePrompt()
		doingeliza=false
	return true
	end

	local p,q,r,reprompt=nil

	local ss,ee,ww=string.find(readln,"^[^;]*[;][%s]*([Oo][Pp][Ee]?[Nn]?[,].*)$")
	if not ww then _,_,ww=string.find(readln,"^[%s]*([Oo][Pp][Ee]?[Nn]?[,].*)$") end
	if ss then 
		local _,_,fn=string.find(ww,"([^%s\\,][^\\,]*[^%s\\,])[%s]*$") --filename
		local _,_,fd=string.find(ww,",(%a:\\.+)\\")        --prefixed path
		if not fd then _,_,fd=string.find(readln,"^[%>]?(%a:\\.+);") end  --promptpath
		if not fd then fd=props['FileDir'] end             --bufferspath
		
--~ 		print(fd.."##"..fn)
		scite.Open(fd.."\\"..fn)
		tracePrompt(nil,"\n",0)
		return true 
	end
	
	local ss,ee,ww=string.find(readln,"^[^;]*[;][%s]*sumv,(.*)$")
	if not ww then _,_,ww=string.find(readln,"^[%s]*sumv,(.*)$") end
	if ss  then 
		movestat(ww or "")
		tracePrompt(nil,nil,1)
		return true 
	end	

	local ss,ee,ww=string.find(readln,"^[^;]*[;][%s]*sv,(.*)$")
	if not ww then _,_,ww=string.find(readln,"^[%s]*sv,(.*)$") end
	if ss  then 
		if ww=="" then ww="tmp" end
		local l=iocatfile(ww or "tmp",editor,promDir)
		if l then return true end
		tracePrompt(nil,nil,1)
		return true 
	end
	
	local ss,ee,ww=string.find(readln,"^[^;]*[;][%s]*svo,(.*)$")
	if not ww then _,_,ww=string.find(readln,"^[%s]*svo,(.*)$") end
	if ss  then 
		if ww=="" then ww="b.out" end
		iocatfile(ww or "b.out",output,promDir)
		tracePrompt(nil,nil,1)
		return true 
	end	
	
	local ss,ee,ww=string.find(readln,"^[^;]*[;][%s]*svc,(.*)$")
	if not ww then _,_,ww=string.find(readln,"^[%s]*svc,(.*)$") end
	if ss  then 
		if ww=="" then ww="clip.n" end
		iocatfile(ww or "clip.n",output,promDir,"clip")
		tracePrompt(nil,nil,1)
		return true 
	end
	
	local ss,ee,ww,yy=string.find(readln,"^[^;]*[;][%s]*([Ll][Ii][Ss]?[Tt]?[,])(.*)$")
	if not ww then ss,ee,ww,yy=string.find(readln,"^[%s]*([Ll][Ii][Ss]?[Tt]?[,])(.*)$") end
	if ss then 
	  local g=unConcat(yy,"';,")
	  for i,yy in ipairs(g) do
		  WReplace(ww..yy)
		end
		tracePrompt(nil,nil,1)
		return true 
	end
	
	ss,ee,ww=string.find(readln,"^[^;]*[;][%s]*[Ff][Oo][Cc]?[Uu]?[Ss]?[,][%s]?(.*)$")
	if not ss then ss=string.find(readln,"^[%s]*[Ff][Oo][Cc]?[Uu]?[Ss]?[,][%s]?(.*)$") end
	if ss then wsummary("f",ww) tracePrompt() return true end

	ss,ee,ww=string.find(readln,"^[^;]*[;][%s]*[Ss][Uu][,][%s]?(.*)$")
	if not ss then ss=string.find(readln,"^[%s]*[Ss][Uu][,][%s]?(.*)$") end
	if ss then wsummary("s",ww) tracePrompt() return true end
	
	ss=string.find(readln,"^[^;]*[;][%s]*[Cc][Ll][Rr][,][%s]*$")
	if not ss then ss=string.find(readln,"^[%s]*[Cc][Ll][Rr][,][%s]*$") end
	if ss then ACoutCache={} end
	
	ss=string.find(readln,"^[^;]*[;][%s]*[Uu][Nn][Dd]?[Oo]?[,][%s]*$")
	if not ss then ss=string.find(readln,"^[%s]*[Uu][Nn][Dd]?[Oo]?[,][%s]*$") end
	if ss then 
		noteSelection(editor)
		editor:Undo()
		restoreSelection(editor)
		tracePrompt("","\n")
		return true
	 end

	ss=string.find(readln,"^[^;]*[;][%s]*[Rr][Ee][Dd]?[Oo]?[,][%s]*$")
	if not ss then ss=string.find(readln,"^[%s]*[Rr][Ee][Dd]?[Oo]?[,][%s]*$") end
	if ss then 
		noteSelection(editor)
		editor:Redo()
		restoreSelection(editor)
		tracePrompt("","\n")
		return true 
	 end

	ss=match(readln,"^[^;]*[;][%s]*[Gg][Oo][Tt]?[Oo]?[,][%s]*([%d]+)$")
	if not ss then ss=match(readln,"^[%s]*[Gg][Oo][Tt]?[Oo]?[,][%s]*([%d]+)$") end
	if ss then 
		editor:GotoPos(editor:PositionFromLine(tain(ss-1)))
		print()
		tracePrompt("","\n")
		return true 
	 end

	if sayrandie(cp,cp2) then output:ScrollCaret() return true end
	
	ss=nil
	ss,ee=string.find(readln,"^[^;]*[;]([%s]*[Ll][Uu][Aa]?[,])")
	if not ss then ss,ee=string.find(readln,"^[%s]*([Ll][Uu][Aa]?[,])") end
	if ss then
		p= string.sub(readln,1,ee) --prompt and inst:
		q= string.sub(readln,ee+1,-1) --the content
		r= match(readln,"[^;]*[;][%s]?") or "" --the path..';'
	else
		--cp
		p,q,r,reprompt=nil
		ss,ee=string.find(readln,"^[^;]*[;]([%s]*[Ss][Aa][Pp][,])")
		if not ss then
			ss,ee=string.find(readln,"^[%s]*([Ss][Aa][Pp][,])")
		end
		--
		if ss then
			editor:append(string.sub(readln,ee+1,-1))
			tracePrompt()
			return true
		end
		--
		return false
	end

	if ss and doingeliza then
		print("\nI AIN'T GONNA FUNK NO MORE!")
		scite_OnChar(ElizaHandler,'remove')
		doingeliza=false
	end

	if ss and q~="" then
		print()
		doluap(q)
		reprompt= r
	else
		reprompt= r
	end

	if elizaran then elizaran=false return true end
	if not starts_line(output,output.CurrentPos) then print() end
	if not doingeliza then trace(reprompt) end--restores prompt
	return true
end

elizaran=false

function last_do() --better as... intro message
	scite.SendEditor(2655,1,1) --always highlight caret line
	scite.SendOutput(2655,1,1)
	
	if props['editor.ExtraAscent']~="" then editor.ExtraAscent=tonumber(props['editor.ExtraAscent']) end
	if props['editor.ExtraDescent']~="" then editor.ExtraAscent=tonumber(props['editor.ExtraDescent']) end 
	if props['output.ExtraAscent']~="" then editor.ExtraAscent=tonumber(props['output.ExtraAscent']) end
	if props['output.ExtraDescent']~="" then editor.ExtraAscent=tonumber(props['output.ExtraDescent']) end 
	
	if output.Length<2 then
		local a=props['FileDir']
		--local y=math.random(106870912,986870912)
		trace(
"                         *** 3583 megabytes free ***   \n+READY\n"..a.."; ")
		--scite.SendOutput(2400) --grabs focus! doesnt work here
--~ if editor.Focus then scite.MenuCommand(421) end --didnt work here either	
	end
end

scite_OnOpen('once',last_do,remove)

-------------------------------------------
--lua-users wiki
-- prompt.lua, scorped


function doluap (line)
	
--~ 	x='math.sqrt'
--~ print(assert(loadstring('return '..x..'(...)'))(25)) --> 5

	if line:find("[e][l][i][z][a][(][) ]+$") then doingeliza=true end

	if sub(line,1,1) == '=' then
		line = 'print('..sub(line,2)..')'
	end

	local f,err = loadstring(line,'inline')

--~ 	if not err and assert(string.len(f.." ")~=1) then err=true end

	if err and not f then
		if not line:match("print") then
			line = 'print( '..line..' )'
		end
		f,err = loadstring(line,'inline')
	end
	print(">Lua,"..line)

	if f then
		local ok,res = pcall(f)
		if ok then
			if res then print(res) elizaran=true end
		else
			print(res)
		end
	end
	
	if err then print("-Lua parse error, "..err) end
	return false
end

function listbuffs()
	for i,v in pairs(openedbuffers) do
		print("-~["..i.." ]")
	end
	tracePrompt()
end

function do_command_list()
	if table.getn(commands) > 1 then
		scite_UserListShow(commands,1,insert_command)
	end
end

------------------
Slide['shortc']=Slide['shortc'] or {}
local la,lc,k
function keytrap(key, shift, ctrl, alt, ankg, cur)
	
	--no commands on alphabet
	if not(alt or ctrl) and key>64 and key<91 then return end

	--this block just to log selection
	if ankg or (shift and (not alt) and key>36 and key<41) then
		--rems line and col to allow single line edits
		local ank,pane =ankg,output
		if editor.Focus then pane=editor end
		if not ankg then ank,cur = pane.Anchor , pane.CurrentPos end
		
		if ank==cur then return end

		local la,lc,g=pane:LineFromPosition(ank),pane:LineFromPosition(cur),"o\t"
		if pane==editor then g=props['FilePath'] end
		sanker[g]={ [1]=la,[2]=ank-pane:PositionFromLine(la) }
		scurren[g]={ [1]=lc,[2]=cur-pane:PositionFromLine(lc) }
		return
	end
			
	if key==13 and not (shift or ctrl or alt) then
		return do_enter()
	end
	
	key=tostring(key)
	if shift then key="S"..key end
	if ctrl then key="C"..key end
	if alt then key="A"..key end

	if Slide['shortc'][key] then 
		Slide['cmdret']=true
		local code,cantgetreturn = Slide['shortc'][key]() 
		--cant get return from pcall or assert-ing the loadstring-ed shortc.key
		return Slide['cmdret']
	end	
end

scite_OnKey(keytrap)

local rkeys={ ["\\"]= 220,[","]= 188,["."]= 190,["/"]= 191,[";"]= 186,["'"]= 192,["#"]= 222,["["]= 219,["]"]= 221,["`"]= 223,["-"]= 189,["="]= 187,["@"]=9 }

function slide_Command( cmdstr )

	local c=unConcat(cmdstr,"|")
	local desc,fun,kyp,k,kv=c[1],c[2],c[3], string.lower(string.sub(c[3],#c[3])) ,0
	if #c<3 then print("- slide error:",desc,fun,kyp,k) return end 
	
	if k:find("[%a]") then kv=string.byte(k)-32
	else if k:find("[%d]") then kv=tonumber(k)+48 
	else if rkeys[k] then kv=rkeys[k] 
	end end end
	
	k=tostring(kv) 
	if string.lower(kyp):find("up") then k=38 end
	if string.lower(kyp):find("down") then k=40 end
	if string.lower(kyp):find("left") then k=37 end
	if string.lower(kyp):find("right") then k=39 end
	if string.lower(kyp):find("nter") then k=13 end
	if string.lower(kyp):find("lete") then k=46 end
	if string.lower(kyp):find("kspac") then k=8 end
	if string.lower(kyp):find("home") then k=36 end
	if string.lower(kyp):find("end") then k=35 end
	k=tostring(k)
	
	if kyp:find("ift") then k="S"..k end
	if kyp:find("trl") then k="C"..k end
	if kyp:find("lt") then k="A"..k end
	
	--print(k)
	
	Slide['shortc']= Slide['shortc'] or {}
	Slide['shortd']= Slide['shortd'] or {}
	
	local ff=unConcat(fun," ")
	ff[2] =ff[2] or "" 
	
--~ 	shortc[k]=loadstring(ff[1].."("..ff[2]..")",'inline')
	Slide['shortc'][k]=loadstring(ff[1].."("..ff[2]..")")
	Slide['shortd'][k]=desc
--~ 	print(k.." # "..ff[1].."("..ff[2]..")")
	--print(shortd[k],k,shortc[k])
end

slide_Command("Undo|modundo|Ctrl+Z")

function modundo()
	
	if editor.Focus then editor:Undo() return end
	
	if output.Length-2>1 and output:textrange(output.Length-2,output.Length-1)==";" then
		output:Undo() output:Undo() output:Undo() output:Undo()
		if output:textrange(tain(output.Length-2),tain(output.Length-1))==";" then
			output:Redo()
		end
	else
		output:Undo()
	end
	
	local s,f=poslinestfn(output.CurrentPos,output)
	if s==f then output:Undo() end
	s,f=poslinestfn(output.CurrentPos,output)
	if s==f then output:Undo() end

end


slide_Command("copy|copycatch|Ctrl+C")
slide_Command("copy|clipcatch|Ctrl+X")
--records copyposition for selection restoration function
--and records new clipboard strings

_G['mOsys']=_G['mOsys'] or {}
local msys=_G['mOsys']
msys['cliptbl']=msys['cliptbl'] or {['last']=1,['txts']= {[0]="",[1]=""} }
local cliptbl= msys['cliptbl']
local maxcliptxtsz=2200000
local clipmodbuffsz=20

function clipcatch()
	if copycatch() then return end
	local pan,f,a,rv=get_pan()
	if pan==output and output.CurrentPos==output.Length
		and output.Anchor==output.Length	
	then pan=editor end
	
	pan:ReplaceSel("")
end
		
function copycatch()
	local g="o\t"
	local pan,f,a,rv=get_pan()
	
	if pan==output and output.CurrentPos==output.Length
		and output.Anchor==output.Length	
	then pan=editor end

	if pan.SelectionMode~=0 then 
		Slide['cmdret']=false return true 
	end

	pan:Copy()

	if pan==editor then g=props['FilePath'] or "nil" end
	--restore prev selection if none
	if sanker[g] and pan.Anchor==pan.CurrentPos then 
		pan:GotoPos(pan:PositionFromLine(scurren[g][1])+scurren[g][2])
		pan.Anchor=(pan:PositionFromLine(sanker[g][1])+sanker[g][2])
	else
		--if rv then f,a=a,f end --already reversed
		if (a-f)<maxcliptxtsz then
			local tr=pan:textrange(f,a)
			if cliptbl.txts[math.mod(cliptbl.last,clipmodbuffsz)]~=tr 
			and cliptbl.txts[
				math.mod(clipmodbuffsz+cliptbl.last-1,clipmodbuffsz)]
				~=tr
			then
				cliptbl.last=cliptbl.last+1	
				cliptbl.txts[math.mod(cliptbl.last,clipmodbuffsz)]=tr
			end
		end
	end
	return
end

slide_Command("pasteclips|pasteclips|Ctrl+Shift+a")

function get_pan(p) --rts: pan,forepos,aftpos,swapped
	if not p then p=editor if output.Focus then p=output end end
	if p.CurrentPos<p.Anchor then return p,p.CurrentPos,p.Anchor,true
	else                          return p,p.Anchor,p.CurrentPos,nil
	end
end

function foreclip(a)
	return cliptbl.txts[math.mod(cliptbl.last+clipmodbuffsz-(a or 0),clipmodbuffsz)]
end

function pasteclips()
	local pan,pf,pa,rv=get_pan()
	local g,fc=nil,0
	
	if pf==pa then
		g=foreclip()
	else
		repeat
			local uq=foreclip(fc)
			if uq and pa-pf==#uq then
				local x=pan:textrange(pf,pa)
				if x==uq then 
					g=foreclip(fc+1)
				end
			end
			fc=fc+1
		until g or fc>clipmodbuffsz
	end
	
	if not g then g=foreclip() end
	
	pan:ReplaceSel(g)
	pan:SetSel(pf,pf+#g)
	return true
end
		
slide_Command("jumpup|jumplist|Ctrl+[")

slide_Command("jumpdown|jumplist 'dwn'|Ctrl+]")

function getofile(pane,tpos,nid,dwn,xtra)
	nid=nid or 1
	if dwn then nid=nid*-1 end
	
	pane = pane or output
	tpos = tpos  or pane.CurrentPos	
	local gln=pane:LineFromPosition(tpos )-nid --this is -ve safe
	gln=tain(gln,0,pane.LineCount)
	
	local gll=gln
	local txr,gpth,gdir =nil
	
	local rgst=gln
	local rgfn=0
	local rg
	
	if dwn then rgfn=pane.LineCount rgd=1
	else rgd=-1 end
	
	local toofx=0
--~ 	while not gpth and gln>-1 do
	for gln=rgst,rgfn,rgd do
		txr=pane:textrange(pane:PositionFromLine(gln),pane.LineEndPosition[gln])
		gpth=txr:match("^([%a][%:][\\/][%w%@%-%#_.\\/%s]+[%w])")
		
		if not gpth then
			gpth=txr:match("^([%w_-.][%w%@%-%#_.\\/%s]*[%w_.]+)")
			if gpth then 
				gdir= getdirectory2(pane,pane:PositionFromLine(gln))
--~ 				print("-"..(gpth or "").."#"..(gdir or "#"))
				if gdir then gpth=gdir.."\\"..gpth end
			end
		end 
--~ 		gln=gln-1
--~ 		print(gln)
--~ 		print("#"..(gdir or "").."#"..(gpth or "").."#"..txr)
		if gpth and isfilepath2(gpth) then gll=gln break end
		if toofx>20 then gpth=nil break end
		toofx=toofx+1 
	end
--~ 	print("#"..txr)
	local j=pane.LineCount-1
	return gpth , pane:PositionFromLine(math.mod(j+gll,j))
end

--~  Lua,print(output:textrange(output:findtext("^[\\w]:?\\\\?[\\w\\\\\\@]+\\.\\w+:\\d+", SCFIND_REGEXP,0,output.Length)))

function findtextget(pane,cp,dest,rgxpat)
	
	if dest=='dwn' then 
		_,cp=poslinestfn(cp,pane)
	end 
	local regm={ 
		"^[-][\\w\\s.\\']+ as \\w:?\\\\?[\\w\\\\\\@]+\\.?\\w\\w\\w?$",
		"^  File \\\"\\w[^\\,]+\\\", line \\d+",
		" [-~]. \\[\\w:?\\\\?[\\w\\\\\\@]+\\.\\w\\w\\w? \\]",
		"^\\w:?\\\\?[\\w\\\\\\@]+\\.\\w+:\\d+",
		"^\\w:\\\\[^\\;]+; \\w:\\\\[\\w\\\\\\@]+\\.\\w\\w\\w?:\\d+" 
	}	

	local cstr,cpth,line,wrapped
	local ah,eh
	local acp=cp
	
	repeat --------------------
		--select next match in the way
		local af,ef={},{}	
		local amtch,emtch=cp,dest
		
		if not wrapped then
			if dest=='dwn' then amtch=cp emtch=pane.Length 
				else amtch=cp emtch=0 end
		else
			if dest~='dwn' then 
				amtch=cp emtch=0
			else
				amtch=cp emtch=pane.Length
			end
		end
		
		for k,rgx in ipairs(regm) do
			ah,eh=pane:findtext(rgx, SCFIND_REGEXP ,amtch,emtch)
			if ah then 
				table.insert(af,ah) table.insert(ef,eh) 
			end
		end
		
		if rgxpat then
			ah,eh=pane:findtext(rgxpat, SCFIND_REGEXP ,amtch,emtch)
			if ah then table.insert(af,ah) table.insert(ef,eh) end
		end
		
		ah=af[1]
		for i,a in ipairs(af)  do	
			if dest=='dwn' then
				if a<=ah then ah=a eh=ef[i] end
			else	
				if a>=ah then ah=a eh=ef[i] end
			end
		end
		
		if ah then --next match selected 
			
			if dest=='dwn' then cp=eh else cp=ah end
			
			cstr=pane:textrange(ah,eh) 
			cstr=string.gsub(cstr,"/","\\")
			cpth,line=nil,nil
				--File "XiteWin.py", line 16, in <module>
			fpths={
				"^([%a][%:][\\/][%w%@%-%#_.\\/%s]+[%w]):([%d]+)",       --errlist
				"^%-[.%w_ %']*as ([%a][%:][\\/][%w%@%-%#_.\\/%s]+[%w])",  --copying..
				"[-~][-~] %[([%a][%:][\\/][%w%@%-%#_.\\/%s]+[%w]) %]",       --sumlist
				"^([%a][%:][\\/][%w%@%-%#_.\\/%s]+[%w])",               --plainfile 
				"%; ([%a][%:][\\/][%w%@%-%#_.\\/%s]+[%w]):(%d+)"        --borked lua
			}
			
			hpths={
				"^  File %\"(%w[^,]+)%\", line ([%d]+)",
				"^([%w_-.][%w%@%-%#_.\\/%s]*[%w_.]+):([%d]+)"
			}
			
			for k,pat in ipairs(fpths) do
				cpth,line=cstr:match(pat)
				if cpth and isfilepath2(cpth) then 
				break end
			end
			
			if not cpth then
				local cdir= getdirectory2(pane,ah)
				
				for k,pat in ipairs(hpths) do
					cpth,line=cstr:match(pat)
					--print(cpth) 
					if cpth and isfilepath2(cdir.."\\"..cpth) then 
						cpth=cdir.."\\"..cpth 
						break 
					elseif cpth and isfilepath2(props['FileDir'].."\\"..cpth) then
						cpth=props['FileDir'].."\\"..cpth
						break
					end
				end
			
			end
		end
		
		if not ah and not wrapped then 
			wrapped=true 
			ah=true	
			if dest=='dwn' then cp=0 else cp=pane.Length end
		end
	
	until isfilepath2(cpth) or (not ah and wrapped) 

	return ah,eh,cpth,cstr,line or 1
end

function jumplist(dwn)
	if dwn==1 then dwn='dwn' end
	
	local ah,eh,cpth,cstr,line=findtextget(output,output.CurrentPos,dwn)
	
	if not ah then Slide['cmdret']=nil return end
	
	local fnd=bjumper(cpth,line)
	output:SetSel(ah,ah)
	Slide['cmdret']=fnd 
	return
end

slide_Command("comment|hotcomment|Ctrl+q")

function hotcomment()
	
	Slide['cmdret']=false 
	local p,b,c=get_pan()
	if p==editor then return end
	
	local sl=output:GetLine(output:LineFromPosition(c))
	local qret=jjumper(sl,c)

end

function selbrak(b)

	local pane=editor if output.Focus then pane=output end
	if pane.Anchor==pane.CurrentPos or pane.SelectionMode~=0
	  or (Slide.recoin and Slide.recoin[(props['FilePath'] or "nil")])
	then 
		Slide['cmdret']=false  return 
	end
	
	local f,a=pane.Anchor,pane.CurrentPos
	local ff=f
	
	if f>a then a,f=f,a end
	
	if b=='D' then
		local ff,aa=tain(f+1,0,a),tain(a-1,f)
--~ 		local ff,aa=f=1,a-1 --tain(f+1,0,a),tain(a-1,f)
		if aa-ff<1 then Slide['cmdret']=false return end
		pane:BeginUndoAction()
		pane:ReplaceSel(pane:textrange(ff,aa))
		pane:EndUndoAction()
		a=a-2
	else
		pane:BeginUndoAction()
		pane:insert(a, sub(b,2,2))
		pane:insert(f, sub(b,1,1))
		pane:EndUndoAction()
		a=a+2
	end
	
	
	if ff==f then
		pane:SetSel(f,a)
	else
		pane:SetSel(a,f)
	end
end

slide_Command("Selection quote  |selbrak \"\'\'\"|'")
slide_Command("Selection parenth|selbrak '()'|Shift+0")
slide_Command("Selection brack  |selbrak '[]'|]")
slide_Command("Selection bracket|selbrak '<>'|Shift+.")
slide_Command("Selection brace  |selbrak '{}'|Shift+]")
slide_Command("Selection dubquot|selbrak '\"\"'|Shift+2")
slide_Command("Delete ends|selbrak 'D'|Delete")


function keysay(a,b,c,d,e,f,g)
	print(a,b,c,d,e,f,g)
end
--~ scite_OnKey(keysay)
--~ scite_OnKey(keysay,'remove')

