fu! Update_all_linked_notes()
  let l:cur_note_data = Parse_note_from_cursor ()
  return
  Update_other_matching_notes (current_note_data)
endf

"Get info on starting note
  fu! Parse_note_from_cursor
    let l:note_data = {'position':getpos ('.')}
    extend (Parse_a_note (note_data['position'])
    return note_data
  endf

  fu! Parse_a_note (note_line)
    " get metadata
    let l:metadata = Get_metadata_from_note (note_line)
    " copy note and replace metadata
    let l:note = {'note':Get_note_and_fix (metadata)
    return extend (metadata, note)
  endf

  " get metadata
    fu! Get_metadata_from_note (note_line)
      let l:meta_data = Get_tags_and_hash (a:note_line)
      let l:meta_text = Make_meta_text (tags, hash)
      return extend (meta_data, meta_text)
    endf

      fu! Get_tags_and_hash (meta_line)
        "get line number of meta_line
        let l:meta_line = Get_line_num_with_meta_data_from (a:meta_line)
          if (meta_line == 0) | return {} | endif
        "get tags
        let l:tags = Get_tags (meta_line)
        "get hash
        let l:hash = Get_or_make_hash (meta_line)
        return {'meta_line':meta_line, 'tags':tags, 'hash':hash}
      endf

        fu! Get_or_make_hash (meta_line)
          let l:line_text = getline (a:meta_line)
          let l:hash = matchstr (line_text, 'hash\s*=\s*\zs\w\+')
          if (hash == "") | let hash = Make_hash (line_with_meta) | endif
          return hash
        endf

        fu! Get_tags (meta_line)
          let l:line_text = getline (a:meta_line)
          let l:tags = matchstr (line_text, 'tags\s*=\s*\zs[^>]\+\ze\>')
          let l:all_tags = split (tags, '\W\+')
          return all_tags
        endf


      fu! Make_meta_text (tags, hash)
        let l:meta_text = "<tags = "
        for a_tag in a:tags
          meta_text = meta_text. a_tag. ", "
        endfo
        meta_text = meta_text[:-2]. "><hash = ". a:hash. ">"
        return meta_text
      endf

  " get repaired note
    fu! Get_note_and_fix (metadata)
      let l:note = Copy_note_down (a:metadata['meta_line'])
      note[0] = a:metadata['meta_text']
      return note
    endf

      fu! Copy_note_down (start_line)
        let l:copy_till = Get_end_line_from_meta (a:meta_line)
        return getline (a:start_line, copy_till)
      endf

"Update other matching notes 
  fu! Update_other_matching_notes (note)
    "note = tags, hash, a note copy
    for a_tag in note.tags
      let l:position_change += Insert_note_at_tag (note, a_tag)
      let note.position += position_change
    endfo
    call setpos ('.', note.position)
  endf

  " insert note at a tag
    fu! Insert_note_at_tag (note, a_tag)
    endf"""""""""""""""""""""""""""

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
    let l:yanked_text = a:yanked_text
    "get starting note position from its tag position
    let l:starting_note_pos = Get_first_hashed_line (a:tag_matchline+1, a:hash)
    "check that the hash was found
    if starting_note_pos == 0
      let l:line_to_stop_at = a:tag_matchline 
      let starting_note_pos = a:tag_matchline +1
    else "if hash was found:
      "get end of note position
      let l:line_to_stop_at = Get_end_line_from_meta (starting_note_pos)
      "delete it
      execute "silent ". starting_note_pos. ",". line_to_stop_at. "delete_"
    endif
    "append new note
    call append(starting_note_pos-1, yanked_text)
    "return the amount that this changes our cursor pos
    let l:changed_amount =  len (a:yanked_text) -((line_to_stop_at +1) -starting_note_pos)
    return Get_cursor_adjust (starting_note_pos, a:cursor, changed_amount)
  endf

  fu! Get_cursor_adjust (changed_line, cursor_line, changed)
    return a:changed_line < a:cursor_line ? a:changed : 0
  endf

  fu! Make_hash (current_line)
    let l:line_text = getline (a:current_line +1, a:current_line +3)
    let l:new_hash = ""
    let l:nums = 0

    for line in line_text
      for character in split (line, '\zs')
        let nums += char2nr (character) * 123
      endfo
    endfo
    let new_hash = string (nums)
    return new_hash
  endf

  fu! Yank_current_note (meta_line)
    let l:copy_till = Get_end_line_from_meta (a:meta_line)
    return getline (a:meta_line, copy_till)
  endf

  fu! Get_first_hashed_line (starting_point, hash)
    let l:match_line = Get_line_of_match_unless_outdent (a:starting_point, a:hash, 0)
    let l:outdent_line = Get_next_outdent (a:starting_point, 0)
    return (match_line < outdent_line) ? match_line : 0
  endf

  fu! Get_line_of_match_unless_outdent (starting_line, regex, reverse)
    let l:botline = line ('$')
    let l:linetext = getline (a:starting_line)
    let l:end_line = a:starting_line
    let l:next_outdent = Get_next_outdent (a:starting_line, a:reverse) +1

    while 1 
      "stop at match, bottom line, outdent, or line 0
      if match (linetext, a:regex) >= 0 | break | endif
      if end_line == botline && !a:reverse | break | endif
      if end_line == next_outdent && !a:reverse | break | endif
      if end_line < 1 | break | endif
      "incriment end_line and get text
      let end_line += a:reverse ? -1 : 1
      let linetext = getline (end_line)
    endw
    return end_line
  endf

  fu! Get_next_outdent (starting_line, reverse) 
    let l:botline = line ('$')
    let l:end_line = a:starting_line
    let l:starting_indent = IndentLevel (a:starting_line)
    let l:new_indent = starting_indent +1
    let l:end_line = a:starting_line
    "special case
    if a:starting_line == botline
      return 0
    endif

    while 1
      "stop at outdent, bottom line, or line 0
      if (new_indent < starting_indent) && (new_indent != 0) | break | endif
      if (end_line == botline) | break | endif
      if (end_line < 1) | break | endif
      "incriment end_line and indent level 
      let end_line += a:reverse ? -1 : 1
      let new_indent = IndentLevel (end_line)
    endw
    return end_line
  endf

  fu! Get_tag_line (tag_name)
    return Get_line_of_match_unless_outdent (1, a:tag_name, 0)
  endf

  fu! Get_end_line_from_meta (starting_line)
    "get the metaline, or the newilne
    let l:next_tag_line =  Get_line_of_match_unless_outdent (a:starting_line + 1, '<tags\|^\s*$', 0) - 1
    "special case
    if next_tag_line == a:starting_line | return a:starting_line +1 | endif
    return next_tag_line
  endf

  fu! Get_line_to_copy_till (starting_line)
  endf

  fu! Get_line_num_with_meta_data_from (starting_point)
    return Get_line_of_match_unless_outdent (a:starting_point, "<tags", 1)
  endf

  fu! IndentLevel (line_num)
    return indent (a:line_num) / &shiftwidth
  endf

nnoremap gy :call Update_all_linked_notes()<CR>
