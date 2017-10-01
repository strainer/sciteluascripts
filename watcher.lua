Slide['aftaclose']=Slide['aftaclose'] or false
Slide['opentime']=Slide['opentime'] or os.time()
Slide['fstatble']=Slide['fstatble'] or {}
Slide['chlist']=Slide['chlist'] or {}
Slide['recordch']=Slide['recordch'] or 0
Slide['detailch']=Slide['detailch'] or 0
Slide['extrarec']=Slide['extrarec'] or 0
Slide['tndg']=Slide['tndg'] or 0
Slide['tabtime']=Slide['tabtime'] or 0
Slide['tabnumb']=Slide['tabnumb'] or 1

local seentime=Slide['seentime']
local seenfile=Slide['seenfile']
local rantime=Slide['rantime']
local fstatble=Slide['fstatble']
local chlist=Slide['chlist']
local recordch=Slide['recordch']
local detailch=Slide['detailch']
local extrarec=Slide['extrarec']
local tndg=Slide['tndg']
local tabtime=Slide['tabtime']
local tabnumb=Slide['tabnumb']

local fstatfile='filewatch.n'
local fstatpath=props['SciteDefaultHome']..'\\'..fstatfile

local insert=table.insert
local stringsub=string.sub
local floor=math.floor
local match=string.match

--Lua:print(string.format("<%-10s>", "goodbye")) leftpad 10, no - rightpad
local function strpack(str,len,right)
	local sln=#str
	if len<sln then
		local cutl=math.floor((sln-len)/2)
		local cutr=sln-len-cutl
		local cutp=math.floor(sln/2)
		return stringsub(str,1,cutp-cutl-2).."(~)"..stringsub(str,cutp+cutr+2)
	else
		if not right then
			return str..stringsub(spaceS,1,len-sln)
		else
			return stringsub(spaceS,1,len-sln)..str
		end
	end
end

local function fstatrow( diffs, size, saves, dwelltime, firsttime, lasttime )
	return 
		{['diffs']       = diffs 
		,['size']        = size 
		,['saves']       = saves
		,['dwellt']      = dwelltime 
		,['firsttime']   = firsttime 
		,['lasttime']    = lasttime }
end

function movestat(str)
 
	local fpath=string.match(str,"([^,]+),")
	local apath=string.match(str,",([^,]*[^%s])%s*")
	if fpath==apath or not 
		(string.find(fpath,"^%a:\\[^,%*]*$") 
		and string.find(apath,"^%a:\\[^,%*]*$") ) 
	then
		print("\n- Wont move paths (terms seem invalid)")
		
		return
	end
	print("\n- Moving "..fpath.."* to "..apath.."*")
	print("\n- Backup saved to "..fstatpath..".bak")
	
 saveallrec(".bak")
	
	for fn,sr in pairs(fstatble) do
		local pfp=string.gsub(fn, fpath, apath)
		if pfp~=fn then
			if not fstatble[pfp] then 
				fstatble[pfp]=shallow_clone(fstatble[fn])
				print(pfp..":1: Was "..fn)	
			else
				print( fn..":1: Ate "..pfp)
				fstatble[pfp].diffs=fstatble[pfp].diffs+fstatble[fn].diffs
				fstatble[pfp].saves=fstatble[pfp].saves+fstatble[fn].saves
				fstatble[pfp].dwellt=fstatble[pfp].dwellt+fstatble[fn].dwellt
				fstatble[pfp].firsttime=fstatble[fn].firsttime
--~ 		fstatble[pfp].lasttime=fstatble[fn].lasttime
--~ 		fstatble[pfp].size=fstatble[fn].size
			end
			fstatble[fn]=nil
		end
	end
 saveallrec()
end 
 
 
function fhistory(ltime,num,hardn)

	local ftimes,r={},{}
	for fn,sr in pairs(fstatble) do
		local tgtim =openedbuffers[fn] or sr.lasttime
		if sr.lasttime>tgtim then tgtim=sr.lasttime end
