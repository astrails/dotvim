set nocompatible
filetype off

if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#begin(expand('~/.vim/bundle/'))

" plugin management
NeoBundleFetch 'Shougo/neobundle.vim'

" file tree
NeoBundle 'scrooloose/nerdtree'
" file tree and tabs interaction
NeoBundle 'jistr/vim-nerdtree-tabs'
" commenting
NeoBundle 'scrooloose/nerdcommenter'
" fuzzy file open
NeoBundle 'kien/ctrlp.vim'
" popup completion menu
NeoBundle 'AutoComplPop'
" tags list navigation
NeoBundle 'taglist.vim'
" yank history
NeoBundle 'YankRing.vim'
" git integration
NeoBundle 'tpope/vim-fugitive'
" syntax checking on save
NeoBundle 'scrooloose/syntastic'
" TextMate-style snippets
NeoBundle 'msanders/snipmate.vim'
" manipulation of surraunding parens, quotes, etc.
NeoBundle 'tpope/vim-surround'
" vertical alignment tool
NeoBundle 'tsaleh/vim-align'
" 'ag' searching integration
NeoBundle 'rking/ag.vim'
" text object based on indent level (ai, ii)
NeoBundle 'austintaylor/vim-indentobject'
" global search & replace
NeoBundle 'greplace.vim'
" better looking statusline
NeoBundle 'bling/vim-airline'
" plugin for resolving three-way merge conflicts
NeoBundle 'sjl/splice.vim'
" plugin for visually displaying indent levels
NeoBundle 'Indent-Guides'
" end certain structures automatically, e.g. begin/end etc.
NeoBundle 'tpope/vim-endwise'
" automatic closing of quotes, parenthesis, brackets, etc.
NeoBundle 'Raimondi/delimitMate'
" calendar, duh!
NeoBundle 'calendar.vim--Matsumoto'
" A Narrow Region Plugin (similar to Emacs)
NeoBundle 'chrisbra/NrrwRgn'
" url based hyperlinks for text files
NeoBundle 'utl.vim'
" A clone of Emacs' Org-mode for Vim
NeoBundle 'hsitz/VimOrganizer'
" visual undo tree
NeoBundle 'sjl/gundo.vim'
" switch segments of text with predefined replacements. e.g. '' -> ""
NeoBundle 'AndrewRadev/switch.vim'
" async external commands with output in vim
NeoBundle 'tpope/vim-dispatch'
" git diff in the gutter (sign column) and stages/reverts hunks
NeoBundle 'airblade/vim-gitgutter'

" Ruby/Rails

" rails support
NeoBundle 'tpope/vim-rails'
" bundler integration (e.g. :Bopen)
NeoBundle 'tpope/vim-bundler'
" rake integration
NeoBundle 'tpope/vim-rake'
" A custom text object for selecting ruby blocks (ar/ir)
NeoBundle 'nelstrom/vim-textobj-rubyblock'
" ruby refactoring
NeoBundle 'ecomba/vim-ruby-refactoring'
" apidock.com docs integration
NeoBundle 'apidock.vim'
" toggle ruby blocks style
NeoBundle 'vim-scripts/blockle.vim'
" lightweight Rspec runner for Vim
NeoBundle 'josemarluedke/vim-rspec'

" color themes
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'tpope/vim-vividchalk'
NeoBundle 'chriskempson/tomorrow-theme', {'rtp': 'vim/'}

" syntax support
NeoBundle 'vim-ruby/vim-ruby'
NeoBundle 'tsaleh/vim-tmux'
NeoBundle 'Puppet-Syntax-Highlighting'
NeoBundle 'JSON.vim'
NeoBundle 'tpope/vim-cucumber'
NeoBundle 'tpope/vim-haml'
NeoBundle 'tpope/vim-markdown'
NeoBundle 'kchmck/vim-coffee-script'
NeoBundle 'vitaly/vim-syntastic-coffee'
NeoBundle 'vim-scripts/jade.vim'
NeoBundle 'wavded/vim-stylus'
NeoBundle 'VimClojure'
NeoBundle 'slim-template/vim-slim'
NeoBundle 'elixir-lang/vim-elixir'
NeoBundle 'Blackrush/vim-gocode'
NeoBundle 'ekalinin/Dockerfile.vim'
NeoBundle 'groenewege/vim-less'

" Support and minor

" Support for user-defined text objects
NeoBundle 'kana/vim-textobj-user'
" replacement for the repeat mapping (.) to support plugins
NeoBundle 'tpope/vim-repeat'
" hide .gitignore-d files from vim
NeoBundle 'vitaly/vim-gitignore'
" repeat motion with <Space>
NeoBundle 'scrooloose/vim-space'
" Github's gist support
NeoBundle 'mattn/gist-vim'
" web APIs support
NeoBundle 'mattn/webapi-vim'

"NeoBundle 'ShowMarks'
"NeoBundle 'tpope/vim-unimpaired'
"NeoBundle 'reinh/vim-makegreen'

NeoBundle 'Shougo/vimproc'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/unite-outline'
NeoBundle 'ujihisa/unite-colorscheme'

call neobundle#end()

filetype plugin indent on

