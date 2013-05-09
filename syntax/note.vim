if exists("b:current_syntax")
  finish
endif

echon "Our syntax highlighting code will go here."
syntax match notesTag "\v^.*[^:]:$" 
syntax match metaData "\v^\s+\<tags.*$" conceal cchar=-
highlight link notesTag Function
highlight link metaData Comment
hi conceal ctermfg=DarkBlue ctermbg=none guifg=DarkBlue guibg=none

let b:current_syntax = "note"
