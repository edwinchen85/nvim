# Domain glossary

Terms used in code and reviews. Keep entries to what a future reader needs to
avoid re-deriving or re-suggesting.

- **Hunk** — a `+`/`-` body block of a diff, in real `git diff` output or in
  fugitive's `:Git` status buffer (whose inline hunks carry no diff header).
- **Hunk language** — the language a hunk line is highlighted with: the diffed
  file's filetype, resolved in `lua/config/diff_lang.lua` for treesitter
  injections. Vue files are the exception below.
- **Vue SFC block** — a `<script>`/`<template>`/`<style>` section of a `.vue`
  file. Hunk lines are highlighted with the block's language, not `vue`, since
  the vue grammar only highlights wrapped content. Tracked line-by-line by
  `lua/config/vue_blocks.lua`, shared by the diff injections and the zdiff
  patch. Block state is a language string, `false` (outside any block) or
  `nil` (unknown, sniff the line's shape). Bare `<script>` defaults to
  typescript.
- **Conflict marker** — a `<<<<<<<`, `|||||||` (diff3 base), `=======` or
  `>>>>>>>` line. Classified by `lua/config/conflict_markers.lua` (`marker(line)
  -> start|base|sep|end`), used by the diff injections, the fugitive no-EOL
  marks and the render-markdown patch. Not used by the `<leader>x` resolve
  keymaps, which are whole-buffer `:s` regexes and do not yet handle the diff3
  base section.
