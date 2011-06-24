# apidock.vim #

This plugin allows you to browse [APIdock](http://apidock.com)'s Ruby, Rails, and RSpec docs
from within Vim.  It will invoke Firefox from the command line, and open the
query in a new tab.

The plugin uses the command 'firefox', which it expects to be in your path, and executable from your shell.  See 'Customization' below if you need some other behavior.  (In particular, all of you OSX users will have to make a small change.)  This should work out of the box on Ubuntu, and most other Linux-based systems on which Firefox is installed.

The *Official Version* of ack.vim is available at [vim.org](http://www.vim.org/scripts/script.php?script_id=2571).

## Installation ##

If you have [Rake](http://rake.rubyforge.org/) installed, you can just run: `rake install`.

The file apidock.vim goes in ~/.vim/plugin, and the apidock.txt file belongs in ~/.vim/doc.  Be sure to run

    :helptags ~/.vim/doc

afterwards.

## Usage ##

* RR - Search the Rails docs for the word under the cursor.

* RB - Search the Ruby docs for the word under the cursor.

* RS - Search the RSpec docs for the word under the cursor.

## Origin Story ##

This Vim plugin is mostly copied from the [AkitaOnRails](http://www.akitaonrails.com/) guys' [vimfiles on GitHub](http://github.com/akitaonrails/vimfiles/tree/master).  In particular, [this commit](http://github.com/fabiokung/vimfiles/commit/6723ec056282f4d2d66d214c921111f57fa48035) by [Cassio Marques](http://cassiomarques.wordpress.com/) on January 10th, 2009.  I just added the RSpec function, the help docs, and then threw it up on GitHub.  However, do bug _me_ if something isn't working.

## Customization ##

If you don't want to use Firefox, the fix is pretty simple.  Edit
~/.vim/plugin/apidock.vim, and edit the line (should be line #1),

<pre><code>
  let g:browser = 'firefox -new-tab '
</code></pre>

using the shell command for your preferred browser.

In OSX, you'll want to change the previously mentioned line to

<pre><code>
  let g:browser = 'open -a /Applications/Firefox.app'
</code></pre>

You may also need to remove the three ampersands in the file.  Davey did, anyway, as it wouldn't work with them.  I have no idea why.  Perhaps the 'open' command has problems with running asynchronously.  Maybe the ampersand insulted its mother.  Simply deleting the ampersand character will do, but you are welcome to remove everything after (and including) the final period from each line with an ampersand, if you'd like.
