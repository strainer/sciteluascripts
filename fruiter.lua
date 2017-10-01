
--[[FRUITER!]]--


function fruition() --reads the current buffer and clips magic areas out to a file
	
	local fsep4="%-~%-·~%-~·%-~%-"
	local fsep3="%-·~%-~·~%-~·%-"
	local fsep2="%-~~%-~~~%-~~%-"
	--~ 	local fsep4="-~-·~-~·-~-"
	--~ 	local fsep3="-·~-~·~-~·-"
	--~ 	local fsep2="-~~-~~~-~~-"
	
	if not string.match(props["FileNameExt"],"\.n$") then return end  --no magic filetype
	if not editor:findtext(string.gsub(fsep3,"%%",""),0) then return end --no magic separator
	if not editor:findtext(string.gsub(fsep4,"%%",""),0) then return end    --no magic separator
	
	local pout=nil
	local zeol=eolchars(editor)	
	local edtx=editor:GetText()
	
	local berry=0 --number of berrys (notelists)
	
	local fsta, flen = 1, string.len(edtx)
	local filetxs,filetxe,scrolts,scrolte,savetxs,savetxe ={},{},{},{},{},{}
	
	local sfind=string.find
	local smatch=string.match
	local sgsub=string.gsub
	
	local bugg=0
	while fsta<flen and bugg<200 do	
		
		--~   if true then return end
		
		
		local whk1s,whk1e,frutx	
		= sfind(string.sub(edtx,fsta)
			,"(%#[^%w\r\n]*%-[^%-]*%-[%s\r\n]*%w+[^\n\r]*%.+%w+[^\n\r]*[\n\r]+.-"
			..fsep3.."[^\n\r]*[\n\r]+.-)"..fsep4) 
		
		--~   if true then return end
		
		bugg=bugg+1
		if not whk1s then
			fsta=flen
			--print("nofish")
			--~   if true then return end
			
		else
			berry=berry+1
			--~ 	if true then return end
			
			whk1s=whk1s+fsta-1
			whk1e=whk1e+fsta-1
			fsta=whk1s+sfind(frutx,"[\r\n]")
			
			_,hk1s=sfind(frutx,"%#[^%-\r\n]*%-[^%-]*%-%s*" )   --filename
			_,hk1e=sfind(frutx,"%#[^%-\r\n]*%-[^%-]*%-[%s\n\r]*[^\n\r]*")  --filename
			--~ 				print("file "..string.sub(frutx,hk1s,hk1e))
			
			local slipr=nil
		if hkls then slipr=smatch(string.sub(frutx,hkls,hkle),".-%-~%>(.*)") end
		
		if slipr then
			hk1s,hk1e,hk2s,hk2e=sfind(frutx,".*%-%s*(.*)%s*%-~%>([^\r\n]*"..zeol..")")
		else
			_,hk2s=sfind(frutx,fsep2.."[^\n\r]*")
			hk2e,_=sfind(frutx,fsep3) 
		end
		
		filetxs[berry]=hk1s+whk1s
		filetxe[berry]=hk1e+whk1s-1          --no line ends iinc
		--~ 			print("file "..string.sub(edtx,filetxs[berry],filetxe[berry]))
		
		--hk2s,hk2e=string.find(frutx,fsep2.."(.*)"..fsep3)
		scrolte[berry]=hk2e+whk1s-2
		if hk2s then scrolts[berry]=hk2s+whk1s 
			if not smatch(string.sub(edtx,scrolts[berry],scrolte[berry]),zeol..".*"..zeol)
				then scrolts[berry]=nil
			end
			--~  				print("scrol "..(scrolte[berry]-scrolts[berry]+1)..string.sub(edtx,scrolts[berry],scrolte[berry]))
		else --from first newline to last newline iinc 
			scrolts[berry]=nil --possibly set in previous lp
		end
		
		_,hk3s=sfind(frutx,fsep3.."[^\n\r]*")
		_,hk3e=sfind(frutx,fsep3..".*") 
		
		savetxs[berry]=hk3s+whk1s --from first newline to last newline iinc
		savetxe[berry]=hk3e+whk1s-1 
		--~ 			 print(berry.." save "..(savetxe[berry]-savetxs[berry]+1)..string.sub(edtx,savetxs[berry],savetxe[berry])) 
		
		local ff=edtx:sub(filetxs[berry], filetxe[berry])
		local tt=edtx:sub(savetxs[berry], savetxe[berry])
		
		if not smatch(tt, zeol..".-([^%s]).-"..zeol)  --no save feild 
			then berry=berry-1 
		elseif not sfind(ff,"\.")          --no file feild
			then berry=berry-1 
		end
		
	end   --tabling valid feilds
	
	if berry==100 then return end    --debug help
