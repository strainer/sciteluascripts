function exec_buffer()
  local buf = editor:GetText()
  if buf == '' then buf = editor:GetText() end
  dostring(buf)
end

scite_Command('Execute buffer|exec_buffer|Ctrl+Shift+L')
