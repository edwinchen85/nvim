# Debug guide (JS / TS / Vue)

A debugger freezes your program on a line you pick. Then you look at the
values and walk forward one line at a time. No more `console.log`.

The setup is in `lua/plugins/dap.lua`: nvim-dap (the core), nvim-dap-ui (the
panels), nvim-dap-virtual-text (values shown beside the code) and
`js-debug-adapter` from Mason (VS Code's JS debugger).

Tested here: **Node: current file** and **Chrome: open a URL**. The Vitest and
attach options follow the upstream docs but have not been run in this config.

## 1. Keys

All keys start with `<leader>d`. Press `<leader>d` and wait to see the list.

| Key          | What it does                                             |
| ------------ | -------------------------------------------------------- |
| `<leader>db` | Put or remove a breakpoint on this line                  |
| `<leader>dB` | Breakpoint with a condition (stops only when it is true) |
| `<leader>dc` | Start. While paused: continue to the next breakpoint     |
| `<leader>do` | Step over: run this line, stay in this function          |
| `<leader>di` | Step into: go inside the function called on this line    |
| `<leader>dO` | Step out: finish this function, go back to the caller    |
| `<leader>de` | Show the value under the cursor (or the selection)       |
| `<leader>du` | Show or hide the panels                                  |
| `<leader>dr` | Run the last launch option again (no picker)             |
| `<leader>dx` | Stop the session                                         |

## 2. The loop

Every debug session is the same five steps.

1. **Breakpoint.** Cursor on the line you doubt, `<leader>db`. A `B` shows in
   the sign column.
2. **Start.** `<leader>dc`, then pick a launch option (section 3).
3. **Read.** The program stops on your line. Look at the grey text beside the
   code and at the Scopes panel.
4. **Step.** `<leader>do` to move on, `<leader>di` to go into a call,
   `<leader>dO` to leave it, `<leader>dc` to jump to the next breakpoint.
5. **Stop.** `<leader>dx`. Fix the code. `<leader>dr` to run it again.

## 3. The four launch options

`<leader>dc` with nothing running opens a picker. The same four options show
in `.js`, `.ts`, `.jsx`, `.tsx` and `.vue` files.

| Option                    | Use it for                                |
| ------------------------- | ----------------------------------------- |
| `Node: current file`      | A script you can run with `node file.js`  |
| `Vitest: current file`    | One test file                             |
| `Chrome: open a URL`      | Vue / React code that runs in the browser |
| `Node: attach to process` | A Node server that is already running     |

**Start Neovim in the project root.** The options use `${workspaceFolder}`,
and in nvim-dap that means Neovim's current directory (`:pwd`). If it is wrong,
fix it with `:cd path/to/project` before you start.

## 4. Chrome: Vue and React in the browser

Use this for anything that runs in the browser: components, composables,
stores, click handlers.

1. In a terminal, start the dev server: `pnpm dev`. Note the URL it prints.
2. In Neovim (opened in the project root), open the `.vue` or `.tsx` file.
3. Put a breakpoint inside the code you want to see, e.g. inside a click
   handler in `<script setup>`. `<leader>db`.
4. `<leader>dc`, pick **Chrome: open a URL**.
5. A `URL:` prompt shows `http://localhost:5173` (Vite's default). Press Enter,
   or edit it first if your port or page is different.
6. A new Chrome window opens on that page.
7. Do the thing in the page that runs your code (click the button, open the
   route). Chrome freezes, and Neovim jumps to your line.
8. Step and read as usual. `<leader>dc` lets the page run again.
9. `<leader>dx` stops the session and closes that Chrome window.

Things to know:

- **It is a clean Chrome.** The debugger opens Chrome with its own empty
  profile. You are not logged in and have no extensions. Log in again inside
  that window if the page needs it.
- **Code that runs on page load.** The page may run before the breakpoint is
  ready. If it did not stop, reload the page in the debug Chrome (`Cmd+R`).
- **Editing while debugging.** Vite hot-reloads your change. Breakpoints
  usually stay; if one stops hitting, reload the page.
- **Template code.** Breakpoints work in `<script>`. Lines in `<template>` are
  compiled away, so put the breakpoint in the function the template calls.
- **`debugger;`** A line with just `debugger;` in your code also stops there.
  Handy when a breakpoint will not bind. Remove it after.
- **Monorepo.** `webRoot` is Neovim's current directory. `:cd` into the app's
  own folder (the one with its `vite.config`), not the repo root.
- **Server code is not here.** Chrome only sees browser code. For Nuxt server
  routes, API handlers and SSR code, use attach (section 7).

## 5. Node: one file

For a plain script.

1. Open the file. `<leader>db` on a line.
2. `<leader>dc`, pick **Node: current file**.
3. It stops on your line. `console.log` output shows in the bottom panel.

Try it:

```js
// add.js
function add(a, b) {
  const sum = a + b + 1; // bug on purpose; breakpoint here
  return sum;
}
console.log(add(5, 10));
```

Breakpoint on the `const sum` line, start, then `<leader>do`. Grey text shows
`sum = 16`. It should be 15.

A `.ts` file works too if `node file.ts` works in your terminal. Your Node
(v22.23) runs simple TypeScript directly. Files that need a build step, path
aliases or `enum` will not run this way: debug them through Vitest or attach.

## 6. Vitest: one test file

Same idea as "debug the failing test": start from the test, stop in the code
it tests.

1. Put a breakpoint in the **code under test** (or in the test itself).
2. Open the `*.test.ts` / `*.spec.ts` file. It must be the current buffer.
3. `<leader>dc`, pick **Vitest: current file**.
4. It runs only that file and stops on your breakpoint.

It needs `node_modules/vitest/vitest.mjs` under Neovim's current directory.
If the breakpoint never hits, the usual cause is Vitest's worker pool: see the
Debugging page in the Vitest docs.

## 7. Attach: a server that is already running

For Node servers: Express, Nuxt server routes, scripts that take a while to
set up.

1. Start the server with the inspect flag:

   ```sh
   node --inspect server.js
   # stop on the very first line and wait for you:
   node --inspect-brk server.js
   # through a package script:
   NODE_OPTIONS=--inspect pnpm dev
   ```

2. In Neovim, put a breakpoint in the server code.
3. `<leader>dc`, pick **Node: attach to process**.
4. Pick the Node process from the list (type to filter).
5. Send a request that hits your code. It stops.

`<leader>dx` here ends the debug session.

## 8. The panels

They open when a session starts and close when it ends. `<leader>du` brings
them back.

| Panel       | Where  | What it shows                                 |
| ----------- | ------ | --------------------------------------------- |
| Scopes      | left   | Variables you can see right now, with values  |
| Breakpoints | left   | Every breakpoint you set                      |
| Stacks      | left   | Who called this function, and who called that |
| Watches     | left   | Expressions you asked it to keep showing      |
| REPL        | bottom | Type code, get the answer (section 10)        |
| Console     | bottom | Program output                                |

Move into a panel like any window, then:

| Key    | What it does                                                 |
| ------ | ------------------------------------------------------------ |
| `<CR>` | Open or close an object / array to see inside                |
| `o`    | Jump to that place in the code (a stack frame, a breakpoint) |
| `e`    | Change a variable's value, or edit a watch                   |
| `d`    | Remove a watch                                               |
| `t`    | Turn a breakpoint on or off without deleting it              |
| `r`    | Send the variable to the REPL                                |

To add a watch: go to the Watches panel, enter insert mode, type an expression
(e.g. `user.items.length`), press Enter. It updates on every step.

In Stacks, `o` on an older frame shows that caller's code and its variables.
Good for "how did I get here?".

## 9. Look at a value fast

- **Grey text beside the code**: values of variables on the lines that just
  ran. Automatic. `:DapVirtualTextToggle` turns it off and on.
- **`<leader>de`** on a variable: a float with the full value. Press it again
  to jump into the float; `<CR>` opens nested fields; `q` closes it.
- **Select then `<leader>de`**: evaluates the selection, e.g. select
  `items.filter(x => x.done).length` to see the result without changing code.

## 10. The REPL

A prompt that runs code inside the paused program. Go to the REPL panel and
enter insert mode.

- Type any expression: `user.name`, `items.map(i => i.id)`, `JSON.stringify(x)`.
- Change things: `count = 0`, then continue and see what happens.
- Commands start with a dot:

| Command         | Same as                     |
| --------------- | --------------------------- |
| `.c`            | Continue                    |
| `.n`            | Step over                   |
| `.into`         | Step into                   |
| `.out`          | Step out                    |
| `.up` / `.down` | Move through the call stack |
| `.frames`       | Print the call stack        |
| `.scopes`       | Print the variables         |
| `.clear`        | Clear the REPL              |
| `.help`         | List all commands           |

## 11. Smarter breakpoints

**Conditional**: `<leader>dB`, type a JS expression, Enter. It stops only when
the expression is true. Use it inside loops:

```
Breakpoint condition: item.id === 42
```

These have no key yet; run them from the command line:

| Want                                  | Command                                                              |
| ------------------------------------- | -------------------------------------------------------------------- |
| Log a message, do not stop (logpoint) | `:lua require("dap").set_breakpoint(nil, nil, "sum is {sum}")`       |
| Stop on the 5th time the line runs    | `:lua require("dap").set_breakpoint(nil, "5")`                       |
| Stop when an error is thrown          | `:lua require("dap").set_exception_breakpoints()` (pick from a list) |
| Run until the cursor line             | `:lua require("dap").run_to_cursor()`                                |
| Remove every breakpoint               | `:DapClearBreakpoints`                                               |

Breakpoints are forgotten when you quit Neovim.

## 12. When it does not work

| You see                                    | Likely cause                                 | Fix                                                                       |
| ------------------------------------------ | -------------------------------------------- | ------------------------------------------------------------------------- |
| Breakpoint never hits (Chrome)             | Wrong `:pwd`, or the code ran before attach  | `:cd` to the app root; reload the page                                    |
| Breakpoint never hits (anywhere)           | That line never runs, or it is compiled away | Move it to the next real statement, or use `debugger;`                    |
| Stops in a strange built file              | Source maps missing                          | Use the dev server, not a production build                                |
| "No configuration found"                   | Filetype is not in the list                  | Add it to the `ipairs({...})` list at the bottom of `lua/plugins/dap.lua` |
| JS adapter will not start                  | `js-debug-adapter` missing                   | `:MasonInstall js-debug-adapter`                                          |
| Vitest option fails at once                | No `node_modules/vitest` under `:pwd`        | `:cd` to the package that has Vitest                                      |
| Panels are gone                            | Session ended                                | `<leader>du`                                                              |
| A breakpoint hides a git / diagnostic sign | The sign column is one cell wide             | Nothing to fix; it comes back when the breakpoint goes                    |
| Something else                             |                                              | `:DapSetLogLevel TRACE`, try again, `:DapShowLog`                         |

`:checkhealth dap` shows whether the adapters are found.
