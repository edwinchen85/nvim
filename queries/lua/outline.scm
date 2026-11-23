; Breadcrumb outline, read by lua/config/breadcrumbs.lua. Capture names follow
; Zed's outline queries: @item is the whole symbol, @name its name, @context the
; keywords and brackets shown around the name.

(function_declaration
  "local"? @context
  "function" @context
  name: (_) @name
  parameters: (parameters
    "(" @context
    ")" @context)) @item

; M.name = function() ... end
(assignment_statement
  (variable_list
    name: (_) @name)
  (expression_list
    value: (function_definition))) @item

; local name = function() ... end
(variable_declaration
  "local" @context
  (assignment_statement
    (variable_list
      name: (_) @name)
    (expression_list
      value: (function_definition)))) @item

; { name = function() ... end }
(field
  name: (identifier) @name
  value: (function_definition)) @item
