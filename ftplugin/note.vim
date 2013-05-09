fu! Update_all_identical_notes()
  let l:p = getpos ('.')
  let l:current_line = line('.')
  let l:entire_text = getline (0, line('$'))

  "parse hash and tag info for master note
  let l:meta = Parse_meta (current_line)
  if (meta == {}) | return | endif
  "Yank current note
  let l:yanked_text = Yank_current_note (meta.meta_line)
  "for each tag that note had...
  for x in range (len (meta.tags))
    "find the line with the tag
    let l:tag_matchline = Get_tag_line (meta.tags[x]. ':')
    "find note below the tag by its hash and replace it all
    let l:tmp = Find_note_and_replace (tag_matchline, meta.hash, yanked_text, current_line)
    "update the cursor variable since lines were removed/added
    let p[1] += tmp 
  endfo
  "update cursor
  call setpos ('.', p)
endf

fu! Find_note_and_replace (tag_matchline, hash, yanked_text, cursor)
  "get starting note position from its tag position
  let l:starting_note_pos = Get_first_hashed_line (a:tag_matchline, a:hash)
  "get end of note position
  let l:line_to_stop_at = Get_end_line_from_meta (starting_note_pos)
  "delete it
  execute "silent ". starting_note_pos. ",". line_to_stop_at. "delete_"
  "append new note
  call append(starting_note_pos-1, a:yanked_text)
  "return the amount that this changes our cursor pos
  let l:changed_amount =  len (a:yanked_text) -((line_to_stop_at +1) -starting_note_pos)
  return Get_cursor_adjust (starting_note_pos, a:cursor, changed_amount)
endf

fu! Get_cursor_adjust (changed_line, cursor_line, changed)
  return a:changed_line < a:cursor_line ? a:changed : 0
endf

fu! Parse_meta (current_line)
  "parse hash and tag info
  let l:line_with_meta = Get_line_num_with_meta_data_from (a:current_line)
  if (line_with_meta == 0) | return {} | endif
  let l:line_text = getline (line_with_meta)
  let l:hash = matchstr (line_text, 'hash\s*=\s*\zs\w\+')
  let l:tags = matchstr (line_text, 'tags\s*=\s*\zs[^>]\+\ze\>')
  let l:all_tags = split (tags, '\W\+')
  return {'line_text':line_text, 'hash':hash, 'tags':all_tags, 'meta_line':line_with_meta}
endf

fu! Yank_current_note (meta_line)
  let l:copy_till = Get_end_line_from_meta (a:meta_line)
  return getline (a:meta_line, copy_till)
endf

fu! Get_first_hashed_line (starting_point, hash)
  return Get_line_of_match_unless_outdent (a:starting_point, a:hash, 0)
endf

fu! Get_line_of_match_unless_outdent (starting_line, regex, up) "but not if it indents!
  let l:botline = line ('$')
  let l:linetext = getline (a:starting_line)
  let l:end_line = a:starting_line
  let l:starting_indent = IndentLevel (a:starting_line)
  let l:new_indent = starting_indent
  while (match (linetext, a:regex) < 0)
    if (end_line == botline)
      break
    endif
    if (new_indent < starting_indent) && (new_indent > 0)
      break
    endif
    let end_line += 1 
    if (a:up)
      if (new_indent == 0) | return 0 | endif
      let end_line -= 2
    endif
    let new_indent = IndentLevel (end_line)
    let linetext = getline (end_line)
  endw
  return end_line
endf

fu! Get_tag_line (tag_name)
  return Get_line_of_match_unless_outdent (0, a:tag_name, 0)
endf

fu! Get_end_line_from_meta (starting_line)
  return Get_line_of_match_unless_outdent (a:starting_line + 1, "<tags", 0) - 1
endf

fu! Get_line_to_copy_till (starting_line)
endf

fu! Get_line_num_with_meta_data_from (starting_point)
  return Get_line_of_match_unless_outdent (a:starting_point, "<tags", 1)
endf

fu! IndentLevel (line_num)
  return indent (a:line_num) / &shiftwidth
endf

fu! Play (fn)
  for x in a:fn
    let Y = function(x)
    echo Y(["poo"])
  endfor
endf

fu! Moo (text)
  for x in a:text
    echo x
  return "hiii"
endf

nnoremap gy :call Update_all_identical_notes()<CR>
