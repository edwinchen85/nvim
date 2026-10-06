-- Pure check for config/vue_blocks: SFC block tracking shared by the diff
-- injections and the zdiff patch.
--
--   nvim -l lua/config/checks/vue_blocks.lua

local vue = require("config.vue_blocks")

local function run(lines, seed)
    local out, block = {}, seed
    for _, l in ipairs(lines) do
        local lang
        lang, block = vue.step(block, l)
        out[#out + 1] = tostring(lang)
    end
    return table.concat(out, " ")
end

-- full SFC: tag lines are html, content takes the block's language, lang= wins
assert(run({
    '<script setup lang="ts">',
    "const a = 1",
    "</script>",
    "",
    "<template>",
    "  <div/>",
    "</template>",
    '<style lang="scss">',
    ".a {}",
    "</style>",
}) == "html typescript html nil html html html html scss html", "full sfc")
-- bare <script> defaults to typescript, tag with trailing content still counts
assert(run({ "<script>const x = 1", "let y" }) == "html typescript", "bare script default")
-- unknown block: sniff by shape
assert(run({ "const a = 1", "  <span>x</span>" }) == "typescript html", "sniff")
-- seeded mid-block from the working tree
assert(run({ ".a {}", "</style>", "x" }, "css") == "css html nil", "seeded")
-- open_block
assert(vue.open_block("<template>") == "html" and vue.open_block("</script>") == false and vue.open_block("foo") == nil)

print("ok")
