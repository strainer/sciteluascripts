-- all/string.lua (all.string)
-- A Lua Library (ALL) - string utility functions.
-- This is compatible with Lua 5.1.
-- Licensed under the same terms as Lua itself.--DavidManura
-- modified as necessary by me (mario)

-- begin of my addition

-- returns last word (consists of letters and underscores only) of line string s
function LastWord(s)
  return s:find("(%w+)$")
end

-- returns last character of line string s
function LastChar(s)
  return s:find("(.)$")
end

-- get how many spaces needed to indent line string s
function IndentSize(s)
  return s:find("^(%s*)")
end

-- returns the character at position p as a string
function EditorCharAt(p)
  return string.char(editor.CharAt[p])
end

-- end of my addition

-- remove trailing and leading whitespace from string.
-- http://en.wikipedia.org/wiki/Trim_(8programming)
function trim(s)
  -- from PiL2 20.4
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- remove leading whitespace from string.
-- http://en.wikipedia.org/wiki/Trim_(8programming)
function ltrim(s)
  return (s:gsub("^%s*", ""))
end

-- remove trailing whitespace from string.
-- http://en.wikipedia.org/wiki/Trim_(8programming)
function rtrim(s)
  local n = #s
  while n > 0 and s:find("^%s", n) do n = n - 1 end
  return s:sub(1, n)
end
-- The following more obvious implementation is generally not
-- as efficient, particularly for long strings since Lua pattern matching
-- starts at the left (though in special cases it is more efficient).
-- Related discussion on p.197 of book "Beginning Lua Programming".
--[[
function rtrim(s) return (s:gsub("%s*$", "")) end
]]

-- substitute variables into string.
-- Example: subst("a=$(a),b=$(b)", {a=1, b=2}) --> "a=1,b=2".
function subst(s, t)
  -- note: handle {a=false} substitution
  s = s:gsub("%$%(([%w_]+)%)", function(name)
    local val = t[name]
    return val ~= nil and tostring(val)
  end)
  return s
end

-- explode(seperator, string)
function explode(d,p)
  local t, ll
  t={}
  ll=0
  if(#p == 1) then return {p} end
    while true do
      l=string.find(p,d,ll,true) -- find the next d in the string
      if l~=nil then -- if "not not" found then..
        table.insert(t, string.sub(p,ll,l-1)) -- Save it in our array.
        ll=l+1 -- save just after where we found it for searching next time.
      else
        table.insert(t, string.sub(p,ll)) -- Save what's left in our array.
        break -- Break at end, as it should be, according to the lua manual.
      end
    end
  return t
end
