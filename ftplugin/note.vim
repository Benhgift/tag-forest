fu! Update_all_linked_notes()
  let l:cur_note_data = Parse_note_from_cursor ()
  if cur_note_data == {} | return | endif
  call Remove_notes_marked_for_death (cur_note_data)
  call Update_other_matching_notes (cur_note_data)
endf

"Get info on starting note
  fu! Parse_note_from_cursor ()
    let l:pos_data = Get_pos_data ()
    execute "silent normal zn"
    let l:note_data = Parse_a_note (pos_data['position'][1])
    if note_data == {} | return {} | endif
    call extend (note_data, pos_data)
    return note_data
  endf

  fu! Get_pos_data ()
    let l:pos_data = {'position':getpos ('.')}
    let l:topline_fill = pos_data.position[1] - winsaveview ().topline
    let l:topline_fill = Check_visable_lines (pos_data.position[1] - topline_fill, pos_data.position[1] -1)
    call extend (pos_data, {'topline_fill':topline_fill})
    return pos_data
  endf

    fu! Check_visable_lines (line_start, line_end)
      execute "silent normal zN"
      let l:affected_lines = 0
      let l:first_fold = 1 "topline has to take into account that fold starts are visable
      for counter in range ((a:line_end +1) - a:line_start) "+1 because inclusive
        if foldclosed (a:line_start + counter) < 0
          let affected_lines += 1
          let first_fold = 1
        elseif first_fold
          let affected_lines += 1
          let first_fold = 0
        endif
      endfo
      execute "silent normal zn"
      return affected_lines
    endf

  fu! Parse_a_note (note_line)
    " get metadata
    let l:metadata = Get_metadata_from_note (a:note_line)
    if metadata == {} | return {} | endif
    " copy note and replace metadata
    let l:note = {'note':Get_note_and_fix (metadata)}
    return extend (metadata, note)
  endf

  " get metadata
    fu! Get_metadata_from_note (note_line)
      let l:meta_data = Get_tags_and_hash (a:note_line)
      if meta_data == {} | return {} | endif
      let l:meta_text = Make_meta_text (meta_data.tags, meta_data.hash)
      return extend (meta_data, {'meta_text':meta_text})
    endf

      fu! Get_tags_and_hash (note_line)
        "get line number of meta_line
        let l:meta_line = Get_line_num_with_meta_from (a:note_line)
        if (meta_line == 0) | return {} | endif
        "get tags
        let l:tags = Get_tags (meta_line)
        "get hash
        let l:hash = Get_or_make_hash (meta_line)
        return {'meta_line':meta_line, 'tags':tags, 'hash':hash}
      endf

        fu! Get_line_num_with_meta_from (note_line)
          let l:min_search_line = a:note_line - 100 < 1 ? 1 : a:note_line - 100
          let l:next_tag = search ('^\s*<tags = ', 'bcn', min_search_line)
          let l:next_linebreak = search ('^\s*$', 'bcn', min_search_line)
          return next_tag > next_linebreak ? next_tag : 0
        endf

        fu! Get_or_make_hash (meta_line)
          let l:line_text = getline (a:meta_line)
          let l:hash = matchstr (line_text, 'hash\s*=\s*\zs\w\+')
          if (hash == "") 
            let hash = Make_hash (a:meta_line) 
            call setline (a:meta_line, getline (a:meta_line). "<hash = ". hash. ">")
          endif
          return hash
        endf

          fu! Make_hash (current_line)
            let l:line_text = getline (a:current_line +1, a:current_line +4)
            let l:new_hash = ""
            let l:nums = 0
            for line in line_text
              for character in split (line, '\zs')
                let nums += char2nr (character) * 991
              endfo
            endfo
            let new_hash = string (nums)
            return new_hash
          endf

        fu! Get_tags (meta_line)
          let l:line_text = getline (a:meta_line)
          let l:tags = matchstr (line_text, 'tags\s*=\s*\zs[^>]\+\ze\>')
          let l:all_tags = split (tags, ',')
          let all_tags = Remove_trailing_space (all_tags)
          return all_tags
        endf


      fu! Make_meta_text (tags, hash)
        let l:meta_text = "<tags = "
        for a_tag in a:tags
          if a_tag[0] != '-'
            let meta_text = meta_text. a_tag. ", "
          endif
        endfo
        let meta_text = meta_text[:-3]. "><hash = ". a:hash. ">"
        return meta_text
      endf

  " get repaired note
    fu! Get_note_and_fix (metadata)
      let l:note = Copy_note_down (a:metadata.meta_line)
      let note = Remove_correct_indent (note)
      let note[0] = a:metadata.meta_text
      return note
    endf

      fu! Copy_note_down (start_line)
        let l:copy_till = Search_till (a:start_line +1, '<tags = \|^\s*$', 1)
        return  getline (a:start_line, copy_till)
      endf

      fu! Remove_correct_indent (old_note)
        let l:note = Convert_tabs_to_spaces (a:old_note)
        let l:starting_indent_pos = match (note[1], '\S')
        let l:spaces = '^'. repeat ('\s', starting_indent_pos)
        let l:new_note_line = ""
        let l:new_note = [note[0]]
        for counter in range (len (note) -1)
          let new_note_line = substitute (note[counter+1], spaces, "", "") 
          call add (new_note, new_note_line)
        endfo
        return new_note
      endf

        fu! Convert_tabs_to_spaces (old_note)
          let l:new_note = []
          let l:new_line = ""
          for line in a:old_note
            let new_line = substitute (line, '\t', repeat (" ", &shiftwidth), "g")
            call add (new_note, new_line)
          endfo
          return new_note
        endf

      fu! Remove_trailing_space (note)
        let l:new_note = []
        for line in a:note 
          call add (new_note, substitute(line, '^\s*\(.\{-}\)\s*$', '\1', ''))
        endfo
        return new_note
      endf

