; Breadcrumb outline, read by lua/config/breadcrumbs.lua. Capture names follow
; Zed's outline queries: @item is the whole symbol, @name its name, @context the
; keywords and brackets shown around the name.

(function_declaration
  "async"? @context
  "function" @context
  name: (_) @name
  parameters: (formal_parameters
    "(" @context
    ")" @context)) @item

(generator_function_declaration
  "async"? @context
  "function" @context
  "*" @context
  name: (_) @name
  parameters: (formal_parameters
    "(" @context
    ")" @context)) @item

(class_declaration
  "class" @context
  name: (_) @name) @item

(class_body
  (method_definition
    [
      "get"
      "set"
      "async"
      "*"
      "static"
      "readonly"
      (override_modifier)
      (accessibility_modifier)
    ]* @context
    name: (_) @name
    parameters: (formal_parameters
      "(" @context
      ")" @context)) @item)

(object
  (method_definition
    [
      "get"
      "set"
      "async"
      "*"
    ]* @context
    name: (_) @name
    parameters: (formal_parameters
      "(" @context
      ")" @context)) @item)

(public_field_definition
  [
    "declare"
    "readonly"
    "abstract"
    "static"
    (accessibility_modifier)
  ]* @context
  name: (_) @name) @item

(lexical_declaration
  [
    "let"
    "const"
  ] @context
  (variable_declarator
    name: (identifier) @name) @item)

(pair
  key: [
    (property_identifier) @name
    (string
      (string_fragment) @name)
    (number) @name
    (computed_property_name) @name
  ]) @item

; test blocks: describe("name", ...), it.only("name", ...)
((call_expression
  function: [
    (identifier) @_fn
    (member_expression
      object: (identifier) @_fn)
  ] @context
  arguments: (arguments
    .
    (string
      (string_fragment) @name))) @item
  (#any-of? @_fn "describe" "it" "test" "context" "suite"))

(abstract_class_declaration
  "abstract" @context
  "class" @context
  name: (_) @name) @item

(interface_declaration
  "interface" @context
  name: (_) @name) @item

(type_alias_declaration
  "type" @context
  name: (_) @name) @item

(enum_declaration
  "enum" @context
  name: (_) @name) @item

(internal_module
  "namespace" @context
  name: (_) @name) @item
