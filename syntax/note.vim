if exists("b:current_syntax")
  finish
endif

syntax match notesTag "\v^.*[^:]:$" 
syntax match metaData "\v^\s+\<tags.*$" conceal cchar=-
highlight link notesTag Function
highlight link metaData Comment
hi conceal ctermfg=DarkBlue ctermbg=black guifg=DarkBlue guibg=black

let b:current_syntax = "note"
