; extends

(call_expression
  function: (identifier) @_fn
  (#any-of? @_fn "cn" "twMerge" "clsx" "cva" "tw")
  arguments: (arguments
    (string
      (string_fragment) @tailwind)))

(call_expression
  function: (identifier) @_fn
  (#any-of? @_fn "cn" "twMerge" "clsx" "cva" "tw")
  arguments: (arguments
    (template_string) @tailwind.inner))
