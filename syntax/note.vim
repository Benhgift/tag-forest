if exists("b:current_syntax")
  finish
endif

<<<<<<< HEAD
=======
echon "Our syntax highlighting code will go here."
>>>>>>> ac96d71a464ab083c464ba9430538731103ef0e9
syntax match notesTag "\v^.*[^:]:$" 
syntax match metaData "\v^\s+\<tags.*$" conceal cchar=-
highlight link notesTag Function
highlight link metaData Comment
<<<<<<< HEAD
hi conceal ctermfg=DarkBlue ctermbg=black guifg=DarkBlue guibg=black
=======
hi conceal ctermfg=DarkBlue ctermbg=none guifg=DarkBlue guibg=none
>>>>>>> ac96d71a464ab083c464ba9430538731103ef0e9

let b:current_syntax = "note"
