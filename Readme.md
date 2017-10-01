#sciteluascripts

I use scite text editor with these scripts as my main IDE. I wrote most of them years ago so the code organisation is dreadful, there are many cross dependencies between the files, however several of these scripts contain really powerful and usefull tools.

 ` recoin.lua ` - does a quick-syntax words-in-file search from the command pane, enabling listing, and jumping through hits. Single and multifile word or term search and replace. It makes extensive refactoring quite safe and easy.
 
 ` recoin.lua ` - also contains a live-edit-mode multiline word replace/repeat tool. This is super useful for coding blocks of equations, patterned arrays or 'recoining' vars in nearby lines.
  
 ` watcher.lua ` - effectiently records and conviently lists activity of all opened and previously opened files, quickly closes or opens watched files from the command pane. This completely handles project file management needs for me. Also runs a recent file switcher popup on hotkey.
  
 ` fcrypt.lua ` - seemless text file encryption employing Rob Kendricks AES stream cypher. Fast, with ascii friendly encoding. The encryption scheme encodes each line by linelength and key for efficient diff'ing, so it is not totally secure for large files but it is very nontrivially encrypted and good for my config and private note files. It could be carefully simplified to perform block file AES encryption.
  
 ` initglob.lua ` - a big unruly collection of helper functions which includes `slide_command` which registers functions to keys and key combos. More convienient and capable than assignment through scites property files.
 
### Help

Let me know if you would like any of these functions tidied up. 

Someday I will be redoing these to work with up to date linux scite. At the moment they run on an old windows scite version with source code that has hacks including changing the output panels behaviour into a simple terminal.

Andrewinput@protonmail.com