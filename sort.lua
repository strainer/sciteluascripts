
-- Sort a selected text

function lines(str, botlin, toplin)
  local t = {}
  for i = botlin,toplin do
    table.insert(t,(editor:GetLine(i)))
  end
  return t
end

function real_sort_text(f)

  local botlin = editor:LineFromPosition(editor.Anchor)
	local toplin = editor:LineFromPosition(editor.CurrentPos)
	
	if botlin>toplin then
		local t=toplin toplin=botlin botlin=t end
		
	if botlin==toplin then
		botlin=0 toplin=editor.LineCount 
		editor.Anchor=editor:PositionFromLine(botlin) 
		editor.CurrentPos=editor:PositionFromLine(toplin) end
		
  local buf = lines(sel, botlin, toplin)
  --table.foreach(buf, print) --used for debugging
  table.sort(buf,f)
  local out = table.concat(buf, "")
  editor:ReplaceSel(out)
	editor.Anchor=editor:PositionFromLine(botlin) 
	editor.CurrentPos=editor:PositionFromLine(toplin+1)
end

function sort_text()
  real_sort_text(function(a, b) return a < b end)
end

function sort_text_reverse()
  real_sort_text(function(a, b) return a > b end)
end

