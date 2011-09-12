#!/usr/bin/env bash

python render.py
hg -R ~/src/sjl.bitbucket.org pull -u
rsync --delete -az . ~/src/sjl.bitbucket.org/threesome.vim
hg -R ~/src/sjl.bitbucket.org commit -Am 'threesome.vim: Update site.'
hg -R ~/src/sjl.bitbucket.org push
