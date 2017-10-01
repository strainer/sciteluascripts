--local function string:unconcat(sep)
function unConcatt(hay, sep)
    
	local fi, ult, sep, tbl, pattern = 1, 1, sep or "", {}

  if #sep>1 then
  
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


local h=unConcatt("bbccaaeeaahhaajja","aa")

print("woop")
for a,v in ipairs(h) do
  print(a,v)
end


--[[

	print("start")
	local lunamark = require("lunamark\\lunamark")
	print("done")
	local writer = lunamark.writer.html.new()
	local parse = lunamark.reader.markdown.new(writer, { smart = true })
	local result, metadata = parse("Here's 'my *text*'...")
	print(result)







trace('it traces')
print('it goes..')
trace('it traces')
print('it goes..')


function poot()
local t1="abcdefg"
a,b=t1:find("cd(d)f")
c,d=string.match(t1,"c(..)f")
print(a,b)
print(c,d)
print(t1:sub(a,b))
print(editor:textrange(0,2))
end

--poot()

a,b,c,d,e,f,g=string.match("abcdef","([^a])(.)(.)")
print(a,b,c,d,e,f,g)

f =io.popen('cmd.exe /k')
print(f)
f:close()

function moog()
	print("moog")
	return editor:GetText()
end

trans['moog']=moog
function updateContent()
		if begPos and endPos then
				output:remove(begPos, endPos)
		end
		begPos = output.CurrentPos
		local content = io.popen('dir /b /o /a:-h ')
		print(dir..sep)
		print(up)
		print(content:read '*a')
		content:close()
		endPos = output.CurrentPos
end
 
	



function goon()

local function doit()
	print("done")
end

doit()

end ]]

