; extends

; Highlight hunk bodies with the parser for the file being diffed.
;
; `#offset!` reshapes each line's range to `[col 1, col len+1)`: the leading `1`
; skips the `+`/`-`/` ` marker in column 0, and the trailing `1` pulls in the
; newline. Both matter — the lines are combined into one tree, so without the
; newline they concatenate into a single logical line and the first `--`/`//`
; comment swallows every line after it.
;
; `#diff-filename!` walks back to the nearest line that names a file: `+++ b/x.ts`
; in a real diff, or fugitive's `M x.ts` status line in the :Git buffer, where the
; inline hunks carry no diff header at all.
;
; The two sides need separate patterns, not one alternation: combined injections
; are keyed by pattern, so this yields one tree over the post-image (context +
; additions) and one over the pre-image (context + deletions). Merging them into
; a single tree would interleave both versions of every changed line and parse as
; garbage. Context lines land in both trees and just get highlighted twice.

; post-image
([
  (context)
  (addition)
] @injection.content
  (#offset! @injection.content 0 1 0 1)
  (#diff-filename! @injection.content)
  (#set! injection.combined))

; pre-image
([
  (context)
  (deletion)
] @injection.content
  (#offset! @injection.content 0 1 0 1)
  (#diff-filename! @injection.content)
  (#set! injection.combined))
