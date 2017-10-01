local find = string.find 
local match= string.match
local gsub = string.gsub 
local insert = table.insert 
local sub= string.sub
local tain= tain
local poslinestfn = poslinestfn
--abc abbbbc aabcc a a abc abc[] abc() abc_abc
--typical localslocal tdum,tdee,swp  --tweedles, swapped
local tsline,tslpos  --thisline thislineposition
local tpath          --this path
local str            --a string
local pane           --the pane
local _,u,v,w,a,b    --transients
local hit, fpos, cnt --hit, found pos, count
local multirun
local rcmark=11 --recoin mark
--[[

hotkeyed renaming tool, recoin
keying on a selected word, lists the word in current and recent files

todo
Will enter file recoin mode..
leaving the word via cursors leaves the mode
replacing word
]]


local function domarkers(a,e)
    scite.SendEditor(SCI_SETINDICATORCURRENT, 0)
    scite.SendEditor(SCI_INDICATORCLEARRANGE, 0, editor.Length)
    scite.SendEditor(SCI_INDICSETALPHA, 0, 70)
    scite.SendEditor(SCI_INDICSETOUTLINEALPHA, 0, 160)
    scite.SendEditor(SCI_INDICSETUNDER, 0, 1)
    scite.SendEditor(SCI_INDICSETFORE, 0, 0x3f7f7f) --bgr
    scite.SendEditor(SCI_INDICSETSTYLE, 0, 7)
    if e and e>a then scite.SendEditor(SCI_INDICATORFILLRANGE, a, e - a) end
end

