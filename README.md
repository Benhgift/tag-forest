***
## tag forest 0.9.2
Tag your notes when they apply to different categories, and update all those tagged notes at once when you make changes. (Try the example file)

## Install: 
[With Pathogen](https://github.com/tpope/vim-pathogen):

  - `git clone https://github.com/Corm/tag-forest.git ~/.vim/bundle/`

[With Vundle](https://github.com/gmarik/vundle):

  - Put `Bundle 'Corm/tag-forest'` into your ~/.vimrc 
  - `:BundleInstall`

[Manually](http://i.imgur.com/oh3QVmh.gif?1):

  - Download and unzip all files into the ~/.vim directory (Windows: ~/vimfiles)

## Use: 
Press `gy` in normal mode to update all notes bound to the one with the cursor on it. Please see the sample notes file for formatting. To add a new note simply put `<tags = tag1, tag2, tagN>` above your new note and press `gy` in normal mode.  

Tag coloumns are hidden by default using vim's conceal feature. 
Please use correct syntax formatting and keep a linebreak between all notes and section tags as shown in the example file. Section tags are formatted like `tag:`

To delete tags put a `-` in front of them like `<tags = bio, -math, science>` and press `gy`.

![screenshot](http://i.imgur.com/68fEVD1.png)

## To Do:
 * Make the process automatic without pressing gy
 * Optimize/impliment in python
 * Drop down menu for adding tags
 * Fix "tag namespace" so that you can have conflicting tag names with different parent tags

## Long Term Goal:
  Make a spaced repitition program that links in with this to provide targeted review. (only gives your notes on astro physics if it's given you the parent topic's notes first for instance)

## In this version:
 * `gy` doesn't mess with folds!
 * Added `-` deletion feature
 * Rewrote entire program using indentation to emulate classes (no classes in vimscript...)
 * Fixed a million bugs
 * Indentation is smart now
 * Made updating notes much less jarring. Keeps scroll/view position
