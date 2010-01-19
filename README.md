This is a complete Vim configuration that I'm using everywhere

Plugins that are available form a git repository were added with
[Braid](http://github.com/evilchelu/braid) for easy upgrading.

*Some* help tips are provided for *some* of the plugins. please check out the plugin's docs for more info.

#### General configuration

"," is used as mapleader

Check out the 'vimrc' file for more...

#### Included Plugins:

*   pathogen 1.2 ([vim.org](http://www.vim.org/scripts/script.php?script_id=2332)) ([github](http://github.com/tpope/vim-pathogen))

    Allows to separate each plugin into its own subdirectory. `~/.vim/bundles` directory
    is used as the common root for all the plugins.

    Already configured

*   autocomplpop 2.14.1 ([vim.org](http://www.vim.org/scripts/script.php?script_id=1879))

    Automatically opens popup menu for completions

    Shouldn't require config.

*   cucumber ([github](http://github.com/tpope/vim-cucumber))

    syntax, indent, etc. for [Cucumber](http://github.com/aslakhellesoy/cucumber)

*   drillctg 1.1.3 ([vim.org](http://www.vim.org/scripts/script.php?script_id=2013))

    Allows fast drill-down search across the pathnames in your ctags file

    `:Drill` to open drill window

*   endwise ([vim.org](http://www.vim.org/scripts/script.php?script_id=2386)) ([github](http://github.com/tpope/vim-endwise))

    Wisely add "end" in ruby, endfunction/endif/more in vim script, etc 

*   fugitive ([github](http://github.com/tpope/vim-fugitive))

    A Git wrapper so awesome, it should be illegal

    *    :Gstatus

         Bring up the output of git-status in the preview
         window.  Press - to stage or unstage the file on the
         cursor line.  Press p to do so on a per hunk basis
         (--patch).  Press C to invoke |:Gcommit|.

    *    :Gcommit [args]

         A wrapper around git-commit.

    *    :Ggrep [args]

         |:grep| with git-grep as 'grepprg'.

    *   :Gblame

        Run git-blame on the file and open the results in a
        scroll bound vertical split.  Press enter on a line to
        reblame the file as it was in that commit.

    Much more in the plugin's doc

    
*   haml ([vim.org](http://www.vim.org/scripts/script.php?script_id=1433)) ([github](http://github.com/tpope/vim-haml))

    [HAML](http://haml-lang.com/) syntax etc.

*   json 0.4 ([vim.org](http://www.vim.org/scripts/script.php?script_id=1945))

    synntax highlighting file for JSON

*   kwdbi 1.1 ([vim.org](http://www.vim.org/scripts/script.php?script_id=2103))

    Keep Window on Buffer Delete - Improved

*   minibufexpl 6.3.2 ([vim.org](http://www.vim.org/scripts/script.php?script_id=159))

    Elegant buffer explorer - takes very little screen space

*   misc-lang-settings 

    ts/sw/et settings for various filetypes

*   nerdcommenter ([github](http://github.com/scrooloose/nerdcommenter))

    Vim plugin for intensely orgasmic commenting

    * ,/ - toggle comment
    * ,cc - add commenting
    * ,cu - Uncomment
    * check docs for more

*   nerdtree ([github](http://github.com/scrooloose/nerdtree))

    hax0r vim script to give you a tree explorer

    * Ctrl-P - open directory browser

*   pastie ([vim.org](http://www.vim.org/scripts/script.php?script_id=1624)) ([github](http://github.com/tpope/vim-pastie))

    integration with http://pastie.org

*   puppet ([vim.org](http://www.vim.org/scripts/script.php?script_id=2094))

    Syntax Highlighting for Puppet

*   rails ([vim.org](http://www.vim.org/scripts/script.php?script_id=1567)) ([github](http://github.com/tpope/vim-rails))

    Ruby on Rails: easy file navigation, enhanced syntax highlighting, and more

*   rcov

    [rcov](http://eigenclass.org/hiki.rb?rcov) support (extracted from rcov-0.8.1.2.0 ruby gem)

*   repeat ([vim.org](http://www.vim.org/scripts/script.php?script_id=2136)) ([github](http://github.com/tpope/vim-repeat))

    Use the repeat command "." with supported plugins

*   showmarks 2.2 ([vim.org](http://www.vim.org/scripts/script.php?script_id=152))

    Visually shows the location of marks.

*   surround ([vim.org](http://www.vim.org/scripts/script.php?script_id=1697)) ([github](http://github.com/tpope/vim-surround))

    Delete/change/add parentheses/quotes/XML-tags/much more with ease

    * dsX - delete surround X
    * csXY - change surround X with Y
    * s/S in visual mode - wrap selection 

    You should REALLY read the docs if you want to use this one

*   taglist ([vim.org](http://www.vim.org/scripts/script.php?script_id=273))

    Source code browser (supports C/C++, java, perl, python, tcl, sql, php, etc)

    * ,t - toggle tags window

*   tmux 

    [tmux](http://tmux.sourceforge.net/) syntax  suupport (extracted from tmux-1.1)

*   unimpaired ([github](http://github.com/tpope/vim-unimpaired))

    pairs of assorted bracket maps

*   vividchalk ([vim.org](http://www.vim.org/scripts/script.php?script_id=1891)) ([github](http://github.com/vitaly/vim-vividchalk))

    A colorscheme strangely reminiscent of Vibrant Ink for a certain OS X editor
