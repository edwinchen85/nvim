Substitution in quickfix list

```
:cdo s/node/deno/ | update
```

Jump to file from GV diff window

```
visual select the file path and press gf
```

Scrolling synchronously

```
# apply same vim command to two or more windows
:set scrollbind
:set noscrollbind
```

Add search term into location list

```
:lvimgrep /search_term/g %
```

Match exactly the keyword

```
/\v<keyword>
```

Edit workflow

- exit insert mode
- yank
- gi
- <c-r>0

Format json code

```
# visually select line of code
:'<,'>!jq .
```

Minify json code

```
# visually select line of code
:'<,'>!jq -c .
```

Resolve git conflict of binary files such as png

```
:Git checkout --theirs -- path/to/your/image.png
:Git add path/to/your/image.png
```

Resolve git conflict of deleted files

```
:Git rm path/to/your/deleted/file
:Git add path/to/your/deleted/file
```

Open file from git blob

```
gf path/to/your/file
:Gedit
```

Table management

```
# yank table
yip
# delete table
dip
```
