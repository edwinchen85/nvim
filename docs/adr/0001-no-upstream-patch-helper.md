# ADR-0001: No shared helper for monkeypatching plugin internals

Status: accepted (2026-09-09)

## Context

Nine places wrap a plugin or Neovim function in place (save original, replace
field, delegate): `gitsigns.render.capture.capture_node`,
`pipetable.manager.on_cursor`, `pipetable.width.fit`,
`render-markdown.render.inline.link.setup`, the render-markdown
`quote`/`heading` `setup`, `fff_plus.layout.frame`, `vim.notify`,
`vim.lsp.util.open_floating_preview`, `vim.health.error`. An architecture
review proposed a `patch(mod, key, wrap)` helper that asserts the target exists
and registers the patch for `:checkhealth`.

## Decision

Keep the hand-rolled save/wrap idiom at each site. Do not add a helper.

## Reasons

- No patch has ever broken silently through upstream drift; plugins are pinned
  in `lazy-lock.json`, so drift only happens on an explicit `:Lazy update`.
- If the patched field disappears, the wrapper's `return orig(...)` already
  fails loudly with "attempt to call a nil value" on first use.
- The genuinely silent failure (upstream still exports the function but stops
  calling it on the relevant path) is not detectable by an existence assert, so
  the helper would not prevent the one failure that matters.
- Three of the nine sites patch Neovim core, which does not churn like plugin
  internals.

## Consequences

Each patch site stays self-contained and cites the upstream fact it depends on
(file/line or function name) in a comment. Revisit if an update ever breaks a
patch without an error.
