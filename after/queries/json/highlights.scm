; extends

; Diff hunks (fugitive's :Git status, `git diff`) hand json a loose run of lines,
; `"key": "value",`, which parses as bare strings split by ERROR nodes instead of
; `pair`s, so the stock queries above match nothing. A string beside an ERROR is
; the key when the ERROR after it starts with the `:`, else the value; a real
; document's lone top-level string is a string either way.

(document
  (string) @string)

(document
  (string) @property
  .
  (ERROR) @_colon
  (#match? @_colon "^:"))
