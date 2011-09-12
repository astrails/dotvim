Threesome - a Vim plugin for resolving three-way merges-

Demo
----

[Watch the demo screencast][screencast] in HD on Vimeo.

[screencast]: http://vimeo.com/25764692

Requirements
------------

Vim 7.3+ compiled with Python 2.5+ support.

Yes, that's some (relatively) new stuff.  No, I'm not going to support anything less
than that.

Threesome is a merge tool which means you'll be working with it on your development
machine, not over SSH on your servers.

If you can't be bothered to run up-to-date versions of your tools on your main
development machine, I can't be bothered to clutter the codebase to support you.
Feels bad, man.

Installation
------------

Use [Pathogen][] to install the plugin from your choice of repositories:

    hg clone https://bitbucket.org/sjl/threesome.vim ~/.vim/bundle/threesome
    git clone https://github.com/sjl/threesome.vim.git ~/.vim/bundle/threesome

[Pathogen]: http://www.vim.org/scripts/script.php?script_id=2332

Build the docs:

    :call pathogen#helptags()

Add it as a merge tool for your VCS of choice.

### Mercurial

Add the following lines to `~/.hgrc`:

    [merge-tools]
    threesome.executable = mvim
    threesome.args = -f $base $local $other $output -c 'ThreesomeInit'
    threesome.premerge = keep
    threesome.priority = 1

**Note:** replace `mvim` with `gvim` if you're on Linux, or just plain `vim` if you prefer to keep the editor in the console.

### Git

Add the following lines to `~/.gitconfig`:

    [merge]
    tool = threesome

    [mergetool "threesome"]
    cmd = "mvim -f $BASE $LOCAL $REMOTE $MERGED -c 'ThreesomeInit'"
    trustExitCode = true

**Note:** replace `mvim` with `gvim` if you're on Linux, or just plain `vim` if you prefer to keep the editor in the console.

More Information
----------------

**Full Documentation:** `:help threesome`  
**Source (Mercurial):** <http://bitbucket.org/sjl/threesome.vim>  
**Source (Git):** <http://github.com/sjl/threesome.vim>  
**Issues:** <http://github.com/sjl/threesome.vim/issues>  
**License:** [MIT/X11][license]

[license]: http://www.opensource.org/licenses/mit-license.php
