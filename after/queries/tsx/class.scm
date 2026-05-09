; extends

; cn("class1 class2"), twMerge("..."), clsx("...")
(call_expression
  function: (identifier) @_fn
  (#any-of? @_fn "cn" "twMerge" "clsx" "cva" "tw")
  arguments: (arguments
    (string
      (string_fragment) @tailwind)))

; cn(`class1 class2`)
(call_expression
  function: (identifier) @_fn
  (#any-of? @_fn "cn" "twMerge" "clsx" "cva" "tw")
  arguments: (arguments
    (template_string) @tailwind.inner))
