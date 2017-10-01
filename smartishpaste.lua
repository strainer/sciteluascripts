		
	--[[
			--trace(' K ')
			if alt or ctrl then return end
	 	  if not acrunning then return end
	 		if not get_pane():AutoCActive() then 
				scite_OnKey(handleKey,'remove')
				scite_OnChar(handlepress,'remove')
				return 
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
]]
--[=[
lua save tracking

hook lua onsave
write table to savelog
option write opens to log also
option delay hooks avoid saving 1st session opens
option, do distillations on filelog
to list common directories in most/recently used with last save/acess time


also with save tracking
file can be examined for extradoc functions
functions permitting project tracking
and open and save can be hooked for encryption



more wishlist...
lua file / undo diff with change marks in margin

also would be great if find out how lua can trigger a newline in output 
]=]

--end
