; inherits: tsx

; override tailwind-fold default query (substring match folds any ident
; containing "tw"/"tv" like useFilterNetwork → "Network"). Anchor regex
; so only exact tailwind helper names match.
(call_expression
  function: [
    (identifier) @_ident
    (member_expression
      object: (identifier) @_object.ident)
  ]
  (#match? @_ident "^(clsx|classnames|cn|tv|tw|twMerge|css|cva)$")
  (#eq? @_object.ident "tw")
  arguments: [
    ((arguments
     (_)+) @tailwind.inner._args
     (#set! @tailwind.inner._args "sort" "skip"))
    (template_string) @tailwind.inner._str
  ])
