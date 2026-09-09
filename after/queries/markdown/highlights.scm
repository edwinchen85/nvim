; extends

; Git conflict markers are valid markdown by accident: `>>>>>>> branch` parses
; as seven nested block quotes, and `<<<<<<< HEAD` directly above `=======`
; parses as a setext H1. Paint both as plain text (@conflict.marker is defined
; in plugins/tokyonight.lua); priority beats the default 100 on the markers.
; Rendering is skipped separately in plugins/render-markdown.lua.
((block_quote) @conflict.marker
  (#lua-match? @conflict.marker "^>>>>>>> ")
  (#set! priority 101))

((setext_heading) @conflict.marker
  (#lua-match? @conflict.marker "^<<<<<<< ")
  (#set! priority 101))