"Remove marked notes
  fu! Remove_notes_marked_for_death (note_db)
    execute "silent normal ". "zn"
    let l:position_change = 0
    let l:new_tags = []
    for a_tag in a:note_db.tags
      if a_tag[0] == '-'
        let position_change = Remove_note_from_tag (a_tag[1:], a:note_db)
        let a:note_db.position[1] += position_change
      else
        call add (new_tags, a_tag)
      endif
    endfo
    let a:note_db.tags = new_tags
    call Setpos_and_view ('.', a:note_db.position, a:note_db.topline_fill)
  endf

    fu! Setpos_and_view (cursor, position, topline_fill)
      execute "silent normal ". "zN"
      call setpos (a:cursor, a:position)
      let l:cur_pos = getpos (a:cursor)[1]
      execute "silent normal ". "zt"
      execute "silent normal ". a:topline_fill. "\<c-Y>"
    endf

    fu! Remove_note_from_tag (a_tag, note_db)
      let l:removal_data = Prepare_note_spot (a:note_db.hash, a:a_tag)
      if a:note_db.position[1] > removal_data.target_line
        return 0 - removal_data.amount_removed
      endif
      return 0
    endf

"Update other matching notes 
  fu! Update_other_matching_notes (note_db)
    execute "silent normal ". "zn"
    "note = tags, hash, a note copy
    let l:position_change = 0
    for a_tag in a:note_db.tags
      let position_change = Insert_note_at_tag (a:note_db, a_tag)
      let a:note_db.position[1] += position_change
    endfo
    call Setpos_and_view ('.', a:note_db.position, a:note_db.topline_fill)
  endf

  "insert note at a tag
    fu! Insert_note_at_tag (note_db, a_tag)
      let l:note_pos = Prepare_note_spot (a:note_db.hash, a:a_tag)
      if note_pos == {} | echo a:a_tag. " not found" | return 0 | endif
      call Insert_note_with_correct_indentation (note_pos, a:note_db)
      let l:movement = Check_if_movement_required (a:note_db, note_pos)
      return movement
    endf
      
      fu! Insert_note_with_correct_indentation (note_pos, note_db)
        let l:indentation = IndentLevel (a:note_pos.tag_line) +1 
        let l:tab_string = ""
        let l:indented_note = []
        for indent in range (indentation)
          let tab_string = tab_string. repeat (" ", &shiftwidth)
        endfo
        for line in a:note_db.note
          let indented_note += [tab_string. line]
        endfo
        call append (a:note_pos.target_line, indented_note)
      endf

      fu! Check_if_movement_required (note_db, note_pos)
        if a:note_db.position[1] > a:note_pos.target_line
          return len (a:note_db.note) - a:note_pos.amount_removed 
        else
          return 0
        endif
      endf
      
      fu! Prepare_note_spot (hash, a_tag)
        "find line with tag
        let l:tag_matchline = Get_tag_line ('^\s*'. a:a_tag. ':')
        if !tag_matchline | return {} | endif
        let l:section_end = Get_section_end (tag_matchline)
        let l:note = Remove_note_give_data (tag_matchline, section_end, a:hash)
        return {'amount_removed':note.amount_removed, 'target_line':note.target_line, 'tag_line':tag_matchline}
      endf

        fu! Get_tag_line (regex)
          return search (a:regex, 'wcn')
        endf
      
        fu! Remove_note_give_data (tag_matchline, section_end, hash)
          let l:current_line = a:tag_matchline
          let l:amount_removed = 0
          while current_line != a:section_end
            let l:line_text = getline (current_line)
            if match (line_text, a:hash) >= 0
              let amount_removed = Remove_note (current_line)
              let current_line -=1 "we're on the wrong line cuz we removed it
              break
            endif
            let current_line += 1
          endw
          return {'amount_removed':amount_removed, 'target_line':current_line}
        endf

          fu! Remove_note (line)
            "scan for next <tags or line break
            let l:current_line = Search_till (a:line +1, '<tags = \|^\s*$', 1)
            let l:amount_removed = (current_line +1) - a:line "inclusive
            execute "silent ". a:line. ",". current_line. "delete_"
            return amount_removed
          endf

            fu! Search_till (line, regex, increment)
              "scan for next <tags or line break
              let l:bot_line = line ('$')
              let l:current_line = a:line
              while current_line < bot_line && current_line > 0
                if match (getline (current_line), a:regex) >= 0
                  let current_line -=1
                  break
                endif
                let current_line += a:increment
              endw
              return current_line
            endf

        fu! Get_section_end (start_line) "based on indent
          let line_db = {'bot_line':line ('$'), 'current_line':a:start_line +1}
          let line_db.section_indent = IndentLevel (a:start_line)
          let line_db.last_textline = a:start_line
          while 1
            if Check_section_termination (line_db)
              break
            endif
            let line_db.current_line +=1  
          endw
          return line_db.last_textline
        endf

          fu! Check_section_termination (line_db)
            let l:current_indent = IndentLevel (a:line_db.current_line)
            if current_indent <= a:line_db.section_indent && current_indent > 0 | return 1 |endif
            if a:line_db.section_indent == 0 && current_indent == 0
              if match (getline (a:line_db.current_line), '^\S') == 0 | return 1| endif
            endif
            if current_indent > 0 | let a:line_db.last_textline = a:line_db.current_line | endif
            if a:line_db.current_line == a:line_db.bot_line | return 1 | endif
            return 0
          endf

          fu! IndentLevel (line_num)
            if match (getline (a:line_num), '^\s\+$') >=0
              return 0
            endif
            return indent (a:line_num) / &shiftwidth
          endf

nmap gy :call Update_all_linked_notes()<CR>
"nmap <leader>i :set ft=note<cr>
set conceallevel=1
