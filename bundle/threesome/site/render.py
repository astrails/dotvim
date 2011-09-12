#!/usr/bin/env python

import os
import markdown

extensions = ['toc']
fns = [f for f in os.listdir('.') if f.endswith('.markdown')
                                  or f.endswith('.mdown')
                                  or f.endswith('.md')]

with open('layout.html') as layoutfile:
    layoutlines = layoutfile.readlines()

for fn in fns:
    name = fn.rsplit('.')[0]
    newfn = name + '.html'

    with open(fn) as mdfile:
        title = mdfile.readline().strip()
        content = markdown.markdown(mdfile.read(), extensions)

    with open(newfn, 'w') as newfile:
        for line in layoutlines:
            line = line.replace('{{ title }}', title)
            line = line.replace('{{ content }}', content)
            newfile.write(line)

