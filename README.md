***
## Tag-forrest
Tag your notes when they apply to different subsections, and update those tagged notes when you make changes. (Try the example file)

Install: 
  - clone everything to a folder in .vim/bundle
  - put this in your ~/.vimrc: `set conceallevel=1`

Use: Press `gy` in normal mode to update all notes bound to the one with the cursor on it. Please see the sample notes file for formatting. To add a new note simply put `<tags = tag1, tag2, tagN>` above your new note and press `gy` in normal mode.  

Tag coloumns are hidden by default using vim's conceal feature. 

![screenshot](http://i.imgur.com/68fEVD1.png)

## To Do:
 * Make notes auto remove from a section if you delete a tag
 * Make the process automatic without pressing gy

## Long Term Goal:
  Make a spaced repitition program that links in with this to provide targeted review. (only gives your notes on astro physics if it's given you the parent topic's notes first for instance)