end --locating valid feilds

--~   if true then return nil end

for ib = berry,1,-1 do
	--~  print("doing "..ib)
	--~  print("file>"..edtx:sub(filetxs[ib],filetxe[ib]).."<file")
	
	local noscroll=false --say when berry has no scroll feild
	
	local scrolr	
	if scrolts[ib] then scrolr=edtx:sub(scrolts[ib],scrolte[ib]) or "" --scroller
	else scrolr=""     noscroll=true     end
	
	local scrole=edtx:sub(savetxs[ib],savetxe[ib]) or "" --scrollee
	
	scrole=sgsub(scrole,zeol,"\n")
	scrole=sgsub(scrole,"[\n\r]",zeol) --fix any weird ends
	scrole=smatch(scrole, zeol.."(.*)") --take top ends off scrole
	scrolr=sgsub(scrolr,zeol,"\n")
	scrolr=sgsub(scrolr,"[\n\r]",zeol) --fix any weird ends
	--~  		print("scrole="..scrole.."=")
	local bub=0
	local thap=""
	local thip=""
	
	while scrole ~="" and bub<200 do --while lines to send to scroll
		bub=bub+1
		--~ 			print("-------------")
		--~  			print("scrole="..scrole.."=")
		--~ 		  print("scrolr="..scrolr.."=")
		local thop=smatch(scrole, "([^\r\n]*"..zeol..")") 
		or zeol --top line of scrollee in lf
		if thop~=zeol then thip =thop end 
		--~  			print("thop="..thop.."=")
		--~ 			print("-------------")
		scrole=smatch(scrole, "[^\r\n]*"..zeol.."(.*)") 
		or "woops" --scrollee clipped top
		scrolr=smatch(scrolr, zeol.."[^\r\n]*(.*)") or zeol --scroll panel clip
		
		scrolr=scrolr..thop
		thap=thap..thop
	end
	
	thap=smatch(thap,"(.*)")
	
	if bub>0 then
		local tsfile=edtx:sub(filetxs[ib],filetxe[ib])
		append_string_to_file(tsfile,thap ) 
		if not pout then print() end
		trace(tsfile..":1: "..thip) pout=true
		local pchang=0
		if scrolts[ib] then 
			pchang= string.len(scrolr)-(scrolte[ib]-scrolts[ib])-1
		end
		
		editor:BeginUndoAction()
		
		if not noscroll then 
			editor:SetSel(scrolts[ib]-1,scrolte[ib])
			editor:ReplaceSel(scrolr)
		end
		
		editor:SetSel(pchang+savetxs[ib]-1,pchang+savetxe[ib])
		editor:Clear()
		editor:NewLine() 
		local p =editor.CurrentPos 
		editor:NewLine()
		editor.CurrentPos=p editor.Anchor=p
		editor:EndUndoAction()	
		
	end
end --each berry
if pout then tracePrompt() end	
end

--scite_BeforeOnSave(fruition)
scite_OnBeforeSave(fruition,"remove")
scite_OnBeforeSave(fruition)

