; extends

; default vue/html attribute folding kept via extends:
;   class="...", :class="...", v-bind:class="..."
; function calls inside <script> blocks (cn/twMerge/clsx/cva/tw)
; are folded via the typescript/javascript after-queries through tree-sitter
; language injections — no patterns needed here for that.
