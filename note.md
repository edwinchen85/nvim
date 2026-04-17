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