function eolchars(pane)  --not done yet
	if not pane then pane=editor end
	local chars="\n"
	local emo=pane.EOLMode
	if emo==0 then return "\r\n" end
	if emo==1 then return "\r"   end
	if emo==2 then return "\n"   end
	if emo==3 then return "\n"   end
end

local function countlines(str)
	rr=1
	while gfind(str,"[\r\n]+") do rr=rr+1 end
	return rr
end

local function flname(fname)
	local fruitpath = props["fruitpath"] or ""
	if not string.find(fname,"[/\\]") then
		fname=fruitpath..fname
	end
	return fname
end

function sappend(fname) --selection append to given file
	local packet = editor:textrange(editor.CurrentPos, editor.Anchor)
	if packet then
		editor:Cut()
		append_string_to_file(fname,packet)
		print(">sap:"..flname(fname))
	else
		print("-sap: empty")
	end
	--tracePrompt()
end

function append_string_to_file(fname,taxt)
	
	fname=flname(fname) or ""	
	
	local frutxt,flen=LoadEnd(fname)
	if frutxt then
		stig=string.match(frutxt,".+\"(%u%l%l%s%s?.%d%s%u%l%l)%s%d%d") or "" --the last time pattern
	else
		print("Made a new fruit .. "..fname) --orchard,
		frutxt=""	
	end
	local stug=os.date("%a%d%b")
	
	local marn=""
	local monn=" .¸.·^·.¸.·´`·.¸.·^·.¸.\r\n"
	if string.gsub(stig,"%s","")~=stug then marn=monn..'"'..os.date("%a %d %b %H:%M 0%y")..'"'.."\r\n" end
	
	AppendData(fname, marn..taxt)
end


------------------------------------------------------------------------
-- modified file I/O functions from the great hexedit by %star%
------------------------------------------------------------------------
function LoadEnd(fpath)
	local filepath=string.gsub(fpath,"[\\/]","\\\\")
	local INF = io.open(filepath, "rb")
	if not INF then
		print("Failed to open '"..filepath.."'") 
		return ""
	end
	
	local noo=INF:seek("end",-4000) or "nil"
	
	print("seeked to:"..noo)
	local src=INF:read("*a")
	
	io.close(INF)
	
	return src
end

-- use f:seek to return only last bit of file to look for date 
--~ function LoadDatar(fpath)
--~   local BLOCKSIZE=1024*64
--~   local SIZELIMIT=4096
--~   local filepath=string.gsub(fpath,"[\\/]","\\\\")
--~   local INF = io.open(filepath, "rb")

--~   if not INF then
--~     --print("Failed to open '"..filepath.."' for reading") 
--~ 		local g,l="",0
--~ 		return "",0
--~   end
--~ 
--~ 	local len = 0

--~ 	local blk, err = INF:read(BLOCKSIZE)
--~ 
--~ 	if not blk then
--~ 		if err then
--~ 			print("Failed to read from '"..filepath.."'")
--~ 			io.close(INF) return
--~ 		end
--~ 		return "",0
--~ 	end
--~ 
--~ 	len = string.len(blk)
--~ 	io.close(INF)
--~   if len == 0 then src = "" else src = blk
--~   return src, len
--~ end

------------------------------------------------------------------------
-- basic data saver
------------------------------------------------------------------------
function AppendData(filepath, filedata)
	local ONF = io.open(filepath, "a+")   -- write data to file
	if not ONF then
		ONF = io.open(filepath):write("")
		--makefile(filepath)
		print("Created '"..filepath.."' for fruiting") return
	end
	local okay = ONF:write(filedata)
	io.close(ONF)
	if okay then return true end
	print("Failed to write data to '"..filepath.."'")
	return true
end	

-- Read Favourites File
-- On Windows: %USERPROFILE%\SciTE.favs
-- On Unix: $HOME/.SciTE.favs
-- Returns list of valid paths