--~ 		print('fn# '..fn..' o#'..(openedbuffers[fn] or '')..' fs#'..sr.lasttime)
		if not (ltime and (tgtim<ltime)) then
			ftimes[#ftimes+1]={ [1]=fn , [2]=tgtim }
		end
	end
	
	table.sort(ftimes, function(x,y) return (x[2]>y[2]) end )
	
	local tti=ftimes[1][2]
	local f
	
	if num>#ftimes then num=#ftimes end
	local tinv=tain((tti-ftimes[num][2])/num,600,1800) --crazy stupid switcher hack 
	for ix=1,#ftimes do
		f=ftimes[ix]
		if num and (#r>=num) 
		and not ((not hardn) and (#r<num*2) and (((tti-f[2])*3)<tinv)) 
		then break end
		tti=f[2]
		if openedbuffers[f[1]] or (#r<3) then
			insert(r,f[1])
		end
	end

	return r
end

function testhist()
	print("\n"..table.concat(fhistory(nil,5),"\n"))
end

local function cdirt(path,impo)
	if not chlist[path] then 
		chlist[path]=true 
		recordch=recordch+1
		detailch=detailch+2+impo	
	end
	detailch=detailch+impo+1
end 
 
local function wcheckexists(path,ftime) --creates as necess
	local nowtime=os.time()
	rantime=rantime or nowtime
	local f=fstatble
	if not f[path] then
		ftime = ftime or nowtime --diffs, size, saves, dwellt, firsttime, lasttime
		f[path]=fstatrow( 0, editor.Length, 0, nowtime-ftime, ftime, nowtime )
		cdirt(path,4) --print('ch',detailch,#chlist,chlist[path])
	else
		if nowtime-rantime<3 then 
			--print("\ngag") 
		return end
		
		f[path]=fstatrow( f[path].diffs, f[path].size, f[path].saves, f[path].dwellt, f[path].firsttime, nowtime )
		cdirt(path,1)
	end
end

local function wchecksize(path) --updates size and diff
	if editor.Length ~=fstatble[path].size then
		fstatble[path].diffs=fstatble[path].diffs+math.abs(fstatble[path].size-editor.Length)
		fstatble[path].size=editor.Length
		cdirt(path,2)
	end
end
 
local function wupdwellt(path, rantime) --updates time and dwell
	path=path or props['FilePath']
	local nowtime=os.time()
	rantime=rantime or nowtime 
	local dwellnow=nowtime-rantime
	if dwellnow<5 then return end
	if dwellnow>1200 then dwellnow=1200 end --limit dwells to 20mins for unattention
	fstatble[path].dwellt=fstatble[path].dwellt + dwellnow
	fstatble[path].lasttime= nowtime
	cdirt(path, floor(math.log(dwellnow/100))+1 )
end
	
function onsaveds()
	seenfile=props['FilePath'] 
	
	local lastwfile=seenfile -- reset onswitch update point.. 
	seentime=os.time() 
	openedbuffers[seenfile]=seentime

	wcheckexists(lastwfile) 
	wchecksize(lastwfile)
	wupdwellt(lastwfile,lasttime)  lasttime=seentime
	
	fstatble[lastwfile].saves=fstatble[lastwfile].saves+1
	cdirt(lastwfile, 3 )
	wcheckdirt()
end                                          scite_OnBeforeSave(onsaveds)

function onswitches()
--~ 	local F = io.open(fstatpath, "a+")   -- write data to file
--~ 	local ok = F:write("switches") io.close(F) 
--~  --switches happens on shutdown, not on startup
	if Slide['aftaclose']==true then
		Slide['aftaclose']=false
		return
	end
	
	if not Slide['afterstartW'] then 
		scite_OnOpen(onswitches,'remove') 
		scite_OnOpen(onswitches) 
		Slide['afterstartW']=true
	end
	
	local lastwfile=seenfile
	seenfile=props['FilePath']
	lasttime=seentime or os.time()
	seentime=os.time()
	if not openedbuffers[seenfile] then
		--print("onswitch:new:"..seenfile)
		chlist[seenfile]=true
		wcheckexists(seenfile)
		detailch=detailch+1
	end
	tndg=math.mod(tndg+0.001,1)
	openedbuffers[seenfile]=seentime+tndg
	--print("onswitch:"..seenfile..":"..seentime)
	--want to do this onshutdown but there is none (
	if seentime-lasttime<1 then 
		--print("onswitch:saveextra")
		if detailch~=0 then saveextrarec() 	end
		return
	end

	if lastwfile then --(if there was a last file)
		wcheckexists(lastwfile,lasttime)
	end
	if seentime-(lasttime or seentime)>0 then
		--print("onswitch:wupdwellt")
		wupdwellt(lastwfile , lasttime)
	end 
end                               scite_OnSwitchFile(onswitches)
				
function wdroprec(path)
	fstatble[path].firsttime=0
	chlist[path]=true
	saveextrarec()
	fstatble[path]=nil
end

function ac_onopens()  --collect buffer paths, runs at startup before switching
	--for i,v in pairs(openedbuffers) do print(i,v) end
	local currtime=Slide['opentime']
	local lasttime=currtime
	currtime=os.time()
	local p=props['FilePath']
	
	if Slide['afterstartW'] then	
		if not openedbuffers[p] then wcheckexists(p,currtime) end
		chlist[p]=true
		detailch=detailch+2
	end
	
	tndg=math.mod(tndg+0.001,1)
	openedbuffers[p]=currtime+tndg
	--print("onopens:"..props['FilePath'])
	
	if currtime-lasttime>1 then 
		--print("onopens:goswitches")
		scite_OnOpen(onswitches,'remove')
		scite_OnOpen(onswitches)
		Slide['afterstartW']=true
		--scite_OnOpen(ac_onopens,'remove')
	end
end scite_OnOpen(ac_onopens)

function ac_oncloses()  --collect buffer paths trying turned off... 
	p=props['FilePath']
	openedbuffers[p]=false	
	chlist[p]=true
	detailch=detailch+1
end scite_OnClose(ac_oncloses)

function wcheckdirt()
	--at shutdown all are saved so this only
	--checks to see if much for a resave or 
	--this is to save disk access especially for pen drives.
	if recordch+extrarec>32 and detailch>32 then saveallrec() 
	else if detailch>48 then saveextrarec() end 
	end
end
								
function ModeWriteD(filepath, filedata, mode)
--~ 	print("#Writing zum")
	local F = io.open(filepath, mode)   -- write data to file
	if not F then
		F = io.open(filepath):write(filedata) io.close(F)
		print("Created '"..filepath) 
		return
	end
	local ok = F:write(filedata) io.close(F)
	if not ok then print("Failed to write data to '"..filepath.."'") end
end	

--format details forthe reading and writing routines
local g= { "diffs",9,"size",9,"saves",5,"dwellt",9,"firsttime",10,"lasttime",11 }
local gx={ 1,g[2], 
					 1+g[2],  g[2]+g[4], 
					 1+g[2]+g[4],  g[2]+g[4]+g[6], 
					 1+g[2]+g[4]+g[6],  g[2]+g[4]+g[6]+g[8],
					 1+g[2]+g[4]+g[6]+g[8],  g[2]+g[4]+g[6]+g[8]+g[10], 
					 1+g[2]+g[4]+g[6]+g[8]+g[10],  g[2]+g[4]+g[6]+g[8]+g[10]+g[12] } 
local s=[[                    ]] --20 s
local slen=string.len local ssub=string.sub 
--

function saveextrarec()
	local tout={ "diff     size     save dwell    first     last       path\n" }
	extrarec=extrarec+1
	for i,v in pairs(fstatble) do 
		if chlist[i] then
			extrarec=extrarec+1
			insert( tout,
				table.concat( 
				{ v[g[1]] , ssub( s,1,g[2]-slen(v[g[1]]) ) , 
					v[g[3]] , ssub( s,1,g[4]-slen(v[g[3]]) ) , 
					v[g[5]] , ssub( s,1,g[6]-slen(v[g[5]]) ) , 
					v[g[7]] , ssub( s,1,g[8]-slen(v[g[7]]) ) , 
					v[g[9]] , ssub( s,1,g[10]-slen(v[g[9]]) ) , 
					v[g[11]], ssub( s,1,g[12]-slen(v[g[11]]) ) , i ,"\n" } ) 
				)
		end
	end
	if not #tout then return end
	ModeWriteD(fstatpath, table.concat(tout), "a+")
	chlist={} recordch=0  detailch=0  --print('saved dirt')
end
													 
function saveallrec(bak)
	bak=bak or ""
	local tout={ "diff     size     save dwell    first     last       path\n" }
	for i,v in pairs(fstatble) do 
		insert( tout,
			table.concat( 
			{ v[g[1]] , ssub( s,1,g[2]-slen(v[g[1]]) ) , 
				v[g[3]] , ssub( s,1,g[4]-slen(v[g[3]]) ) , 
				v[g[5]] , ssub( s,1,g[6]-slen(v[g[5]]) ) , 
				v[g[7]] , ssub( s,1,g[8]-slen(v[g[7]]) ) , 
				v[g[9]] , ssub( s,1,g[10]-slen(v[g[9]]) ) , 
				v[g[11]], ssub( s,1,g[12]-slen(v[g[11]]) ) , i ,"\n"}  ) 
			)
	end
	ModeWriteD(fstatpath..bak, table.concat(tout), "w+")
	chlist={} extrarec=1 recordch=0 detailch=0  --print('saved all')
end

local function readfstatable()
	
	local e = io.open(fstatpath)
	if not e then return end
	local path=""
	for line in e:lines() do --simple closes itself
--[[print(line)
		print( ssub(line,gx[1],gx[2]), 
					 ssub(line,gx[3],gx[4]), 
					 ssub(line,gx[5],gx[6]), 
					 ssub(line,gx[7],gx[8]), 
					 ssub(line,gx[9],gx[10]), 
					 ssub(line,gx[11],gx[12]),
					 ssub(line,gx[12]+1)			 )]]
		path=ssub(line,gx[12]+1)
		
		if ssub(path,2,2)~=":" or tonumber(ssub(line,gx[9],gx[10])  )==0 then
			fstatble[path]=nil extrarec=extrarec+1
		else
			if fstatble[path] then extrarec=extrarec+1 end
			
			fstatble[path]=
				fstatrow( 
				tonumber(ssub(line,gx[1],gx[2])  ),
				tonumber(ssub(line,gx[3],gx[4])  ),
				tonumber(ssub(line,gx[5],gx[6])  ),
				tonumber(ssub(line,gx[7],gx[8])  ),
				tonumber(ssub(line,gx[9],gx[10]) ),
				tonumber(ssub(line,gx[11],gx[12]))
				)
		end
	end
	e:close()
end                                readfstatable()

local function score1(frec)
	local nt=os.time()
	local age=nt-frec.firsttime
	local lgage=math.log(age/3)
	local last=nt-frec.lasttime
	local lglast=math.log(last/3)
	local active=math.log(frec.dwellt+(frec.saves*4)+50)
	
--~ 	print("age "..age)
--~ 	print("last "..last)
--~ 	print("lgage "..lgage)
--~ 	print("lglast "..lglast)
--~ 	print("active "..active)
--~ 	print("score "..(((lgage-lglast)+active)*active))
	
	return 
		(lgage*active)/lglast 
end

local function score3(frec)
	local nt=os.time()
	return --+math.log(frec.dwellt)
		10000000-(nt-frec.lasttime)  --1 week 604800  13.4  10weeks 15 
end

local function score2(frec)
	local nt=os.time()
	return 
		math.log(nt-frec.firsttime)/100 --1 week 604800  13.4  10weeks 15
	 -math.log((nt-frec.lasttime+200)/3)/5  --1 week 604800  13.4  10weeks 15
	 +math.log(frec.dwellt*2+(frec.saves*5)+200)/2   --1 min 4, 1 hour 8 , 
end

local function spad(str,len,ind)
	local s="                                                  "
	local spaces=len-string.len(str)
	local prespaces=0
	if not ind then
		prespaces=floor(spaces/2)
		spaces=spaces-prespaces
	end
	
	return string.sub(s,50-prespaces+1)..string.sub(str,1,len)..string.sub(s,50-spaces+1)
end

function purgewlist()

	for p,t in pairs(fstatble) do
		if not isfilepath2(p) then
			print("Purging "..p)
			fstatble[p]=nil
		end
	end
	saveallrec()
end

function wsummary(opt,qfind)
	local suma={}
	local picker
	local vwall=true
	if opt=="s" then 
		picker="-- [" --delete from records picker
		tscore=score3
	elseif opt=="l" then 
		picker="-- [" --delete from opens
		tscore=score3
	elseif opt=="f" then 
		picker="-~ ["
		tscore=score3
		vwall=false
	end
		
	for p,t in pairs(fstatble) do
--~ 		print(p)
		local tsc=tscore(t)
		if openedbuffers[p] or vwall then 
			if qfind and qfind~="" then
				if string.find( p:lower(), qfind:lower() ) then insert(suma, { p , tsc }) end
			else
				insert(suma, { p , tsc })
			end
		end
	end
	
	if (opt=="f") and (#suma==1) then
		scite.Open(suma[1][1])
		--scite.MenuCommand(421)	
	end
	
	table.sort(suma, function(x,y) return (x[2]<y[2]) end )
	
--~ 	for i,v in ipairs(suma) do
--~ 		print(suma[i][2],suma[i][1])
--~ 	end
	
	local tt=os.time()
	local ft=fstatble
	--pathtop is list of best scoring paths
	--for path ordering of suma
	
	if opt=="disable pathckumping" then
		local nsum={}
		local pathtick={}
		local pathtop={}	
		for ij=#suma,1,-1 do 
			v=suma[ij]
			local _,_,pt=string.find(v[1],"^(.-)[^\\]*$")
			--print(v[1],pt)
			if pt and not pathtick[pt] then
				insert(pathtop,pt)
				pathtick[pt]=true
				--print(pt)
			end
		end
		for ii,pathv in ipairs(pathtop) do
			for i,suv in ipairs(suma) do
				local _,_,pt=string.find(suv[1],"^(.-)[^\\]*$")
				if pathv==pt then
					insert(nsum,suv)
				end
			end
		end
		suma=nsum
	end
	
	local function printlabs(opt,f)
		if opt=="s" then
			print("+ "..spad(f.." Files" ,9,"left").."      saves  dwell  last first rm paths")
		elseif opt=="l" then
			print("+ "..spad(f.." Files" ,9,"left").."            dwell  last rm paths")
		else
			print("+ "..spad(f.." Files" ,9,"left").."            dwell  last rm paths")
		end
	end
	
	print()
	printlabs(opt,#suma)
	
	--if fo==1 then pp=#pathtop end
	--print()--print(pathtop[pp])

--~ 	for i,v in ipairs(suma) do
--~ 		print(suma[i][2],suma[i][1])
--~ 	end
	
	for i,sflpath in ipairs(suma) do
--~ 		if i>lscore then break end
		
--~ 		local r=ft[sflpath] ??
		local r=ft[suma[i][1]]
		local fexists=isfilepath2(sflpath[1])
		local mf=floor
		local _,_,mp=sflpath[1]:find("\\([^\\]*)$")
		
		local dwelledmins =math.mod(mf(r.dwellt/60),60)
		local dwelledhrs =mf(r.dwellt/3600)
		
		if dwelledmins==0 then dwelledmins="" 
		elseif dwelledmins<10 then dwelledmins="0"..dwelledmins..'m'
		else dwelledmins=dwelledmins..'m' end
		
		if dwelledhrs>0 then dwelledhrs=dwelledhrs.."h" else dwelledhrs="" end	
		local dwellti=dwelledhrs..dwelledmins
		
		if dwellti=="" then dwellti="-" end
			
		local sav=r.saves if sav==0 then sav="-" end
		local l
		if fexists then fexists="- " else fexists=": " end
		
		if opt=="s" then l=
		{ fexists,spad(mp,15,true)," ",
			spad(sav,6,true), spad(dwellti ,6   ),
			spad(mf((tt-r.lasttime)/86400+0.499) ,6 ),
			spad(mf((tt-r.firsttime)/86400+0.499) ,6),
			picker,sflpath[1]," ]"--,suma[i][2]
			}
		elseif opt=="l" then l=
		{ fexists,spad(mp,20,true)," ",
			spad(dwellti ,6   ),
			spad(mf((tt-r.lasttime)/86400+0.499) ,6 ),
			picker,sflpath[1]," ]"
			}
		else l=
		{ fexists,spad(mp,20,true)," ",
			spad(dwellti ,6   ),
			spad(mf((tt-r.lasttime)/86400+0.499) ,6 ),
			picker,sflpath[1]," ]"
			}
		end
--~ 		print(suma[i][2])
		print(table.concat(l))
	end
	
	if #suma>8 then 
		printlabs(opt,#suma) 
	end
end

------------------------------------------------------
slide_Command("Ctrl+Tab|ctrltab|Ctrl+@") --@means tab
scite_Command("Buffers|do_buffer_list|Ctrl+`")

function ctrltab()
	local now=os.time()
	local j={2,2,3,4,2,5,6,7,8,9,10}
	if now>tabtime+1 then
		tabnumb=1
	else tabnumb=tabnumb+1 end
	if tabnumb==5 then tabnumb=1 end
	
	tabtime=now
	local jp=j[tabnumb]

	local bfs=fhistory(nil,20)
	repeat
		if openedbuffers[bfs[jp]] then
			scite.Open(bfs[jp])
			jp=20
		else
			jp=jp+1
		end
	until jp==20
end

local scndgo

function gettoppaths()
	local toppaths={}
	local e = io.open(props['slide.toppaths'])
	if not e then return end
	for line in e:lines() do --simple closes itself
		if line:match("[-][-][-][-]") then break end
		local p=pathinStr(line)
		if p then insert(toppaths,p) 
		else
			local dr=line:match("(.*)//.*") or line --strip my comments
			local dr=dr:match("^[%s]*([%a]:[\\/][%w.@~&%-_]+[ ]?[%w.@~&%-_]+[\\/%w.@~&%-_ ]*[\\/])")
			if dr then insert(toppaths,dr) end
		end
	end
	e:close()
	return toppaths
end 

function do_buffer_list()
	local pane=get_pane()
	local bffrSort ={}
	local bffrsOut ={}
	local targ=65
	local bx,tfl,tpl,tfl2,tpl2,afl,apl=0,0,0,0,0,0,0
	
	if pane:AutoCActive() then
		if scndgo then
			scndgo=nil
			pane:AutoCCancel()
			return true
		else
			scndgo=true
		end
	else
		scndgo=nil
	end
	
	if not scndgo then
		for i,v in pairs(openedbuffers) do
		if v then insert(bffrSort,i) end
		end	
	else
--~ 		scndpths=(props['Slidepaths']):unconcat("|")
		scndpths=gettoppaths()
	end
			 
	local gbf=props['FilePath']
	local gdir=props['FileDir']
	local gname=props['FileName'] --(no extension)
	local didfnd=false
	
	if scndgo then
		--same name finding--
		
		didfnd=false
		
		for v,_ in pairs(fstatble) do
			local fni= match(v,"^.-([^\\]*)$") or "" --file name of buff
			fni=match(fni,"^([^\.]*)")                 --remove any extension
			if fni==gname then
				if v~=gbf then 
					didfnd=true 
					--print(v)
					if openedbuffers[v] then insert(bffrSort,v) end 
				end 
			end
		end
		
		if didfnd then insert(bffrSort,"      ") end
		didfnd=false

		for _,v in ipairs(scndpths) do
			insert(bffrSort,v)
		end
		
		insert(bffrSort,"      ")
		
		for v,_ in pairs(fstatble) do
			local fpi=match(v,"^(.-)[\\][^\\]*$")
--~ 			print(fpi)
			if fpi==gdir then
				if v~=gbf then 
					didfnd=true 
					
					if openedbuffers[v] then insert(bffrSort,v) end
 
				end 
			end
		end
	end
	
	if not scndgo then
		table.sort(bffrSort, dircomp) --all opened buffers
		
		--
		local curpath= bffrSort[1] or "" 
		
		local pathlst,m,n={},1,1
		insert(pathlst,curpath)  --pathlst chunks at a time
		
		local curdir=match(curpath,"^(.-)[^\\]*$")
		local lstpath=bffrSort[2]
		local igin,xi=0,2
		
		repeat
			local vnd=match(lstpath or"","^(.-)[^\\]*$")
			if vnd==curdir then 	insert(pathlst,lstpath)  --if lat op buff is same dir as first
			else
				table.sort(pathlst, filcomp) --print('sorting',#pathlst)
				for i,v in ipairs(pathlst) do	bffrSort[igin+i]=v end
				igin=igin + #pathlst
				pathlst={[1]=lstpath}
				curdir=vnd
			end
			xi=xi+1 lstpath=bffrSort[xi] 
		until xi>#bffrSort
		
		table.sort(pathlst, lencomp)
		table.sort(pathlst, ldircomp)
		for i,v in ipairs(pathlst) do
			bffrSort[igin+i]=v
		end			--	for i,v in ipairs(bffrSort) do

		--made a pathlist, and added to bffrSort
		
		--add recently used	
		
		local bbb=fhistory(nil,6)
		
		for i,v in ipairs(bbb) do
			if openedbuffers[bbb[i]] then insert(bffrsOut,bbb[i]) end
		end
		
		if bffrsOut[2] then 
			bffrsOut[2],bffrsOut[1]=bffrsOut[1],bffrsOut[2]
		end
		
		local gdlen=#gdir
		--a back directory of the current 
		local gdhlen=floor((#gdir+1)*2/3)
		local gdh=match(stringsub(gdir,1,gdhlen),"^(.-)[^\\]*$")
		gdhlen=#gdh	
		
		insert(bffrsOut,"      ") --------------
		
		--current directory sorting--
		for i,v in ipairs(bffrSort) do
			local p= match(v,"^(.-)[^\\]*$")
			if p==gdir then
				--print(p,gdir,v)
				if v~=gbf then 
					didfnd=true
					insert(bffrsOut,v) 
				end
				bffrSort[i]="x" --print("niled!")
			end
		end
		if didfnd then insert(bffrsOut,"        ") end --------------
		didfnd=false
		
		--back directories next, sort by length--
		for i,v in ipairs(bffrSort) do
				--print(v, stringsub(v,1,gdhlen),gdh)
			if v~="x" and (gdh==stringsub(v,1,gdhlen)) then
				insert(bffrsOut,v)
				didfnd=true
				bffrSort[i]="x" --print("nilled")
			end
		end
		
		if didfnd then insert(bffrsOut,"        ") end --------------
		
		--all the rest--
		table.sort(bffrSort, drivcomp)
		table.sort(bffrSort, driv1comp)
		table.sort(bffrSort, driv2comp)
	end
	--bffrSort=(props['Slidepaths']):unconcat("|")
	--------------------------------------------------
	--Suss out Dialog Widths
	bx=#bffrSort
	for _,i in pairs(bffrSort) do
		local p,f= match(i,"^(.-)([^\\]*)$") --path,file
		local fl=#f --strlen of file 
		local pl=#p 
		afl=afl+fl apl=apl+pl
		
		if fl>=tfl then tfl2=tfl tfl=fl 
		elseif fl>tfl2 then tfl2=fl
		end
		
		if pl>=tpl then tpl2=tpl tpl=pl 
		elseif pl>tpl2 then tpl2=pl 
		end	
	end
	
	local atl=floor(afl+apl)/2   --sub minimum length
	local itl=tfl2+tpl2          --a good length
	
	local zfl,zpl=tfl,tpl
	if (zfl+zpl)>targ then  --average,top file,path length 
		
		targ=((targ+(tfl2+tpl2)*2+(afl+apl)/bx)/4)
		zfl =(targ*(tfl+tfl2*2+afl))/(tpl+tpl2*2+apl)
		zpl =targ-zfl
	else
		local m=targ-(zfl+zpl)
		zpl=zpl+floor(m/4)
		zfl=targ-zpl
		targ=targ-floor(m/4)
	end
	local zwt=zfl+zpl	 --zpathlen -zfilelen
	--^Sussed out Dialog Widths via convoluted reckonings
	------------------------------------------------------
	
	--reformat entries--
	for i,v in ipairs(bffrSort) do
		if v~="x" then insert(bffrsOut,v) end
	end

	for i,v in ipairs(bffrsOut) do
		local p,f= match(v,"^(.-)([^\\]*)$")
		local fl=#f
		local pl=#p
		local pfl,ppl=zfl,zpl
		
		if (fl>zfl) and (pl<(zpl-(fl-zfl))) then
			
			ppl=ppl-(fl-zfl)
			pfl=pfl+(fl-zfl)
		end

		if (pl>zpl) and (fl<(zfl-(pl-zpl))) then
			pfl=pfl-(pl-zpl)
			ppl=ppl+(pl-zpl)
		end

		if f=="" then f="·.¸¸.·" end
		f=strpack(f,pfl) 		p=strpack(p,ppl)

		bffrsOut[i]="...  "..p..": "..f.."  >"..v
	end
--~ 		local ad,af=match(a,"^(.-)([^\\]*)$")
--~ 		local bd,bf=match(b,"^(.-)([^\\]*)$")
	pane.AutoCMaxHeight=10
	pane.AutoCMaxWidth=targ+15
	
	local nn=1
	if pane==output then nn=0 end 
	local c=pane.CurrentPos
	local n=pane:PositionFromLine(pane:LineFromPosition(c)+nn)
	pane.CurrentPos=n
	
	--if true then print("wek") return end
	pane.CurrentPos=c
	
	scite_UserListShow(bffrsOut,1,
		function (str) 
			local s=str:match("[>](.*)$")
			if s:match("[\\]$") then
				trace("dir/w "..s)
				if get_pane()==editor then
					scite.MenuCommand(421) --switch focus
				end
			else
				scite.Open(s) 
			end
			return false 
		end
	)
	
	--see lines vis on pane, 
	--see current pos is below middle, substract 1 line before userlist show
	--otherwise add one
	--rather, just add one unless near bottom of pane
	
--~ 	pane:AutoCSelect(redu)

end

slide_Command("Closefile|modclosebuf|Ctrl+W")

function modclosebuf()
	
	Slide['aftaclose']=true
	scite.MenuCommand(105) --closes 
	Slide['aftaclose']=false
	local s
	local bbb=fhistory(nil,6)
	for i,v in ipairs(bbb) do
		if openedbuffers[bbb[i]] then s=bbb[i] break end
	end
	
	if not s then scite.MenuCommand(IDM_QUIT) return end
	
	scite.Open(s)
end