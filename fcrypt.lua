--andrew strain MIT licence w/ Rob Kendricks MIT arcfour.lua lib
--encrypt textfiles in scite slide compilation
--this is configured insecurely
--use and reconfigure at your own risk
--this is alpha version software and may be buggy

--basic usage:
--in slide type lua:mork()
--the current file will be encrypted and open automatically using global key
--lua:mork("uniquekey")  encrypts file with unique key which will need input
--every 
--type lua:unmork() to stop encrypting opened file or
--lua:unmorkall() to unmork all opened encrypted files

--notes: each line is encrypted by a quick amature cypher on line length,
--and encrypted again by proper arcfour cypher

require "arcfour"

function string:unconcat(sep)
  local fi, ult, sep, fields, pattern = 1, 1, sep or "", {}

  if sep~="" 
  then pattern = string.format("([^%s]*)[%s]?", sep,sep)
  else pattern ="(.)" end
  
  if self:sub(#self-#sep+1)~=sep 
  then ult=0 end
  
  local function cc(c)  fields[fi] = c  fi=fi+1  end
  self:gsub(pattern, cc)
  
  if ult==0 then fields[#fields]=nil end
  return fields
end

local hdr="~H~i~D~\n"
local csuccess

local cropkey=7  --7 is only quite secure 56bits, 
local auxkey=props['slide.morkey'] 
if auxkey =='' then auxkey = "defaulted" end

--local auxkey="averysecretpass" --applications automatic password is not set
-- changing cropkey invalidates all existing encrypted documents
-- cropkey crops key hashes to value*8 bits, 
-- value of 8 or more may concern some national security restrictions
-- change auxkey to personalise your default password 

local ggsub=string.gsub

function saveEncrypted()
  local tfile=props['FilePath'] 
  local key = morkedfiles[tfile]
  if not key then return false end

  local mask=key.."x"
  while #mask<cropkey do mask=mask..mask end
  local bigkey= arcfour.new(key):cipher(mask:sub(1,cropkey))

  local Bcys = arcfour.new(bigkey)
  Bcys:generate(2222,true)
  local scrum=Bcys:generate(1111)
  Bcys:Sstash(true)
  
  local out = assert(io.open(tfile, "wb"))
  
  local eo=tostring(editor.EOLMode)
  local tosave = {}
  table.insert(tosave,hdr)
  tx=eo..eo..(editor:GetLine(0) or "")
  for l=1,editor.LineCount do
  
    if tx then
      tx=Bcys:scram(tx,scrum)
      tx=Bcys:cipher(tx)  Bcys:SstashU()
--~ 			tx=ggsub(tx,"(.)","\\%1")
      tx=ggsub(tx,"\\","\\\\")
      tx=ggsub(tx,"\n","\\x\\n")
      tx=ggsub(tx,"\r","\\x\\r")
      tx=ggsub(tx,"\f","\\x\\f")
      tx=ggsub(tx,"\x00","\\x\\z")
      tx=ggsub(tx,"\x0b","\\x\\v")
      tx=ggsub(tx,"\x08","\\x\\B")
      tx=ggsub(tx,"\x07","\\x\\b")
      
--~ 			tx=ggsub(tx,"\r","RR")
    end
    table.insert(tosave ,tx or "")
    table.insert(tosave,"\n")
    tx=editor:GetLine(l)
  end
  
  tosave[#tosave]=nil
  
  out:write(table.concat(tosave))
  assert(out:close())
  
--~ 	print("encrypted with"..key)
  return true
end 

function openEncrypted(key,force)
  local ggsub=string.gsub
  local tfile=props['FilePath'] 
  
  --force=true 
  if key==tfile then key=morkedfiles[tfile] end
  local key = (key or morkedfiles[tfile]) or auxkey
  if not ( force or (editor.Length>#hdr+#key+1 and editor:textrange(0,#hdr)==hdr )) 
  then return false end

  csuccess=false

  local mask=key.."x"
  while #mask<cropkey do mask=mask..mask end
  mask=mask:sub(1,cropkey)

  local enckey = arcfour.new(key)
  local bigkey= enckey:cipher(mask)

  local Bcys = arcfour.new(bigkey)
  Bcys:generate(2222,true)	
  local scrum=Bcys:generate(1111)
  Bcys:Sstash(true)
  
  local inp = assert(io.open(tfile, "rb"))
  local head = inp:read(#hdr)
  --print(head)
  if not (head==hdr or force) then
    print("- No Encryption header present")
    assert(inp:close())
    return false
  end
  local data = inp:read("*a")
  assert(inp:close())
  
  local cpos=editor.CurrentPos
  local apos=editor.Anchor
  
  local lines={}
  lines=data:unconcat("\n")
  
  for i=1,#lines do

    if lines[i] then
      lines[i]=ggsub(lines[i],"\\x\\z","\x00")
      lines[i]=ggsub(lines[i],"\\x\\v","\x0b")
      lines[i]=ggsub(lines[i],"\\x\\B","\x08")
      lines[i]=ggsub(lines[i],"\\x\\b","\x07")
      lines[i]=ggsub(lines[i],"\\x\\n","\n")
      lines[i]=ggsub(lines[i],"\\x\\r","\r")
      lines[i]=ggsub(lines[i],"\\x\\f","\f")
      lines[i]=ggsub(lines[i],"\\\\","\\")
      lines[i]=Bcys:cipher(lines[i])	
      lines[i]=Bcys:scram(lines[i] or "",scrum)
      Bcys:SstashU()
    else
      lines[i]=""
    end
  end
  
  local eol=lines[1]:sub(1,2)
  if eol:sub(1,1)~=eol:sub(2,2) and not eol:match("[%d][%d]") then
    uptrace("\n- Demorking failed:\n"..tfile,1,0)
    return
  end
  
  lines[1]=lines[1]:sub(3)
  morkedfiles[tfile]=key
  editor.UndoCollection=0
  editor:ClearAll()
  editor.EOLMode=tonumber(eol:sub(2)) or 2
  editor:AppendText(table.concat(lines))
  editor:SetSel(apos-#hdr,cpos-#hdr)
  editor:EmptyUndoBuffer()
  editor.UndoCollection=1
  editor:SetSavePoint()
  csuccess=true
  return false
end 




function mork(key,force)
  local tfile=props['FilePath'] 
  if morkedfiles[tfile] and not force then 
    print("- Already Morked : "..tfile) return 
  end
  editor:AddText ("m") editor:DeleteBack()
  print("- Ok. Save now to mork (fragile keep a safe copy): "..tfile) 
  morkedfiles[tfile]=key or auxkey
end

function unmorkall()
  local g=props['FilePath']
  for i,v in pairs(morkedfiles) do
    scite.Open(i)
    --unringc()
    editor:AddText ("m") editor:DeleteBack()
    print("-Unmorked "..i)
    morkedfiles[i]=nil
  end
  scite.Open(g)
end

function demork(key,force)
  local tfile=props['FilePath'] 
  morkedfiles[tfile]=key
  openEncrypted(key,force) 
  
  if csuccess then
    print("- Demorked : "..tfile)
  else
    morkedfiles[tfile]=nil
    print("- Demork unsuccessful : "..tfile)
  end
end

function unmork()
  local tfile=props['FilePath'] 
  
  if not morkedfiles[tfile] then
    print("- Was not morked : "..tfile) return
  else
    morkedfiles[tfile]=nil
    editor:AddText ("u") editor:DeleteBack()
    print("- No Longer morking : "..tfile) return
  end
end

scite_OnOpen(openEncrypted)
scite_OnBeforeSave(saveEncrypted)
--scite_OnSave(decrypt)

--[[
  fast encrypts each line with len as key
  slow encrypt each line again with  long key
  escape and substite the \r\n\fs
  concat lines with \n
  write
  
  to decrypt
  unconcat lines with \n
  subst the \r\n\fs
  slow decrypt with long key
  fast decrypt with len as key
  concat lines without \n
  put in editor
  

lua:mork(key,force)   //encrypt a file
lua:unmorkall()       //stop encrypting all opened encrypted files
lua:demork(key)  (or shortcut d:key) //open encrypted file
lua:unmork()          //stop encrypting current file

]]