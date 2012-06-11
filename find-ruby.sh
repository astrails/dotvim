#!/bin/bash

if [ '/opt/local/bin/vim' = `which vim` -a -e /opt/local/bin/ruby ]; then
  echo /opt/local/bin/ruby
elif [ -e '/usr/bin/ruby' ]; then
  echo /usr/bin/ruby
else
  which ruby
fi