--[[
len=string.len
local tal2=0	
tg=os.clock()
tal=0
ligs = { "wwef","shuw                                             ijj","hs     t                        t     nnnnnnnntnnnnnnnnkjjtjjjjjjjjjjhhthhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhiiiiiiiiiiiiiiiiiiiiiiuuuuuuuuuuuuuuuuuuuuuuuuuiiiiiiiiiiiitiiiiioooooooooooooooooooooooooooooooooouuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuhhhhhhhhhhhhhhhhhhhhhthhhhhhhhhhhhhhhhhhhhhhuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuiiiiiiiiitiiiiiiiiiiiiiiiiiitiiiiiiiiiiiiuuuuuuuuuuuuuuuggggggggggggguuuuuuuuugyftddtdtdtdtdtdtdtdtdydtdytydddddtdydytytdydytdytdytdytdytdytdytdydytdytdytdydtudiiyidiydyifiydiyduuyushij","ihsuhiuh","oijjoi" }

local stime=0
function starttime()
	stime =os.clock()
end

function endtime(h)
	print(s,(os.clock()-stime))
end


function string:unconcat1(sep)
	local fi, ult, sep, fields, pattern = 1, 1, sep or "", {}

	if sep~="" 
	then pattern = string.format("([^%s]*[%s]?)", sep,sep)
	else pattern ="(.)" end
	
	if self:sub(#self-#sep+1)~=sep 
	then ult=0 end
	
	local fi=1
	local function cc(c)  fields[fi] = c  fi=fi+1  end
	self:gsub(pattern, cc)
	
	if ult==0 then fields[#fields]=nil end
	return fields
end

x=unconcat("aaaaaaaaaaaaaaaab","")
print( table.concat( x , "-") )




starttime()
for i=1,5000 do
 tick=ligs[3]:unconcat("t")
end
endtime("o")

print(table.concat(tick,"-"))

starttime()
for i=1,5000 do
 local tick=ligs[3]:unconcat1("t")
end
endtime("i")

starttime()
for i=1,5000 do
 local tick=ligs[3]:unconcat("t")
end
endtime("o")

starttime()
for i=1,5000 do
 local tick=ligs[3]:unconcat1("t")
end
endtime("i")


function testit()
--~ 	scite.MenuCommand(423)
--~ 	scite.MenuCommand(423)
--~ 	scite.MenuCommand(423)
--~ 	scite.MenuCommand(423)
end
print("beginning")

--~ f=os.time()
--~ for i=1,3 do
--~ c=scite.MenuCommand(423)
--~ end
--~ print(os.time()-f)

local noopens=truthTab("exe com mp3 bmp jpg jpeg gif lnk")

for i,v in pairs(noopens) do
 print(i,v)
 end
 
]]

--~ print(collectgarbage("count"))
--~ collectgarbage("step")
--~ print(collectgarbage("count"))
--~ collectgarbage()
--~ print(collectgarbage("count"))
--[[

slick={}
slick['a']={}
--~ slick['b']['c']={}
slick={ replicEd= { on=true, pos={f=0,c=1,a=2} } }

slick.replicEd.pos.e=3
print(slick.replicEd.pos.e)

if slick.replicEd.pos.h == -1 then print("oop") end
slick.trick={onx=true}
print(slick.trick.onx)
w='onx'
u=slick.trick[w]
v=slick.truck['off']
print(u,v)
]]
--[[
function xfind(str,ptt,ini,pn)
	
	--e=string.find(pat,"[^%]?(.+[%|].-[^%])")
	
	local s,u=string.find((string.gsub(ptt,"%%.","%%%%") or ""), "%([^%(%)]-[%|][^%(%)]-%)")
	if s then
		local bg=string.sub(ptt,1,s-1)
		local nd=string.sub(ptt,u+1)
		print(bg,nd)
		local brak=string.sub(ptt,s+1,u-1)
		local bunc=brak:unconcat("|")
		for _,x in ipairs(bunc) do
			local a,b,c,d,e,f,g,h,i,j= string.find(str,(bg..x..nd),ini,pn)
			if a then
				return a,b,c,d,e,f,g,h,i,j
			end
		end
	end
	--string.find(string,patt,init,plain)
	--s,e=find(clt,cfnt,gin,nopat)	
end



function yfind(str,ptt,ini,pn)
	
	--mtchfn=string.find(pat,"[^%]?(.+[%|].-[^%])")	
	--quote these %(
	local s,u=string.find((string.gsub(ptt,"%%.","%%%%") or ""), "%([^%(%)]-[%|][^%(%)]-%)")
	if s then
		local bg=string.sub(ptt,1,s-1)
		local nd=string.sub(ptt,u+1)
		
		local brak=string.sub(ptt,s+1,u-1)
		local bunc=brak:unconcat("|")
		for _,x in ipairs(bunc) do
			local a,b,c,d,e,f,g,h,i,j= string.find(str,(bg..x..nd),ini,pn)
			if a then
				return a,b,c,d,e,f,g,h,i,j
			end
		end
	end
	--string.find(string,patt,init,plain)
	--mtchst,mtchfn=find(caslntxt,fndpatcas,nxfndpos,plainmtch)	
end

--~ a,b,c,e,f,g,h=xfind("pigglewigglelok","((Wig|wiggle|wok|wig))",3,false)
--~ print(a,b,c,e,f,g,h)
--~ a,b,c,e,f,g,h=yfind("pigglewigglelok","(Wig|wiggle|wok|wig)",3,true)
--~ print(a,b,c,e,f,g,h)
--~ >1	12	wiggle	nil	nil	nil	nil

--~ print(string.find(">o:\\hub; op,o:\\heb\\hib\\\oh\\hob.n.n", "^[%>]?(%a:\\.+);" ))

function sleep(s)
	local ntime = os.time() + s
	repeat until os.time() > ntime
end

--sleep(30)
--print("slept")


--~ function xx(d)
--~  return d
--~ end

--~ x=loadstring("(xx(3))")

--~ print(x())
--~ print(xx(3))

--~ hit,fpos=ed:findtext("[\t ][\t ]+$", SCFIND_REGEXP, f,a )


function findupline(lin,txt,pane,flags,dwn)
	
--~ 	SCFIND_MATCHCASE + SCFIND_WHOLEWORD + SCFIND_WORDSTART + SCFIND_REGEXP
	if not flags then flags = SCFIND_REGEXP end
	if not pane then pane=output end
	local s,e
	if dwn then	
		s,e = pane:findtext(txt,flags,pane:PositionFromLine(lin))
	else
		s,e = pane:findtext(txt,flags,pane:PositionFromLine(lin),0)
	end
	
	if not s then return
	else
		l=pane:LineFromPosition(s)
		return l,pane:GetLine(l)
	end 
end

function fileandpathabv(ln,pane)
	pane=pane or output
	
	DIR_REGEX=""
	DIR_MATCH="([%a][%:][\\/][^;\(\"\':\>]+[%w])"
	
	local qln,dir=ln,nil
	while qln and not dir do
		qln,dir=findupline(ln,DIR_REGEX,pane)
		dir=dir:match(DIR_MATCH)
	end


function getfilepath(lks)
	pane =output
	tpos=pane.CurrentPos
	local lks=pane:LineFromPosition(tpos)-1 --this is -ve safe
	local cand =nil
	local dix= getdirectory(pane,tpos, nid)
	while not cand and lks>-1 do
		tlk=pane:textrange(pane:PositionFromLine(lks),pane.LineEndPosition[lks])
		
		cand=tlk:match("^([%a][%:][\\/][^;\(\"\':\>]+[%w])[%s]*$")
		
		if not cand then
			cand=tlk:match("^([^;\(\"\':\>]+).*$")
			if cand then 
				dix= getdirectory2(pane,pane:PositionFromLine(lks), nid)
				if dix then 
					cand=dix.."\\"..cand
					if not isfilepath2(cand) then cand = nil end	
				else 
					cand=nil
				end	
			end
		end 
		lks=lks-1
	end
	end
	
	return diza , pane:PositionFromLine(lks+1)
end

b="wxppw" c="swdfs" d="wergrgr" u=0
t1=os.clock()

tn=5000--4000000
for i=0,tn do
	s=b..c..d 
	u=#s+u	
end
t2=os.clock()
print("#g",t2-t1)

w={b,c,d}
for i=0,tn do
	s=table.concat(w) 
	u=#s+u	
end
t1=os.clock()
print("#f",t1-t2)




function clearOccurrences()
		scite.SendEditor(SCI_SETINDICATORCURRENT, 1)
		scite.SendEditor(SCI_INDICATORCLEARRANGE, 1, editor.Length)
end

function markRange(s,e)
		clearOccurrences()
		scite.SendEditor(SCI_SETINDICATORCURRENT, 1)
		scite.SendEditor(SCI_INDICSETSTYLE, 1, INDIC_ROUNDBOX)
		scite.SendEditor(SCI_INDICSETFORE, 1, 255)
		scite.SendEditor(SCI_INDICATORFILLRANGE, s, e - s)
end ]]