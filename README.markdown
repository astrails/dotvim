## Dotvim

### This is a complete Vim configuration that I'm using everywhere.

The config is using [Vundle](http://github.com/gmarik/vundle) for easy upgrading.

*Some* help tips are provided for *some* of the plugins. please check out the plugin's docs for more info.

<a name=top>
#### Contents

* [Installation](#installation)
* [General Configuration](#general)
* [Backups](#backups)
* [Persistent Undo](#undo)
* [Macros](#macros)
* [Interesting Plugins](#interesting)
* [Ruby/Rails Support](#ruby)
* [Color themes](#themes)
* [Syntax plugins](#syntax)
* ["Support" and "minor" plugins](#minor)
* [Misc Bindings](#misc)
* [Russian Translit Layout support](#russian)

<a name=installation>
##### Installation

From your homedirectory (on Linux/Mac OSX):

* `git clone git://github.com/astrails/dotvim.git`
* `ln -sfn dotvim .vim`
* `ln -sfn dotvim/vimrc .vimrc`
* `cd .vim; make install`
* create ~/.local.vim if you want to have some
  local/personal settings you don't want to commit into the repo

Note: if you already have `~/.vim` `~/.vimrc` REMOVE THEM (you might want to backup them first :)

[top](#top)

<a name=general>
#### General configuration

`,` is used as mapleader
`backslash` is used as localleader

* `,e` mapped to `:e **/`. essentially you do `,efoo<tab>` to get a list of all files starting with foo
* `,s` - toggle invisible characters display
* `,n` - next `quicklist` result (like :Ggrep etc)
* `,N` - previous `quicklist` result (like :Ggrep etc)
* `Ctrl-E` - switch between 2 last buffers  (its just a `:b#<cr>` :)
* `Ctrl-N` to cancel current search highlighing
* `,f` global Ggrep for word under the cursor or for selection
* `+`, `-` - easily inc/decrement integers
* `,W` - remove trailing spaces
* `Ctrl-g`/`h`/`j`/`k` - simplified split panes navigation

Check out the 'plugins.vim' and 'after/plugin/bindings.vim' files for more...

[top](#top)

<a name=backups>
#### Backups

Backups and swapfiles are disabled. I really hate them both.

You can re-enable backups by adding the following to your `~/.local.vim`:

    set backup

 and swapfiles by

    set swapfile

backup dir is set to ~/.backup/

The directory is created if it doesn't exist.

[top](#top)

<a name=undo>
#### Persistent Undo

Persistent undos are enabled by default.

You can disable by adding the following to your `~/.local.vim`:

    set noundo

[top](#top)

<a name=macros>
#### Macros

I included a couple of macros that I frequently use in macros.vim which
is loaded from after.vim:

*    `@q` (re)format paragraph forward
*    `@s` enclose selection with double \*. e.g. \*\*foo\*\*.

You really should start writing your own macros. The life will never be the
same ;).

I recommend editing your macros in a vim buffer.

To load a macro into a register you can 'yank' it.

For example if you have a line with a macro and cursor is at the beginning of
it `"ay$`  will load the macro into register `a`, so that you will be able to
execute it with `@a`.

[top](#top)

<a name=interesting>
#### "Interesting" Plugins:

*   [nerdtree](http://github.com/scrooloose/nerdtree)

    hax0r vim script to give you a tree explorer

    * `Ctrl-P` - open directory browser
    * `,p` - to find and highlight the currently open file in the tree

*   [nerdcommenter](http://github.com/scrooloose/nerdcommenter)

    Vim plugin for intensely orgasmic commenting

    * `,/` - toggle comment
    * `,cc` - add commenting
    * `,cu` - Uncomment
    * check docs for more

*   [Command-T](http://github.com/vim-scripts/Command-T)

    TextMate Command-T like file finder for vim

    * `,,` - find file
    * `,.` - refresh the file list and then find a file
    * while at the finder prompt:
      * `Ctrl-Enter` - open file in a new split
      * `Ctrl-s` - open file in a new split
      * `Ctrl-v` - open file in a new vertical split
      * `Ctrl-U` - clear current partial path
      * `Esc` - cancel
      * `Ctrl-c` - cancel

*   [AutoComplPop](http://github.com/vim-scripts/AutoComplPop)

    Automatically opens popup menu for completions

    Shouldn't require config.

*   [taglist.vim](http://github.com/vim-scripts/taglist.vim)

    Source code browser (supports C/C++, java, perl, python, tcl, sql, php, etc)

    * `,t` - toggle tags window

*   [YankRing.vim](http://github.com/vim-scripts/YankRing.vim)

    Maintains a history of previous yanks, changes and deletes

    * `,y` to show the yankring
    * `,[`/`,]` - to cycle the just-pasted text though the yankring.
    * `:h yankring.txt` and `:h yankring-tutorial` for more

*   [vim-fugitive](http://github.com/tpope/vim-fugitive)

    A Git wrapper so awesome, it should be illegal

    *    `:Gstatus`

         Bring up the output of git-status in the preview
         window.  Press `-` to stage or unstage the file on the
         cursor line.  Press `p` to do so on a per hunk basis
         (--patch).  Press `C` to invoke :Gcommit.

    *    `:Gcommit [args]`

         A wrapper around git-commit.

    *    `:Ggrep [args]`

         :grep with git-grep as 'grepprg'.

    *    `,g`

         shortcut to run :Ggrep

    *   `//`

        global git search for the word under the cursor for for selection (in visual mode)

    *   `:Gblame`

        Run git-blame on the file and open the results in a
        scroll bound vertical split.  Press enter on a line to
        reblame the file as it was in that commit.

    Much more in the plugin's doc

*   [syntastic](http://github.com/scrooloose/syntastic)

    syntax checking plugin

    it will display the number of syntax errors in the current file in the vim's status line.

    use `:Errors` to display a window detailing the errors

*   [snipmate](http://github.com/msanders/snipmate.vim)

    TextMate-style snippets for Vim

    write a snipped text and press TAB to expand it.

    To see the list of available snippets type `Ctrl-R <Tab>` in the insert mode

*   [vim-surround](http://github.com/tpope/vim-surround)

    Delete/change/add parentheses/quotes/XML-tags/much more with ease

    * `dsX` - delete surround X
    * `csXY` - change surround X with Y
    * `s/S` in visual mode - wrap selection
    * `ysMovementX` - surround movement with X

    You should REALLY read the docs if you want to use this one

*   [vim-align](http://github.com/tsaleh/vim-align)

    Align and AlignMaps lets you align statements on their equal signs, make comment boxes, align comments, align declarations, etc.

    * `,t=` - align on =
    * `,tsp` - align on whitespace
    * `,t,` - align on commas
    * `,t|` - align on vertical bars
    * `,acom` - align comments (C/C++)
    * `:AlignSEPARATORS` - align on separators
    * `:h align` - see help for more options

*   [ack.vim](http://github.com/mileszs/ack.vim)

    This plugin is a front for the Perl module App::Ack. Ack can be used as a replacement for 99% of the uses of grep.

    * `:Ack [options] {pattern} [{directory}]` - grep for the pattern in side directory and open result in a QuickFix window
    * `:Ack --ruby ...` - search only ruby files.
    * `:h Ack` - more help about Ack

*   [vim-indentobject](https://github.com/austintaylor/vim-indentobject)

    A text object for manipulating blocks based on their indentation

    This is good for Python, YAML, HAML etc.

    Usage is similar to textobj-rubyblock, just with `i` instead of `r`

    * `vai` / `vii` - select indent block including / excluding the outer lines
    * ...

*   [greplace.vim](http://github.com/vim-scripts/greplace.vim)

    Replace a pattern across multiple files interactively

    Use `:Gsearch` to search for a pattern. Edit the result buffer to your
    liking, then `:Greplace` to incorporate your edits into the source files

    * `:Gsearch` - Search for a given pattern in the specified group of files
      and display the matches in the replace buffer.
    * `:Gbuffersearch` - Search for a given pattern in all the buffers in the Vim buffer list.
    * `:Greplace` - Incorporate the modifications from the replace buffer into
      the corresponding files.

*   [vim-powerline](TBD)

    TBD

*   [threesome.vim](https://github.com/sjl/threesome.vim)

    A plugin for resolving conflicts during three-way merges.

    Add the following lines to ~/.gitconfig to use

    [merge]
    tool = threesome

    [mergetool "threesome"]
    cmd = "mvim -f $BASE $LOCAL $REMOTE $MERGED -c 'ThreesomeInit'"
    trustExitCode = true

    Bindings:

    * `\g` - switch to grid view
    * `\l` - switch to loupe view
    * `\c` - switch to compare view
    * `\p` - switch to path view

    * `\o` - select the original file
    * `\1` - select file one
    * `\2` - select file two
    * `\r` - select the results file

    * `\n` - next unresolved conflict
    * `\N` - prev unresolved conflict

    * `\<space>` - cycle layout
    * `\s` - toggle scrolllocking
    * `\d` - cycle diff combinations
    * `\D` - turn off all diffs

    * `\CC` - exits vim with error code (like :cquit). this will indicate to git that merge resolution failed

    * `:h threesome` - you should probably read it ;)

*   [vim-endwise](http://github.com/tpope/vim-endwise)

    Wisely add "end" in ruby, endfunction/endif/more in vim script, etc

*   [delimitMate](http://github.com/Raimondi/delimitMate)

    auto-completion for quotes, parens, brackets, etc. in insert mode.


[top](#top)

<a name=ruby>
#### Ruby/Rails support:

*   [vim-rails](http://github.com/tpope/vim-rails)

    Ruby on Rails: easy file navigation, enhanced syntax highlighting, and more

    * `:AV` - open "alternate" file in a new vertical split
    * `:AS` - open "alternate" file in a new horizontal split
    * `:RV` - open "related" file in a new vertical split
    * `:RS` - open "related" file in a new horizontal split
    * `:Rextract` - extract partial (select text for extraction first)
    * `:Rinvert` - takes a self.up migration and writes a self.down.
    * `gf` - remapped to take context into account. recognizes models
      associations, partials etc.
    * `:h rails` for much more info ;)

*   [vim-bundler](https://github.com/tpope/vim-bundler)

    Lightweight support for Ruby's Bundler

    * `gf` when standing over a gem name in a Gemfile will go to gem's directory
    * `:Bopen NAME` does bundle open NAME - opens gem NAME's lib diretory in the current window.
    * `:Bundle` - runs bundler

*   [vim-rake](https://github.com/tpope/vim-rake)

    TBD

*   [vim-textobj-rubyblock](https://github.com/nelstrom/vim-textobj-rubyblock)

    A custom text object for selecting ruby blocks.

    In other words it teaches vim to understand what is ruby block, just like vim already understands what is word, paragraph, sentence etc.

    It works with begin/end, if/else/end etc.

    * `var` - select ruby block around the cursor including begin/end
    * `vir` - select insides of a ruby block around the cursor not including begin/end
    * `dar` - delete ruby block around the cursor
    * etc...

    Some 'trickier' usage patterns.

    * `varar` - select the ruby block that is around the ruby block that is around the cursor. including begin/end
    * `vararir` - select insides of the ruby block that is around the ruby block that is around the cursor. not including begin/end
    * ...

*   [vim-ruby-refactoring](https://github.com/ecomba/vim-ruby-refactoring)

    Refactoring tool for Ruby in vim!

    * `,rap`  :RAddParameter           - Add Parameter(s) to a method
    * `,rcpc` :RConvertPostConditional - Convert Post Conditional
    * `,rel`  :RExtractLet             - Extract to Let (Rspec)
    * `,rec`  :RExtractConstant        - Extract Constant (visual selection)
    * `,relv` :RExtractLocalVariable   - Extract Local Variable (visual selection)
    * `,rit`  :RInlineTemp             - Inline Temp. replace temp parameter by direct function call
    * `,rrlv` :RRenameLocalVariable    - Rename Local Variable (visual selection/variable under the cursor
    * `,rriv` :RRenameInstanceVariable - Rename Instance Variable (visual selection)
    * `,rem`  :RExtractMethod          - Extract Method (visual selection)

*   [apidock.vim](https://github.com/alexandrov/apidock.vim)

    Vim plugin that searches http://apidock.com Ruby, Rails, and RSpec docs from within Vim.

    * `RR` - Search the Rails docs for the word under the cursor.
    * `RB` - Search the Ruby docs for the word under the cursor.
    * `RS` - Search the RSpec docs for the word under the cursor.


[top](#top)

<a name=themes>
#### Color themes

*   [vim-colors-solarized](http://github.com/altercation/vim-colors-solarized)

    precision colorscheme for the vim text editor

*   [vim-vividchalk](http://github.com/tpope/vim-vividchalk)

    A colorscheme strangely reminiscent of Vibrant Ink for a certain OS X editor


[top](#top)

<a name=syntax>
#### Syntax plugins

*   [vim-tmux](http://tmux.sourceforge.net/)

    syntax  suupport (extracted from tmux-1.1)

*   rcov

    support (extracted from rcov-0.8.1.2.0 ruby gem)

*   [Puppet-Syntax-Highlighting](https://github.com/vim-scripts/Puppet-Syntax-Highlighting)

    Syntax Highlighting for Puppet

*   [JSON.vim](https://github.com/vim-scripts/JSON.vim)

    synntax highlighting file for JSON

*   [vim-cucumber](http://github.com/tpope/vim-cucumber)

    syntax, indent, etc. for [Cucumber](http://github.com/aslakhellesoy/cucumber)

*   [vim-haml](http://github.com/tpope/vim-haml)

    [HAML](http://haml-lang.com/) syntax etc.

*   [vim-markdown](http://github.com/plasticboy/vim-markdown)

    syntax for [Markdown](http://daringfireball.net/projects/markdown/)

*   [vim-coffee-script](http://github.com/kchmck/vim-coffee-script)

    syntax for [Coffee script](http://jashkenas.github.com/coffee-script/)

*   [jade.vim](https://github.com/vim-scripts/jade.vim)

    syntax for [Jade](http://jade-lang.com/)

*   [vim-slim](https://github.com/bbommarito/vim-slim)

    [Slim](http://slim-lang.com/) syntax support.

*   stylus

    TBD

[top](#top)

<a name=minor>
#### "Support" and "minor" plugins

*   [vim-textobj-user](https://github.com/kana/vim-textobj-user)

    Support for user-defined text objects

*   [vim-repeat](http://github.com/tpope/vim-repeat)

    Use the repeat command "." with supported plugins

*   [vim-space](http://github.com/scrooloose/vim-space)

    Smart Space key for Vim

    press SPACE to repeat last motion command


[top](#top)

<a name=misc>
### Misc Bindings

The following is a list of commands and key bindings that I personally find interesting
stored for easy refreshing my memory of them. there is no much 'system' to it, just
randomly chosen bits of vim goodness.

* `]p` paste with autoindent.
* `ga` print ascii value of character under the cursor
* `g#` like "#", but without using "\<" and "\>"
* `g<` display previous command output
* `zt` scroll cursor line to top
* `zz` scroll cursor line to center
* `zb` scroll cursor line to bottom
* `CTRL-W x` exchange current window with n-th window (or next if no count given)
* `gv` reselect last selection
* `gt` next tab
* `gT` prev tab
* `ci` change inside delimiters
* `di` delete inside delimiters
* `@@` execute last macro
* `"xyy` copy line into `x` register (replace x with any other)
* `<C-R>x` while in insert mote will paste content of register x (replace x with any other)
* `"xp` paste from register x
* `:reg` Display the contents of all numbered and named registers.


[top](#top)

<a name=russian>
#### Russian Translit Layout support

There is ~/.vim/bindings-ru-translit.vim file.

OSX has a nice russian translit keyboard layout which I use when I need to
write any russian text. The problem is that once I go to the normal mode
nothing works. This is an attempt to make vim at least partially useful when
the kerboard is in russioan translit mode and not in the default US mode. The
idea is to remap the russian characters to the english characters that
correspond to the same keyboard key. And a couple of userful multy-key
combinations.

Similar can be done for other keyboard layouts, your pull requests are
welcome ;).

To use this feature: just include the file from your ~/.local.vim:

    source ~/.vim/bindings-ru-translit.vim

[top](#top)


#### Copyright

&copy; 2012 [Vitaly Kushner](mailto:vitaly@astrails.com)
