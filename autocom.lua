
-- Dynamically generate autocomplete lists from possible identifiers in any file.
--  From 'lua-users wiki'  A nice generic name completer
--  Altered to run on ctrlspace instead of always
--  And hacked to preferences

slide_Command 'Completions|autoCp|Ctrl+Enter'

local match = string.match
local find = string.find
local insert = table.insert
local stringlen =string.len
local stringsub = string.sub 
local	normalize = string.lower 
local gmatch=string.gmatch

local CompleteSingle=true
local GoneForward=0

Slide['autoAPIC']=Slide['autoAPIC'] or {}
Slide['autoAPIC']['n']={}
Slide['autoEDIC']=Slide['autoEDIC'] or {}
Slide['autoEDIC']['n']={}
Slide['autoACou']=Slide['autoACou'] or {}

local function get_pane()
	if editor.Focus then return editor 
	else return output
	end
end

--AUTOCOMPLETE by strainer 2012

-- A list of string patterns for finding suggestions for the autocomplete menu.
--local IDENTIFIER_PATTERNS = {"[%a_][%w_.-:/\\\[]*[%w_(;]"}
local EditorPatt = {
	"[^%w%$]([%$]?[%a_][%w_]+[%-%:%.][%:%>]?[%\\/%$]?[%a][%w_]+)"   --punct separated terms
 ,"[^%w]([%a]+[%:][%\\/][%\\/%w%._%@ ]+[%\\/%w])"       --windows paths and urls
 ,"[%:%.]?[%a_][%w_][%w_]+[%[%(]?"   --plain terms w/ dot starts and bracket ends
 ,"[%a%$%#%@][%w_][%w_%@]+[%.%w_]*[%w_]*[%\\%[%(]?" --php and vars and fnames
 ,"[^\\]([\"][^\r\n\"]+[^\\][\"])"   --quoted terms
	,"[^\\]([\'][^\r\n\']+[^\\][\'])"   --quoted terms
	,"([%(][^\r\n]+[%)])"   --bracket terms
	,"([%[][^\r\n]+[%]])"   --bracket terms
}
local ApiPatt = {
	"[\r\n]([%$]?[%a_][%w_]+[%-%:%.][%:%>]?[%\\/%$]?[%a][%w_]+)"   --punct separated terms
 ,"[\r\n][%S]*([%:%.][%a_][%w_][%w_]+[%[%(]?)"   --plain terms w/ dot starts and bracket ends
 ,"[\r\n]([%a%$%#%@][%w_][%w_%@]+[%.%w_]*[%w_]*[%\\%[%(]?)" --php and vars and fnames
}
local IDPATTER3 = {
	"[^\\]([\"][^\r\n\"]+[^\\][\"])"   --quoted terms
	,"[^\\]([\'][^\r\n\']+[^\\][\'])"   --quoted terms
	,"([%(][^\r\n]+[%)])"   --bracket terms
	,"([%[][^\r\n]+[%]])"   --bracket terms
}

local IDPATS = { EditorPatt,ApiPatt,EditorPatt }

local wrdanc
--calcd on ac init
--may include single " ' [ or (
--will run back and stop on . ,after other punc

function chooseAnchor(pane)

	local ginPos = pane.CurrentPos
	local fosPos = ginPos
	
--	if reworking then trace("reworking") else trace("\nfirstwork") end
	
	if reworking then --goes to the first bracket
		if fosPos>0 and find(pane:textrange(fosPos-1, fosPos),"[.%[%(%$%:\"\'#]") then
			if fosPos<1 then fosPos=1 end
			return fosPos-1
		end
		--go back over words and slashes
		while fosPos>0 and find(pane:textrange(fosPos-1, fosPos),"[%w_]") do
			fosPos = fosPos-1
		end --include more word symbols?
		if fosPos>0 and find(pane:textrange(fosPos-1, fosPos),"[.%[%(%$%:]") then
			fosPos = fosPos-1	
		end
		if fosPos<0 then fosPos=0 end
		return fosPos
	end

	if fosPos>0 and find(pane:textrange(fosPos-1, fosPos),"[%[%(%$%\"\']") then
		if fosPos<1 then fosPos=1 end
		return fosPos-1
	end
		
	--go back over words and slashes
	while fosPos>0 and find(pane:textrange(fosPos-1, fosPos),"[%w_%\\/]") do
		fosPos = fosPos-1
	end --include more word symbols?

	--then go back over $ and :
	if fosPos>0 and find(pane:textrange(fosPos-1, fosPos),"[%$%:]") then
		fosPos=fosPos-1
	else
	--then go back over $ and . words
	if fosPos>0 and find(pane:textrange(fosPos-1, fosPos),"[%w_%.]") then
		fosPos=fosPos-1
		--print("didy")
	end
	--if less than 6 goback more words and slashes (filepaths)
	if ginPos-fosPos<6 then
		while fosPos>0 and find(pane:textrange(fosPos-1, fosPos),"[%w_%\\/]") do
			fosPos = fosPos-1
		end --include more word symbols
	end
	
	--then go back 1 letter ?
	if fosPos>2 and find(pane:textrange(fosPos-2, fosPos),"[%a]:")
		and find(pane:textrange(fosPos-3, fosPos-2),"[^%a]")
		then
		fosPos=fosPos-2
	end
	end
	return fosPos
