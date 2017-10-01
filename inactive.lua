--scite_Command("testoutp|testoutp|Ctrl+Alt+o")
--scite_Command("testr|testr|Ctrl+Alt+b")

--~ OnUpdateUI()

--~ function dwelling
--~   dwellcount=dwellcount+1
--~ 	if dwellcount%15==0 then print("d") end
--~ end

local function eolchars(pane)  --not done yet
	if not pane then pane=editor end
	local chars="\n"
	local emo=pane.EOLMode
	if emo==0 then return "crlf" end
	if emo==1 then return "cr"   end
	if emo==2 then return "lf"   end
	if emo==3 then return ""     end
end

function SetLanguage(lng_name) --By Vlad in groups ...not working for...
	local i = 0
	for _,name,_ in string.gfind(props["menu.language"],
			"([^|]*)|([^|]*)|([^|]*)|") do
		if name == lng_name then
			scite.MenuCommand(IDM_LANGUAGE + i)
			return
		end
		i = i + 1
	end
end 

function testr()
	print()
	trace("weewee")
	scite.MenuCommand(2329)
end

-----------

--~ scite_Command("reselect|ressel|Alt+R")
function ressel()
  local p=get_pane()
	if sanker[p]==scurren[p] then return end
  p:GotoPos(scurren[p])
  p:SetSel(sanker[p],scurren[p])
end

--------------

function readFavsFile()
  local p1 = props["SciteDefaultHome"]
  if props["PLAT_GTK"] ~= '' then
    file1 = p1.."/.SciTE.favs"
  else
    file1 = p1.."\\SciTE.favs"
  end
  --_ALERT(file1)
  local f1 = io.open(file1)
  local favs = {}
  local i = 1
  if f1 then
    for line in f1:lines() do
      local l=line
      for c in string.gfind(l, "%$%(([^\)]*)%)") do
        l=string.gsub(l,"%$%(([^\)]*)%)",props[c])
      end
      --_ALERT(l)
      fh=io.open(l)
      if fh then
        favs[i] = l
        i = i + 1
        io.close(fh)
      end
    end
    io.close(f1)
  end
  return favs
end

-- Select Favourite
function SelectFavourite()
  local favs = readFavsFile()
  if table.getn(favs) == 0 then return 0 end
  local s = ''
  local sep = ';'
  local n = table.getn(favs)
  for i = 1,n-1 do
    s = s..favs[i]..sep
  end
  s = s..favs[n]
  editor.AutoCSeparator = string.byte(sep)
  editor:UserListShow(10,s)
  editor.AutoCSeparator = string.byte(' ')
  return 0
end

-- Open selected file in SciTE
function OnUserListSelection(listID, s)
  if listID == 10 or listID ==11 then
    scite.Open(s)
  end
  return 0
end

----------------
