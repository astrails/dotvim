let b:current_syntax = 'threesome'

syn match ThreesomeModes '\v^[^|]+'
syn match ThreesomeLayout '\v\|[^\|]+\|'
syn match ThreesomeCommands '\v[^\|]+\|$'
syn match ThreesomeHeading '\v(Threesome Modes|Threesome Commands|Layout -\>)' contained containedin=ThreesomeModes,ThreesomeLayout,ThreesomeCommands
syn match ThreesomeSep '\v\|' contained containedin=ThreesomeLayout,ThreesomeCommands
syn match ThreesomeCurrentMode '\v\*\S+' contained containedin=ThreesomeModes

hi def link ThreesomeSep Comment
hi def link ThreesomeHeading Comment
hi def link ThreesomeModes Normal
hi def link ThreesomeCurrentMode Keyword