end

local function getApiNames()
	
	local apiCache = Slide['autoAPIC']	
	local aapi='n'
	if props["APIPath"]~="" then aapi = props["APIPath"] end 

	if apiCache[aapi] and next(apiCache[aapi]) then return end

	apiCache[aapi]={}
	local f = io.open(aapi, "rb")
	if f then
--~ 		print("isread")
		readnames( f:read("*all"), true, 2, apiCache[aapi] )
		f:close()
	end
	
	--Slide['autoAPIC']=apiCache
	--print("gotapi "..aapi.." "..#apiCache[aapi])
end

local function getGlobNames()
	
	local p=props["GlobalAutoC"]
	if p=="" then p='o:\\hub\\code\\pad\\terse.n' end
	local f = io.open(p, "rb")
	if f then 
		readnames( f:read("*all"), true, 1, Slide['autoACou'] )
		f:close()
	end
end

function readnames(text, sw, patt, dest )
	local IDpat = IDPATS[patt or 1]
	local setword=true
	if sw=='remove' then setword = nil end	
	for _,pattern in ipairs(IDpat) do
		for word in gmatch(text, pattern) do
			dest[word] = setword
		end
	end
end

--hooked on shortcut key only
--initialises, the anchor position, the lexer

--[[
	ac in output sees  all output all current and recent docs, no api?
	ac in editor sees window of output and current doc
	
	rescan whole current doc up to limit centered around currentpos
	or last update like
	
	scan whole doc _after_ a buffer change
	track buffer path with top level local var
	
	autoCBufferPath
	just let autoc lexer api buffers fill up?
	yes, its not a leak of memory
]]

local function calcrange(pane,maxi)
	local cutread=pane.Length-maxi
	if cutread<0 then return 0,pane.Length end
	local thps=pane.LineEndPosition[pane.FirstVisibleLine]
	local readend=thps+maxi/2
	local readbgn=thps-maxi/2
	if readend>pane.Length then
		readbgn=readbgn+readend-pane.Length  readend=pane.Length
	end
	if readbgn<0 then
		readend=readend-readbgn readbgn=0
	end
	if readend>pane.Length then  readend=pane.Length  end
	return readbgn,readend
end

function autoCp() --inits

	local pane=get_pane()
	if pane:AutoCActive() then --shutdown if shortcut while active
		reworking=true
		local t=chooseAnchor(pane)
		reworking=false
		if t~=wrdanc then
			wrdanc=t
			handlepress()
			return true
		end
		acrunning =false
		pane:AutoCCancel()
		scite_OnKey(handleKey,'remove')
		scite_OnChar(handlepress,'remove')
		return
	end
	
	local outCache=Slide['autoACou']
	local ediCache=Slide['autoEDIC']
	
	if not next(outCache) then getGlobNames() end

	props["autocomplete.choose.single"] = "0"
	pane.AutoCIgnoreCase = true
	
	local aapi = props["APIPath"] or "n"
	
	acstarted =false
	local reworking=false
	wrdanc=chooseAnchor(pane)
	
	local maxin=500000
	local minim= 10000
	
--~ 	print("edcachlen="..(#ediCache[aapi]))
	ediCache[aapi]=ediCache[aapi] or {}
--~ 	print("edcachlen="..(#ediCache[aapi]))
	
	--*remove current unfinished text from names 
	local bKp=pane.CurrentPos
	local fWp=pane.CurrentPos+1
	while bKp>1 and find(pane:textrange(bKp-1,bKp),"[%w_]") do bKp=bKp-1 end 
	bKp=bKp-1
	while bKp>1 and find(pane:textrange(bKp-1,bKp),"[%w_]") do bKp=bKp-1 end 
	while fWp<pane.Length and find(pane:textrange(fWp-1,fWp),"[%w_]") do
		fWp=fWp+1
	end 
	
	if pane==editor then
		readnames( output:textrange(calcrange(output,minim) ), true, 1, outCache )
		local p,q=calcrange(editor,maxin)
		if p<bKp then readnames( editor:textrange(p,bKp), true, 1, ediCache[aapi] )
		end
		if q>fWp then readnames( editor:textrange(fWp,q), true, 1, ediCache[aapi] )
		end
	else 
		readnames( editor:textrange(calcrange(editor,minim) ), true, 1, ediCache[aapi] )
		local p,q=calcrange(output,math.floor(maxin/2))
		if p<bKp then readnames( output:textrange(p,bKp), true, 1, outCache )
		end
		if q>fWp then readnames( output:textrange(fWp,q), true, 1, outCache )
		end
	end
	
	for i,v in pairs(openedbuffers) do --read in all opened buffer names
		outCache[i]=true  --fullpath
		if find(i,"[%\\/]") then
			outCache[match(i,"[^%\\/][%w.@_ ]+$") or " "]=true
		end

	end
	
	getApiNames() --check apiNames are loaded
	
	handlepress()
	--checknames()
	return false
end

acrunning=false
local menuItems = {}
local ginlen=0
local lginlen=0
local thegofo=""
local cpos,lpos=0,0

function handlepress()

	local ediCache = Slide['autoEDIC']
	local apiCache = Slide['autoAPIC']
	local outCache = Slide['autoACou']
	
	local pane=get_pane()

--~ 	if pane==output then editor:append("paneoutput") end
--~ 	if pane==editor then editor:append("paneeditor") end
--~ 	if pane:AutoCActive() then editor:append("auto active") end

	if acstarted==pane and pane==editor and (not editor:AutoCActive()) then
--~ 		editor:append(" isherex ")
		return
	end
--~ 	editor:append(" ishere ")

	acstarted=pane
	lpos,cpos= cpos,pane.CurrentPos 

	if cpos<wrdanc then wrdanc=chooseAnchor(pane) end
	local ginlen = cpos - wrdanc
	
--* this is the goforward shalava
	local acc=pane:AutoCGetCurrent()+1
	if GoForward and #menuItems[acc]>ginlen and (os.clock()-GoneForward)<0.05 then
		return true
	end 
	if string.len(menuItems[acc] or"")>0 and GoForward then
		GoForward=nil GoneForward=os.clock()
		if #menuItems[acc]>ginlen then
			thegofo=menuItems[acc]
			pane:SetSel(wrdanc,cpos)
			pane:ReplaceSel(stringsub(menuItems[acc],1,ginlen+1))
			cpos = cpos+1
			ginlen = ginlen+1
		end
	end 
	GoForward=nil
	--* shalava fin
	local prefix = pane:textrange(wrdanc, wrdanc+ginlen)
	local nlprefix=normalize(prefix)
	local names=ediCache[(props["APIPath"] or "n")]		--*
	local shorty=2
	if ginlen<shorty then 
		namesh={}
		readnames( editor:textrange(calcrange(
			editor,1000*(ginlen+2 )) ), 
			true, 1, namesh )	
		readnames( output:textrange(calcrange(
			output,1000*(ginlen+2 )) ), 
			true, 1, namesh )	
	else
		namesh=names
	end
	local dnames={}
	
	function makemenui(menuT,glen)  --(extra testing to accelerate v.long lists)
			
		local prefix = pane:textrange(wrdanc, wrdanc+glen)
		local nlprefix=normalize(prefix)
		local ftest=glen if ftest>2 then ftest=2 end
		local nsprefix=normalize(stringsub(prefix,1,ftest))
		local mlen=0
		
		for name, v in pairs(namesh) do
			if normalize(stringsub(name, 1, ftest)) == nsprefix then
			if ftest==glen or normalize(stringsub(name, 1, glen)) == nlprefix then
				--dc=dc+1
				insert(menuT, name)
				dnames[name]=true
				mlen=mlen+1
				if mlen>200 then break end
			end
			end
		end
		if ginlen>=shorty then
			for name, v in pairs(outCache) do
				if (normalize(stringsub(name, 1, ftest)) == nsprefix) and (not dnames[name])
				and (ftest==glen or normalize(stringsub(name, 1, glen)) == nlprefix) then
					dnames[name]=true
					mlen=mlen+1
					insert(menuT, name)
					if mlen>300 then break end
				end
			end
			
			local aapi = props["APIPath"] or "n"
			
			if apiCache[aapi] and next(apiCache[aapi]) then
			for name, v in pairs(apiCache[aapi]) do

				if (normalize(stringsub(name, 1, ftest)) == nsprefix) and (not dnames[name])
				and (ftest==glen or normalize(stringsub(name, 1, glen)) == nlprefix) then
					--dc=dc+1
					insert(menuT, name)
					mlen=mlen+1
					if mlen>400 then break end
				end
			end
			end
			
		end
		
		if mlen>200 then
			if prefix==""
			then menuT[1]="..."
			else insert(menuT,prefix.."...")
			end
		end
	end
	--*
	-- nlist.n
	menuItems={}
	makemenui(menuItems,ginlen)
		
	local posts=0

	if #menuItems==1 and menuItems[1]==prefix then menuItems[1]=nil end 
	if #menuItems<16 and ginlen>2 then  --inserts postfixed paths
		--print(nlprefix)
		local done={}
		--local sprefix= escape the prefix and use it
		for name, v in pairs(outCache) do
			if find(name,"[\\/]") then 
				local n=normalize(name)
				if stringsub(n, 1+#n-ginlen) == nlprefix and #n~=ginlen
				then 
					posts=posts+1
					insert(menuItems, name)
				end
				local m=match(n,"^[%a]+[%:][%\\/].*"..nlprefix.."[^\\/]*")
				if m and not done[stringsub(name,1, #m)] then
					insert(menuItems,
						stringsub(name,find(n, nlprefix.."[^\\/]*"))
					) 
					m=stringsub(name,1, #m)
					if not dnames[m] then insert(menuItems,m) end
					done[m]=true dnames[m]=true
					posts=posts+2
--~ 					insert(menuItems, m)
										
					m=match(n,"^[%a]+[%:][%\\/].*"..nlprefix
									..".*"..nlprefix.."[^\\/]*")
					if m and not done[stringsub(name,1, #m)] then
						m=stringsub(name,1, #m)
						if not dnames[m] then insert(menuItems,m) end
						done[m]=true dnames[m]=true
						posts=posts+1
					end
				end 
			end 
		end --rechecking outcache
--~ 		if#menuItems==posts and posts>1 then insert(menuItems, prefix) end
	end
	
	local minimenu ={}
	
	if #menuItems==1 and CompleteSingle then
		if posts==0 then makemenui(minimenu,ginlen-1)
		else minimenu[1]=true
		end
	end
 
	--print(#menuItems,#minimenu)
	
	if #minimenu==1 and thegofo=="" and cpos-lpos~=-1 then
		pane:SetSel(wrdanc,cpos)
		pane:ReplaceSel(menuItems[1].."")
		pane:AutoCCancel()
		
		acrunning=false
		scite_OnKey(handleKey,'remove')
		scite_OnChar(handlepress,'remove')
	else --
	
		if ginlen~=0 then
			table.sort(menuItems, function(a,b) return normalize(a) < normalize(b) end)
		end
			
		if ((#menuItems==0 or #menuItems==1 
		and #menuItems[1]==ginlen ))
		and not reworking then
			--print("triedit",wrdanc)
			reworking=true
			wrdanc=chooseAnchor(pane)
			--print("triedot",wrdanc)
			handlepress()
			reworking=nil
			return true
		end
		
		pane.AutoCSeparator = 1
		pane:AutoCShow(ginlen, table.concat(menuItems, "\1"))
		
		if thegofo~="" then 
			pane:AutoCSelect(thegofo)
			thegofo=""
		end
		
		acrunning=true
		scite_OnKey(handleKey)
		scite_OnChar(handlepress)
	end
	
	return true
end

-- Add event handler in a cooperative fashion: (thanks ahk forum guy)
--OnKey(handleKey)
--~ 		if _G[OnKey] then
--~ 			_G[OnKey] = function(...) return handleKey(...) or OnKey(...) end
--~ 		else
--~ 			_G[OnKey] = handleKey
--~ 		end


function handleKey(key, shift, ctrl, alt) --f/ ahk forum guy

	--trace(' K ')
	if alt or ctrl then return end

	if not get_pane():AutoCActive() then
		acrunning=false
		scite_OnKey(handleKey,'remove')
		scite_OnChar(handlepress,'remove')
		return
	elseif key == 0x27 then --cursor forward
		local s=get_pane():textrange(get_pane().CurrentPos,get_pane().CurrentPos+1)
		if find(s,"[%s\n\r]") or get_pane().CurrentPos==get_pane().Length then
			GoForward=true
			handlepress()
			return true
		end
	end

	--scite_OnKey('once',handleKey,remove)
	--scite_OnChar('once',handlepress,remove)

	if key == 0x8 then -- VK_BACK
		if not ctrl then
			-- Need to handle it here rather than relying on the default
			-- processing, which would occur after handleChar() returns:
			get_pane():DeleteBack()
			handlepress()
			return true
		end
	elseif key == 0x9 or key == 0x20 then -- VK_TAB and SPACE
		if not ctrl then
			acrunning=false
			scite_OnKey(handleKey,'remove')
			scite_OnChar(handlepress,'remove')
			get_pane():AutoCCancel()
			return
		end
	elseif key == 0x26 or key == 0x28  then -- VK_up and down
		return false
	elseif key == 0x25 then -- VK_LEFT
		if not shift then
			if ctrl then
				get_pane():WordLeft() -- See VK_BACK for comments.
			else
				get_pane():CharLeft() -- See VK_BACK for comments.
			end
			handlepress()
			return true
		end
	end
	-- ~ 			trace("wog")
	return false --return false continues processing(!) remember this dummy
end
