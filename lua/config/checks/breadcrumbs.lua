-- Pure check for config/breadcrumbs: the symbol trail built from
-- queries/<lang>/outline.scm, its per-token colours, and the long-trail clip.
--
--   nvim -l lua/config/checks/breadcrumbs.lua

vim.opt.rtp:prepend(vim.fn.stdpath("config"))
vim.opt.rtp:append(vim.fn.stdpath("data") .. "/site")
local bc = require("config.breadcrumbs")

local function attach(lang, lines)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.treesitter.start(buf, lang)
    vim.treesitter.get_parser(buf):parse(true)
    return buf
end

-- "a › b" of the trail at a 0-based position, or nil without an outline query
local function trail(buf, row, col)
    local segments = bc.outline(buf, row, col)
    if not segments then
        return nil
    end
    return table.concat(
        vim.tbl_map(function(s)
            return s.text
        end, segments),
        " › "
    )
end

local function eq(got, want)
    assert(got == want, ("got %q, want %q"):format(tostring(got), tostring(want)))
end

local tsx = attach("tsx", {
    "// comment",
    "export function MarkPaidButton(_props?: { referralId?: string }) {",
    "  return <p>hello world</p>;",
    "}",
    "",
    "abstract class Foo extends Bar {",
    "  private static async load(",
    "    id: string,",
    "  ) {",
    "    const handler = () => {",
    '      return { key: { "nested-key": 1 } };',
    "    };",
    "  }",
    "}",
    'describe("thing", () => {',
    '  it.only("works", () => {',
    "    expect(1).toBe(1);",
    "  });",
    "});",
    "interface Props { id: string }",
})

-- a space only where two captures are not adjacent: "(" hugs the name, ")" does not
eq(trail(tsx, 2, 4), "function MarkPaidButton( )")
eq(trail(tsx, 3, 1), "function MarkPaidButton( )") -- just past the closing brace still counts
eq(trail(tsx, 0, 0), "")
eq(trail(tsx, 4, 0), "")
-- nesting, modifiers, a parameter list spread over lines
eq(trail(tsx, 9, 4), "abstract class Foo › private static async load( )") -- on "const": the declarator is the item
eq(trail(tsx, 9, 12), "abstract class Foo › private static async load( ) › const handler")
eq(trail(tsx, 10, 25), "abstract class Foo › private static async load( ) › const handler › key › nested-key")
eq(trail(tsx, 16, 4), "describe thing › it.only works")
eq(trail(tsx, 19, 12), "interface Props")

-- each token keeps the buffer's own highlight group; the joining space has none
local chunks = bc.outline(tsx, 2, 4)[1].chunks
eq(chunks[1][1], "function")
assert(chunks[1][2]:find("^@keyword.*%.tsx$"), chunks[1][2])
eq(chunks[2][1], " ")
eq(chunks[2][2], nil)
eq(chunks[3][1], "MarkPaidButton")
assert(chunks[3][2]:find("^@function"), chunks[3][2])

local js = attach("javascript", {
    "class A {",
    "  static count = 0;",
    "  get size() {",
    "    return 1;",
    "  }",
    "}",
})
eq(trail(js, 1, 10), "class A › static count")
eq(trail(js, 3, 4), "class A › get size()") -- no parameters: the brackets are adjacent

local lua = attach("lua", {
    "local function a(x)",
    "  M.b = function()",
    "    return { c = function() end }",
    "  end",
    "end",
})
eq(trail(lua, 2, 24), "local function a( ) › M.b › c")

eq(trail(attach("json", { '{ "a": 1 }' }), 0, 3), nil)

-- Zed's MAX_SEGMENTS: first six, "⋯", last six
local many = {}
for i = 1, 14 do
    many[i] = { text = tostring(i), chunks = { { tostring(i) } } }
end
local clipped = vim.tbl_map(function(s)
    return s.text
end, bc.clip(many))
eq(table.concat(clipped, " "), "1 2 3 4 5 6 ⋯ 9 10 11 12 13 14")
eq(#bc.clip(vim.list_slice(many, 1, 12)), 12)

-- path: relative inside the window's cwd, home-relative outside it
local file = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_name(file, vim.fn.getcwd() .. "/src/a.tsx")
eq(bc.path(file, 0).text, "src/a.tsx")
vim.api.nvim_buf_set_name(file, vim.fn.expand("~") .. "/.breadcrumbs-check/a.tsx")
if not vim.startswith(vim.fn.expand("~") .. "/", vim.fn.getcwd() .. "/") then
    eq(bc.path(file, 0).text, "~/.breadcrumbs-check/a.tsx")
end

print("breadcrumbs ok")