local function domarkersx(st,fn)
--~ 	editor:MarkerDefine(rcmark, SC_MARK_CIRCLE, 0)
  editor:MarkerDeleteAll(rcmark)
  if not st then return end

  editor:MarkerSetBack(rcmark, 0x00ccff)
  editor:MarkerSetAlpha(rcmark, 40)
  editor.MarginMaskN[1] = 33554431-(2^rcmark)
  
  for line = editor:LineFromPosition(st),
             editor:LineFromPosition(fn-#nlchar()) 
  do 
    editor:MarkerAdd(line, rcmark)
  end
end

slide_Command("Recoin|recoin_hotkey|Ctrl+;")
--[[
]]
function recoin_hotkey() 
    
--~ 	print('hotkey')
  
  if (get_pane())==output then return end
  
  Slide.recoin=Slide.recoin or {}

  local kr,cp,bcp = editor.Anchor, editor.CurrentPos, editor.CurrentPos
  if kr>cp then kr,cp=cp,kr end
      
  local u,v,kln=poslinestfn(kr)
  local ws,w,cln=poslinestfn(tain(cp,v))
    
  local hassel= (cln==kln and kr~=cp)
  
  local ttime=os.time()
  
  local cfp= props['FilePath'] or "nil"
  local rcfp= Slide.recoin[cfp]
  
  if not rcfp then           --init single line or scope
    Slide.recoin[cfp]={}
    rcfp=Slide.recoin[cfp]
    rcfp['hottime']=ttime
    scite_OnChar(recoin_onChrKy)
    scite_OnKey(recoin_onChrKy)
    rcfp.wdst= math.floor((kr+cp)/2)
    rcfp.wdfn= rcfp.wdst

    if canscope or not rcfp.mskst then
      --tweak selection if ends on start of newline
      --if ws==cp then cp=cp-#(nlchar()) cln=cln-1 w=cp end
      if kln~=cln then
        rcfp.mskst=u  rcfp.mskfn=w
      else
        if cp-kr<4 then
          rcfp.mskst=ws  rcfp.mskfn=w
        else
          rcfp.mskst=kr  rcfp.mskfn=cp
        end
      end
--~ 			rcfp['multiline']=true
      cp=bcp editor.CurrentPos=bcp
      editor.Anchor=bcp
      hassel=false
    else	
      rcfp.mskstl=kln rcfp.mskfnl=cln
      rcfp.mskst=editor:PositionFromLine(kln) 
      rcfp.mskfn=editor.LineEndPosition[cln]
    end
    
  --continue with, subsequent press behaviour:
  --no rcfp, no multiline,
  elseif ttime-rcfp['hottime']<3 and not rcfp['multiline'] then
    
    rcfp['multiline']=true
    rcfp.mskstl=kln rcfp.mskfnl=cln
    local mnln = editor.FirstVisibleLine
    local mxln = mnln+editor.LinesOnScreen-2
    local stick=-1
    repeat
      local f,a,cln=poslinestfn(nil,nil,nil,rcfp.mskfnl+1)
--~ 			print(stick,f,a,cln)
      if stick==cln then break else stick=cln end
      if editor:findtext("\\w+", SCFIND_REGEXP, f, a) then 
        rcfp.mskfnl=rcfp.mskfnl+1
      else break end
    until rcfp.mskfnl==mxln
    stick=-1
    repeat
      local f,a,cln=poslinestfn(nil,nil,nil,rcfp.mskstl-1)
      if stick==cln then break else stick=cln end
      if editor:findtext("\\w+", SCFIND_REGEXP, f, a) then 
        rcfp.mskstl=rcfp.mskstl-1 
      else break end
    until rcfp.mskstl==mnln
    
    rcfp.mskst=editor:PositionFromLine(rcfp.mskstl) 
    rcfp.mskfn=editor.LineEndPosition[rcfp.mskfnl]

  elseif not hassel then
    return closerecoin()
  else
    rcfp.wdst= kr
    rcfp.wdfn= cp
  end

  recoin_setmask(
    rcfp, rcfp.mskst, rcfp.mskfn,
    rcfp.wdst,
    rcfp.wdfn,
    hassel
  )
--~ 	rcfp.wdst,rcfp.wdfn=caret_land(editor,cp,"[^$%w_]",true)
end	

function recoin_setmask(rcfp,mskst,mskfn,wst,wfn,hassel)

--~ 	print('setmask',mskst,mskfn,wst,wfn,hassel)
  
  mskst=mskst or rcfp.mskst
  mskfn=mskfn or rcfp.mskfn

  wst= wst or editor.Anchor
  wfn= wfn or editor.CurrentPos
  if wst==wfn then 
    wst,wfn,xx=dcrnword(wst)
--~ 		print("q:"..xx..":")	
  end
  if wst>wfn then wst,wfn=wfn,wst end
  
  wrd=editor:textrange(wst,wfn)	
  
--~ 	print("w:"..wrd..":")

  rcfp['bmap']=recoin_mask(mskst,mskfn, wst,wfn, hassel, editor)
  
  rcfp['wrd']=wrd rcfp['wdst']=wst rcfp['wdfn']=wfn
  rcfp['mskst']=mskst rcfp['mskfn']=mskfn
  rcfp['mskstl']=editor:LineFromPosition(mskst) 
  rcfp['mskfnl']=editor:LineFromPosition(mskfn-#nlchar())
  
  domarkers(rcfp.mskst,rcfp.mskfn)
end
--abc abc abc abc abc

function recoin_mask(dst,dov,wst,wfn,hassel,pane)
--~ 	print("msk ran")
  wst= wst or editor.Anchor
  wfn= wfn or editor.CurrentPos
  local fq,aq=poslinestfn(wfn)
  if wst==wfn then --or wst<fq or wst>aq then 
    wst,wfn=dcrnword(math.floor((wst+wfn)/2))
--~ 		print("w2:"..editor:textrange(wst,wfn)..":")	
  end 
  if wst>wfn then 
    wst,wfn=wfn,wst 
    rcfp['wdst']=wst rcfp['wdfn']=wfn
  end
  if dst>dov then dst,dov=dov,dst end
  
  pane = pane or editor 
  local sdt=pane:textrange(dst,dov)
--~ 	print("tr:"..sdt..":")
--~ 	print(wst,wfn)
--~ 	print("wrt:"..pane:textrange(tain(wst,wfn),wfn)..":")
  wst=wst-dst+1 wfn=wfn-dst 
  local wrd=sdt:sub(wst,wfn)
--~ 	print("wrd:"..wrd..":")
--~ 	print(wst,wfn)
  
  
  local dtln=#sdt
  local nk,mtchs=1,{}

  local ffwd=wrd:sub(1,1)
  local afwd=wrd:sub(-1,-1)

  if hassel then
    ffwd,afwd="",""
  else 
    ffwd,afwd="%f[%w_]","%f[^%w_]" 
  end
    
  local patt=ffwd..string.gsub(wrd, "([%(%)%.%%%+%-%*%?%[%^%$])", "%[%%%1%]")..afwd

--~ 	if true then print(patt) end
--~ 	print("pt:"..patt..":\n")
  repeat
    
    local st,fn = string.find(sdt, patt , nk )

    if st then
      if st>wfn or fn<wst then 
        insert(mtchs,st) insert(mtchs,fn) 
--~ 				trace(":m:"..sdt:sub(st,fn)..":")
      end
      nk=fn+1
    else
      nk=dtln
    end
  until	nk >= dtln
--~ 	print("msk ret")

  return mtchs
end

local function isoutwd(kp,wst,wfn)
  return kp<wst or kp>wfn
end

function dcrnword(pos,pane,wchr)
  pane=pane or editor
  pos= pos or pane.CurrentPos
  wchr=wchr or "%w$_"
  wchr="["..wchr.."]"
  local lf,la=poslinestfn(pos)
  
  local ltxt=pane:textrange(lf,la)
--~ 	print("ltxt:"..ltxt..":")
  local ltl=#ltxt
  local subp=pos-lf
  local qfp,qap=subp,subp
  
  while qfp>0 and string.sub(ltxt,qfp,qfp):find(wchr) do
    qfp=qfp-1
  end
  
  while qap<ltl and string.sub(ltxt,qap+1,qap+1):find(wchr) do
    qap=qap+1
  end
  
--~ 	print("ss:"..string.sub(ltxt,qfp+1,qap)..":")
--~ 	print("pt:"..pane:textrange(lf+qfp,lf+qap)..":")
  
  return lf+qfp, lf+qap, string.sub(ltxt,qfp+1,qap)
end


function closerecoin()
  domarkers()
  Slide.recoin[(props['FilePath'] or "nil")]=nil
  scite_OnChar(recoin_onChrKy,'remove')
  scite_OnKey(recoin_onChrKy,'remove')
  return true
end

function recoin_onChrKy(char, shift, ctrl)

  if get_pane()==output then return end
  local rcfp= Slide.recoin[props['FilePath'] or "nil"]
      
  if not rcfp then
    if not Slide.recoin['paused'] then
--~ 			uptrace("+ Recoin quick is paused\n",1,0)
      Slide.recoin.paused=true
    end
    return --
  else
    if Slide.recoin.paused then
--~ 			uptrace("- Recoin quick is active\n",1,1)
      Slide.recoin.paused=false
    end
  end
    
  local f,c,a
  local bwdst,bwdfn=rcfp.wdst,rcfp.wdfn
  local kp,cp=editor.Anchor,editor.CurrentPos
--~ 	rcfp['lastkp2']=rcfp['lastkp'] rcfp['lastcp2']=rcfp['lastcp']
  local _,_,cl=poslinestfn(cp)
  
  if (ctrl and char==83) 
  or cl<(rcfp.mskstl-1) 
  or cl>(rcfp.mskfnl+1) 
  or (rcfp.mskst>cp+1) 
  or (rcfp.mskfn<cp-1) 
  then 
    --cp~=tain(cp,rcfp.mskst,rcfp.mskfn) then
    return closerecoin()
  end
  
  local retv=false

  if char=="autoc" then return end
  
  if char==32 and shift then --space and shift
    editor:ReplaceSel(" ")
    rcfp.mskfn=rcfp.mskfn+1
    recoin_setmask(rcfp,rcfp.mskst,rcfp.mskfn)
    return true
  end
  
  if char==8 then --backspace
    
    local jbk=0
    
    if kp~=cp then
      if kp>cp then kp,cp=cp,kp end
      recoin_setmask(rcfp,rcfp.mskst,rcfp.mskfn,kp,cp,true)
      bwdst,bwdfn=rcfp.wdst,rcfp.wdst  --?
      editor:remove(kp, cp)
      editor:GotoPos(kp)
      rcfp.mskfn=rcfp.mskfn-cp+kp
    elseif ctrl then
      f,a=dcrnword(editor,cp-1)
      if f>a then a,f=f,a end
      if isoutwd(cp,bwdst,bwdfn) or isoutwd(f,bwdst,bwdfn) then 
        recoin_setmask(rcfp) 
        bwdst,bwdfn=rcfp.wdst,rcfp.wdfn
      end
      bwdfn=bwdfn-math.abs(cp-f)
      editor:SetSel(f,cp)
      editor:DeleteBack()
      rcfp.mskfn=rcfp.mskfn-math.abs(cp-f)	
    else --just backspace
      
      if isoutwd(cp,bwdst,bwdfn) then 
--~ 				print("outwd")
        recoin_setmask(rcfp) 
        bwdst,bwdfn=rcfp.wdst,rcfp.wdfn
      end
      
      editor:DeleteBack()
      jbk=cp-editor.CurrentPos
      cp=cp-jbk
      
      bwdfn=bwdfn-jbk
      rcfp.mskfn=rcfp.mskfn-jbk

    end
    
    if editor.CurrentPos<rcfp.mskst then
      rcfp.mskst=rcfp.mskst-jbk
      rcfp.wdst=rcfp.wdst-jbk
      rcfp.wdfn=rcfp.wdfn-jbk
      return true 
    end
    
    retv=true
  
  --fwd del w ctrl 
  --bwd= remved string as stored in prev msk, also
  --on outwd resetmask after edit, reset beforewd
  elseif char==46 then --forward delete
    if ctrl then
      f,a=dcrnword(editor,cp+1)
      bwdfn=bwdfn-math.abs(cp-a)
      editor:remove(cp, a)
      rcfp.mskfn=rcfp.mskfn-a+cp
      if isoutwd(cp,bwdst,bwdfn) then 
        recoin_setmask(rcfp) 
        bwdst,bwdfn=rcfp.wdst,rcfp.wdfn
        end
    else
    --all ops are complicated byhow 
    --we are performing the singular edit before
    --the operation to use the mask to edit the whole
    
      bwdfn=bwdfn-1
      editor:remove(cp, cp+1)
      rcfp.mskfn=rcfp.mskfn-1
      if isoutwd(cp,bwdst,bwdfn) then 
        recoin_setmask(rcfp) 
        bwdst,bwdfn=rcfp.wdst,rcfp.wdfn
      end
    end
    retv=true
  
  elseif type(char)=='number' then 
    rcfp['lastkp']=kp rcfp['lastcp']=cp
    return retv
        
  end
  --ends the onkey processing
  
  rcfp.rekeyed=0
  if type(char)=='string' then 
    
    bwdfn=bwdfn+#char
    
    if rcfp.lastkp~=rcfp.lastcp then --key is pressed on a selection
      editor:Undo()
--~ 			print("undid")
      kp=rcfp.lastkp local cpq=rcfp.lastcp
      if kp>cpq then kp,cpq=cpq,kp end
      recoin_setmask(rcfp,rcfp.mskst,rcfp.mskfn,kp,cpq,true)
      bwdst,bwdfn=rcfp.wdst,rcfp.wdst+#char
      editor:SetSel(kp, cpq)
      editor:ReplaceSel(char)
      editor.CurrentPos=kp+#char
      rcfp.mskfn=rcfp.mskfn+#char-cpq+kp	
    elseif isoutwd(cp,bwdst,bwdfn) then 
--~ 		elseif isoutwd(cp-#char,bwdst,bwdfn) then 
      editor:remove(cp-#char, cp)  --caution remove on f==a
--~ 			print("tis so")
      recoin_setmask(rcfp)
      bwdst,bwdfn=rcfp.wdst,rcfp.wdfn+#char
      editor:insert(cp-#char,char)
      editor.CurrentPos=cp
      rcfp.mskfn=rcfp.mskfn+#char
    else
      rcfp.mskfn=rcfp.mskfn+#char
    end
  
  end
  
  rcfp['lastkp']=rcfp['lastcp']
  
--~ 	print("multi",bwdst,bwdfn)
  if bwdst>bwdfn then bwdst,bwdfn=bwdfn,bwdst end
  applymultitxt(rcfp,bwdst,bwdfn)	
--~ 	print("backfrom multi")
  return retv
end

function applymultitxt(rcfp,cwdst,cwdfn) 

  local bmap=rcfp.bmap	
  local cp=editor.CurrentPos
  local cwrd=editor:textrange(cwdst,cwdfn)

  local wrdif=#cwrd-#rcfp.wrd	
  
  local txi=editor:textrange(rcfp.mskst,tain(rcfp.mskfn,rcfp.mskst))

--~ 	print("\n:::::::\n"..rcfp.wrd..">"..cwrd..":")
--~ 	print(":::::::\n"..txi..":\n - - ")

  local mcp=cp-rcfp.mskst
  local mout={}
  local onshft,inshft,cpshft =0,0,0
  local m,stp,fp,lp = 1,0,0,-1 
  local un = true
  
  --mask works on unaltered clip,
  --which only needs shifted by wrdif
  --on cords after cp

  --mask is adjusted to fit recoined out
  --an accumulating shift is applied
  --to every stp and fp following
  editor:BeginUndoAction()
  while m<#bmap do
    if bmap[m]>=mcp then   --if point in map is after caretposition
      inshft=wrdif
    else
      cpshft=cpshft+wrdif
    end
    
    fp=bmap[m]+inshft
    stp=bmap[m+1]+inshft

    insert(mout,txi:sub(lp+1,tain(fp-1,0)))
    insert(mout,cwrd)
    lp=stp
    
    bmap[m]=bmap[m]+onshft+inshft
    onshft=onshft+wrdif
    bmap[m+1]=bmap[m+1]+onshft+inshft
    
    m=m+2
  end
  insert(mout,txi:sub(stp+1))
  
  mcp=cpshft+mcp+rcfp.mskst
  
  local moo=table.concat(mout)
  editor:SetSel(rcfp.mskst,rcfp.mskfn)
  editor:ReplaceSel(moo)
  editor:SetSel(mcp,mcp)
--~ 	print(table.concat(mout))
  editor:EndUndoAction()
  
  rcfp.mskfn=rcfp.mskst+#moo
  rcfp.wrd=cwrd rcfp.wdst=cwdst+cpshft rcfp.wdfn=cwdfn+cpshft
  
  txi=editor:textrange(rcfp.mskst,rcfp.mskfn)
--~ 	print(txi..":")

  domarkers(rcfp.mskst,rcfp.mskfn)
end


slide_Command("List|relist|Ctrl+j")

function relist() 
      
  local pane=get_pane()
  local kr,fnp = pane.Anchor,pane.CurrentPos	
  if kr==fnp then kr,fnp=caret_land(pane) end
  if kr>fnp then kr,fnp=fnp,kr end
  local v=pane:textrange(kr,fnp)
  v="List,"..v
  tracePrompt(v.."\n","\n>")
  MAReplace(v)
  tracePrompt()
  output:ScrollCaret()
  
  if pane==editor then pane:SetSel(kr,fnp) end
  
end

function parefind(str,ptt,ini,pn)
  
  --string.find(string,patt,init,plain)

  --~ a,b,c,d,e,f,h=parefind("pigglewigglelok","piggle((wiggle|lok))")
  --~ print(a,b,c,d,e,f,g,h)
  --~ >1	12	wiggle	nil	nil	nil	nil
    
  --mtchfn=string.find(pat,"[^%]?(.+[%|].-[^%])")	
  --quote these %(
  local s,u=string.find((string.gsub(ptt,"%%.","%%%%") or ""), "%([^%(%)]-[%|][^%(%)]-%)")
  if s then
    local bg=string.sub(ptt,1,s-1)
    local nd=string.sub(ptt,u+1)
    
    local brak=string.sub(ptt,s+1,u-1)
    local bunc=brak:unconcat("|")
    local a,b,c,d,e,f,oa,ob,oc,od,oe,of
    local bigs,first=0,1000000
    
    for _,x in ipairs(bunc) do

      a,b,c,d,e,f= find(str,(bg..x..nd),ini,pn)
      if a and (a<first or (a==first and #x>bigs)) then
        bigs=#x 
        first, oa,ob,oc,od,oe,of = a, a,b,c,d,e,f
      end
    end
    
    return oa,ob,oc,od,oe,of
  end
end

function MAReplace(c)
  
  local cc=string.lower(c)
  local _,_,isrep=find(c,"^([Ll]is?t?[:,])")
  local _,_,fxx=find(cc,"^lis?t?[:,](~~?)")
  local _,_,fscope=find(cc,"^lis?t?[:,]~~?([%d][%d]?)")
  local _,_,rpexpr=find(c,"^[Ll]is?t?[:,]~~?[%d%~][%d]?[%d]? (.+)")
  if not fxx then WReplace(c) return end 
  
  local farray={}
  local cfp=props['FilePath']
  Slide.repfiles=Slide.repfiles or {}
  
  if (not fscope) or fscope=="0" then 
    if Slide.repfiles[cfp] then 
      farray=Slide.repfiles[cfp]
    else
      table.insert(farray,cfp)
    end
    print("- File Scope:")
    print(table.concat(farray,"\n"))
    Slide.repfiles[cfp]=farray
    --print(isrep..rpexpr)
    --~ return false
  elseif find(c,"...?.?[:,]~%d+") then
    farray,farr={},fhistory(nil,tain(tonumber(fscope),1,50),true)
    if fscope then
      for i=#farr,1,-1 do
        insert(farray,farr[i])
      end
      print(table.concat(farray,"\n"))
      print("- These recent files scoped")
      Slide.repfiles[cfp]=farray
      if not rpexpr then return false end
    end
  else
    farray,farr={},getofiles(tain(tonumber(fscope),1,50))
    if fscope then
      for i=#farr,1,-1 do
        insert(farray,farr[i])
      end
      print(table.concat(farray,"\n"))
      print("- These upscreen files scoped")
      Slide.repfiles[cfp]=farray
      if not rpexpr then return false end
    end
  end
  
  if not rpexpr then return false end
  
  for i,v in ipairs(farray) do 
    scite.Open(v)
    WReplace(isrep..rpexpr,i~=#farray,true)
  end
  scite.Open(cfp)
  return false
end

function WReplace(c,nosumm,multifile)
  
  local find = string.find
  local cc=string.lower(c)

  if not multifile then
    uptrace("\n>"..props["FileDir"].."; "..c.."\n",0,1)
  end

  if (not multifile) and find(cc,"^lis?t?[:,]~[%d%~][%d]?[%d]?%s")
  then MAReplace(c) return end

  local _,_,line=poslinestfn(editor.CurrentPos,editor) 
  local _,_,q=find(c,"[:,](.*)")  q=q or ""
  print(props['FilePath']..":"..(line+1)..": ~~( "..q.." )~~")

  local tnam=props['FileNameExt']
  local hfs={lua=1,java=1,js=1,php=1,thtml=1,cxx=1,h=1,py=1,html=1}
  local hasfun=hfs[(props['FileExt'])]
      
  noteSelection()
  
  local stp,fnp=0,editor.Length
  if editor.CurrentPos~=editor.Anchor then
    fnp,stp=editor.CurrentPos,editor.Anchor
    if fnp<stp then fnp,stp=stp,fnp end
    if (fnp-stp<500) and not find(editor:textrange(stp,fnp),"[\r\n]")
    then stp=0 fnp=editor.Length end
  end

  editor:BeginUndoAction()

  local len=string.len
  
  local patrep,plainmtch=nil,true
  local inst=c
  _,_,c=find(c,"[:,](.*)")
  local nocase
  if sub(inst,1,1)=="l" then nocase=true end
  local wrdbnd=true
  local xfindx=false

  if sub(c,1,1)=="¬" then xfindx=true
    c=sub(c,2)
  end

  if sub(c,#c)=="¬" then plainmtch=nil
    c=sub(c,1,#c-1)
  end

  if sub(c,#c)=="¬" then patrep=true
    c=sub(c,1,#c-1)
  end

--~ 	if sub(c,-2)==" ~" then wrdbnd=nil
--~ 		c=sub(c,1,#c-2)
--~ 	else
  if 
     sub(c,#c)=="~" then wrdbnd=nil
    c=sub(c,1,#c-1)
  end 
  
  if sub(c,1,2)=="\\~" then c=sub(c,3) end --an escaped ~
  
  local fndpatw=c
  local reppatw,reppatv
  
  if find(c," ~") then
    fndpatw=match(c,"(.*) ~")
    reppatw=match(c," ~(.*)")
    reppatv=reppatw
    if not reppatw then reppatw="" end
  end
  
  if reppatv and wrdbnd then
    reppatv=wwordpatt(reppatv)
--~ 		print("reppatv#"..reppatv)
--~ 		reppatv="[^%w_]"..reppatv.."[^%w_]"
  end
  
  if fndpatw=="" then fndpatw=nil end 
  if not fndpatw then fndpatw="whaddyamean?" reppatw=nil end
  
  local lenchng=0 --init not used
  
  local se,fwd=false,false
  local nxfndpos
  local otabl={}
  local ortabl={}
  local fndpatcas=fndpatw
  if nocase then fndpatcas= string.lower(fndpatcas) end
  
  local haswdst,haswdfn
  if xfindx or find(fndpatcas,"^[$%w_]") then haswdst = true else haswdst=false end
  if xfindx or find(fndpatcas,"[%w_]$") then haswdfn = true else haswdst=false end
  local xf
  
  --local ooo=sub("~ooOO8O8O8O8O8888888",1,math.floor((len(fndpatw)+1)/2))..sub("8888888O8O8O8O8OOoo~",21-math.floor((len(fndpatw))/2))
  
  local reps,treps=0,0
  local colides=0
  local edst=editor:LineFromPosition(stp)
  local eden=editor:LineFromPosition(fnp)
  
  if not fndpatw then print("- lost innocence") return end

  local mtchst,mtchfn,clnstp,clnfnp,padlntxt,caslntxt,prtlntxt,lndif,prtdif,insr
  local lower=string.lower
  
  if xfindx then tfind=parefind else tfind=find end
  
--~ 	print("fndpatcas#"..fndpatcas) 

--~ 	if wrdbnd then print("wrdbnd") else print("no wrdbnd") end
--~ 	if haswdst then print("haswdst") else print("no haswdst") end
--~ 	if haswdfn then print("haswdfn") else print("no haswdfn") end
--~ 	if fndpatcas then print("fndpatcas#"..fndpatcas) else print("no fndpatcas") end
--~ 	if plainmtch then print("plainmtch") else print("no plainmtch") end
--~ 
--~ 	a,b,c,d=tfind("boot tweek",fndpatcas,0,plainmtch)
--~ 	print(a,b,c,d)
  
--~ 	if true then return end
  
  for cln=edst,eden do
    
    clnstp=editor:PositionFromLine(cln)
    clnfnp=editor.LineEndPosition[cln]
    
    if clnstp<stp and clnfnp>stp then clnstp=stp end
    if clnfnp>fnp then clnfnp=fnp end
    
    if clnstp==0 then padlntxt="\n"..editor:textrange(clnstp,clnfnp)
    else padlntxt=editor:textrange(clnstp-1,clnfnp) 
    end  --one extra char at start to assist word finds
    
    caslntxt, prtlntxt =padlntxt, padlntxt
    lndif, nxfndpos, prtdif=0, 2, 0 
    if nocase then caslntxt= lower(caslntxt) end
  
    if reppatv and not patrep then
      local v=0 
      for _ in string.gfind(padlntxt, reppatv) do
        v = v + 1	
      end
      if v>0 then
        colides=colides+v
        insert(ortabl, tnam..":"..(cln+1)..":"..sub(prtlntxt,2))
      end
    end
    
    repeat --process one line (padlntxt)
        
      mtchst,mtchfn=tfind(caslntxt,fndpatcas,nxfndpos,plainmtch)
      
--~ 			if mtchst then print(nxfndpos,sub(caslntxt,mtchst,mtchfn),fndpatcas) end
      
      if wrdbnd then
        if haswdst and mtchst and find(sub(caslntxt,mtchst-1,mtchst-1),"[%w$_]") 
        then mtchfn=nil end
        if haswdfn and mtchfn and find(sub(caslntxt,mtchfn+1,mtchfn+1),"[%w$_]") 
        then mtchfn=nil end
      end
      
      if mtchfn then nxfndpos=mtchfn+1 
      else
        if mtchst then nxfndpos=mtchst+1 end
      end
        
      if mtchfn then	
        if reppatw then	
          if patrep then 
            if xfindx then
              insr=gsub(sub(padlntxt,mtchst,mtchfn), 
                sub(padlntxt,mtchst,mtchfn), reppatw) 
              or "!!"..sub(padlntxt,mtchst,mtchfn).."!!"
            else
              insr=gsub(sub(padlntxt,mtchst,mtchfn), fndpatcas, reppatw) 
              or "!!"..sub(padlntxt,mtchst,mtchfn).."!!"
            end
            
            prtlntxt=sub(prtlntxt,1,mtchst-1+lndif+prtdif).."@"..insr
                .."@"..sub(prtlntxt,mtchfn+1+lndif+prtdif)
            prtdif=prtdif+2
          else 
            insr=reppatw 
          end
          
          padlntxt=sub(padlntxt,1,mtchst-1)..insr..sub(padlntxt,mtchfn+1) 
          caslntxt=sub(caslntxt,1,mtchst-1)..insr..sub(caslntxt,mtchfn+1) 
          
          lenchng=#insr-(mtchfn-mtchst+1)
          nxfndpos=nxfndpos+lenchng
          if clnstp+mtchst<stp then stp=stp+lenchng end
          if clnstp+mtchst<fnp then fnp=fnp+lenchng end
        end
        
        reps,treps=reps+1,treps+1
      end	
    until not mtchst --(no more finds in line)
    
    if hasfun and find(padlntxt,"function") then 
      --function: test1.lua:3:
      ffunc=tnam..":"..(cln+1)..":"..sub(prtlntxt,2)
      fll=cln
    end
    
    if reps>0 then
      if ffunc and not (fll==cln) then
        insert(otabl, ffunc)
        ffunc=nil
      end
      
      insert(otabl, tnam..":"..(cln+1)..":"..sub(prtlntxt,2))
      if reppatw then
        editor:SetSel(clnstp,clnfnp) 
        editor:ReplaceSel(sub(padlntxt,2))
      end
    end
    reps=0
    
  end --all lines done	

  editor:EndUndoAction()
  
  local tr="Text"
  if wrdbnd then tr="Word" end
  
  if treps==0 then
    if (not nosumm) then 
      print("-"..tr.." not found: '"..fndpatw.."'")
    end
  else
    print(table.concat(otabl,"\n"))
    
    if not reppatw then
      print("-"..tr.." '"..fndpatw.."' found "..treps.." times")
    else
      print("-"..tr.." '"..fndpatw.."' replaced with '"..reppatw.."' "..treps.." times")
      if colides>0 then
        print(table.concat(ortabl,"\n"))
        print("-Colliding with "..colides.." previous occurences of '"..reppatw.."'")
      end
    end
  end

  restoreSelection()	
  return treps
end

function wwordpatt(wrd)
  local ffwd,afwd
  
  if string.find(wrd,"^[$%w_]")
  then ffwd="%f[$%w_]" else ffwd="" end
  if string.find(wrd,"[%w_]$")
  then afwd="%f[^%w_]" else afwd="" end
    
  return ffwd..string.gsub(wrd, "([%(%)%.%%%+%-%*%?%[%^%$])", "%[%%%1%]")..afwd
end	



