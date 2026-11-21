# Database guide (dadbod-grip)

dadbod-grip is a database client inside Neovim. You open a table, it shows up
as a grid, and you edit the cells like text. Nothing is written to the database
until you say so.

Spec: `lua/plugins/dadbod-grip.lua`. Full reference: `:help dadbod-grip`.
Press `?` in any Grip window for the keys of that window.

Two keys differ from the upstream docs in this config:

| Upstream     | Here         | Why                                              |
| ------------ | ------------ | ------------------------------------------------ |
| `<leader>db` | `<leader>D`  | `<leader>db` is the debugger's breakpoint key    |
| `<C-CR>`     | `<C-e>`      | `<C-CR>` arrives as plain Enter under tmux (§13) |

## 1. What you need

Grip talks to a database through that database's command-line tool. The tool
must be on your `PATH`.

| Database   | Tool      | URL looks like                          | Install                     |
| ---------- | --------- | --------------------------------------- | --------------------------- |
| SQLite     | `sqlite3` | `sqlite:shop.db`                        | already on macOS            |
| PostgreSQL | `psql`    | `postgresql://user:pass@localhost/mydb` | `brew install libpq` (\*)   |
| MySQL      | `mysql`   | `mysql://user:pass@localhost/mydb`      | `brew install mysql-client` |
| DuckDB     | `duckdb`  | `duckdb:file.duckdb`                    | `brew install duckdb`       |

(\*) Homebrew does not put `libpq` on your `PATH`. Add its `bin` folder yourself.

Only `sqlite3` was installed when this guide was written. Run
`:checkhealth dadbod-grip` to see what Grip can find.

## 2. The four windows

| Press | Window         | What it is                                  |
| ----- | -------------- | ------------------------------------------- |
| `1`   | Schema sidebar | List of tables. Press `1` again: connections |
| `2`   | Query pad      | Where you type SQL. Press `2` again: history |
| `3`   | Grid           | The table rows. Press `3` again: pick a table |
| `?`   | Help           | Keys for the window you are in              |

`1`, `2`, `3` work from any Grip window.

## 3. Connect

| Do this                            | What happens                           |
| ---------------------------------- | -------------------------------------- |
| `<leader>D` or `:GripConnect`      | Pick a saved connection, or add one    |
| `:GripConnect sqlite:shop.db`      | Connect straight to a URL              |
| `gC` or `<C-g>` in a Grip window   | Switch connection                      |
| `:GripStart`                       | Open the built-in demo database        |

A relative SQLite path is relative to the folder you started nvim in.

Connections you add in the picker are saved in `.grip/connections.json` in
the project. In the picker, `G` copies one to `~/.grip/connections.json`
(all projects) and `D` removes one.

## 4. Look at tables

| Do this                     | What happens                              |
| --------------------------- | ----------------------------------------- |
| `go`, `gT` or `gt`          | Table picker                              |
| `:Grip customers`           | Open a table by name                      |
| `gb` or `:GripSchema`       | Open the sidebar                          |

In the sidebar:

| Key       | What it does                          |
| --------- | ------------------------------------- |
| `<CR>`    | Open the table                        |
| `l` / `h` | Show / hide the table's columns       |
| `/`       | Search                                |
| `r`       | Refresh the table list                |
| `y`       | Copy the table or column name         |
| `+`       | Create a table                        |
| `D`       | Drop the table                        |
| `<Esc>`   | Close the sidebar                     |

## 5. Move around the grid

| Key                 | What it does                         |
| ------------------- | ------------------------------------ |
| `j` / `k`           | Row down / up                        |
| `w` / `b`, `<Tab>`  | Next / previous column               |
| `0` / `$`           | First / last column                  |
| `gg` / `G`          | First / last row                     |
| `H` / `L`           | Previous / next page (100 rows each) |
| `K`                 | Show the row top-to-bottom           |
| `-` / `g-`          | Hide this column / show all again    |
| `=`                 | Cycle column width                   |
| `r`                 | Reload from the database             |

## 6. Change data

Edits are **staged** first. Staged means "remembered, not saved yet". The
grid shows them in color, and the database is untouched until you press `a`.

| Color  | Meaning            |
| ------ | ------------------ |
| Violet | Cell you changed   |
| Red    | Row to be deleted  |
| Green  | New row            |

| Key            | What it does                                   |
| -------------- | ---------------------------------------------- |
| `i` or `<CR>`  | Edit the cell (opens a small editor)           |
| `x`            | Set the cell to NULL (NULL = "no value")       |
| `p`            | Paste the clipboard into the cell              |
| `o`            | Add a new row                                  |
| `d`            | Mark the row for deletion (press again: unmark) |
| `gs`           | Show the SQL that `a` would run                 |
| `gl`           | Keep that SQL preview open while you edit      |
| `u`            | Undo one staged edit                           |
| `U`            | Throw away all staged edits                    |
| `a`            | **Apply**: write everything to the database    |
| `{` / `}`      | Jump to previous / next changed row            |

In the cell editor: `<CR>` or `<C-s>` saves the cell, `<C-c>` cancels.
`<Esc>` goes to normal mode so you can use Vim motions; then `<CR>` saves
and `q` cancels.

Select rows with `V` first to do many at once: `e` sets one value in the
column, `d` marks them all for deletion, `x` sets NULL.

`a` runs all staged changes in one transaction. A transaction is "all or
nothing": if one change fails, none of them are saved and your staged edits
stay on screen.

A table needs a primary key (a column that is unique per row, usually `id`)
to be editable. Grip uses it to find the row to change.

## 7. Sort and filter

| Key     | What it does                                        |
| ------- | --------------------------------------------------- |
| `s`     | Sort by this column: up, down, off                  |
| `S`     | Add a second sort column                            |
| `f`     | Show only rows with this cell's value               |
| `gn`    | Show only rows where this column is NULL            |
| `gF`    | Filter builder (`=`, `!=`, `>`, `<`, `LIKE`, `IN`)  |
| `<C-f>` | Type your own `WHERE` condition                     |
| `F`     | Clear filters                                       |
| `X`     | Reset sort, filters and page                        |
| `gP` / `gp` | Save / load a named filter for this table     |

## 8. Write your own SQL

Open the query pad with `q` (from the grid or sidebar), `2`, or
`:GripQuery`.

| Key              | What it does                                        |
| ---------------- | --------------------------------------------------- |
| `<C-e>`          | Run the SQL block under the cursor                  |
| `<C-e>` (visual) | Run only the selected lines                         |
| `<C-Space>`      | Open completion by hand                             |
| `<Tab>` / `<S-Tab>` | Next / previous suggestion                     |
| `<CR>`           | Accept the selected suggestion, else a new line     |
| `gF`             | Format the SQL                                      |
| `<C-s>`          | Save the query (same as `:GripSave`)                |
| `gq`             | Load a saved query                                  |
| `gh`             | History                                             |
| `gw`             | Jump to the grid                                    |

A "block" is the lines around the cursor up to the next blank line. Put a
blank line between queries and `<C-e>` runs only the one you are on.

Completion suggests table names, column names and keywords after two letters
or a dot (`customers.`). It is Grip's own popup; blink is off in the pad.

The result of a query you typed is read-only. Press `gO` in the grid to
reopen it as an editable table.

Example queries (the table names are made up):

```sql
SELECT * FROM orders WHERE status = 'pending';

SELECT c.name, p.name AS product, o.quantity
FROM orders o
JOIN customers c ON c.id = o.customer_id
JOIN products p ON p.id = o.product_id;

SELECT category, COUNT(*) AS items, SUM(stock) AS total_stock
FROM products
GROUP BY category;
```

## 9. Saved queries and history

Both live in a `.grip/` folder in the project, so each project has its own.

| Do this              | What happens                                   |
| -------------------- | ---------------------------------------------- |
| `:GripSave report`   | Save the pad to `.grip/queries/report.sql`     |
| `:GripLoad report`   | Load it back into the pad                      |
| `:GripLoad` or `gq`  | Pick a saved query, with preview               |
| `:GripHistory` or `gh` | Pick from everything you ran, with preview |

History is automatic: every query and every applied edit is appended to
`.grip/history.jsonl`. Saved queries store a connection ID, never the
password.

Decide per project whether `.grip/` belongs in git or in `.gitignore`.

## 10. Change the structure

| Do this                          | What happens                                |
| -------------------------------- | ------------------------------------------- |
| `:GripCreate` or `+` in sidebar  | Table designer; shows the SQL, asks first   |
| `:GripDrop scratch` or `D` in sidebar | Drop a table; you must type its name |
| `:GripRename old new` or `gN`    | Rename a column                             |
| `gV`                             | Show the table's `CREATE TABLE` SQL         |
| `gi` / `gI`                      | Columns and types / plus indexes and stats  |
| `6` `7` `8` `9`                  | Columns, foreign keys, indexes, constraints |
| `4` or `gG`                      | Diagram of how tables link together         |

**Dropping a table is forever.** Practise on the demo database first
(`:GripStart`).

Anything the commands do not cover (add a column, add an index) is plain SQL
in the query pad:

```sql
ALTER TABLE customers ADD COLUMN phone TEXT;
```

## 11. Follow links between tables

A foreign key is a column that points at a row in another table, like
`orders.customer_id` pointing at `customers.id`.

| Key     | What it does                                           |
| ------- | ------------------------------------------------------ |
| `gf`    | On a foreign key cell: open the row it points at       |
| `gm`    | The other way: open the rows that point at this row    |
| `<C-o>` | Go back                                                |

## 12. Copy, export, import

| Key / command  | What it does                                         |
| -------------- | ---------------------------------------------------- |
| `y`            | Copy the cell                                        |
| `Y`            | Copy the row as CSV                                  |
| `gY` / `gy`    | Copy the table as CSV / as a Markdown table          |
| `gE`           | Copy to clipboard, choose from 6 formats             |
| `gX` or `:GripExport` | Save to a file: csv, json or sql            |
| `:GripImport`  | Stage rows from CSV/TSV/JSON on the clipboard        |
| `:GripImport !cat new.csv` | Same, from a command's output            |

Imported rows are only staged. Press `a` to save them. Column names in the
input must match the table's column names exactly.

## 13. Things that do not work here

- `<C-CR>` and `<S-CR>`. `lua/config/settings.lua` switches off the terminal
  mode that tells these apart from plain Enter (the Cmd+V paste fix for
  Ghostty + tmux). So under tmux both arrive as `<CR>`. Run is rebound to
  `<C-e>`. "Open in a new split" (`<S-CR>` in the pad and sidebar) has no
  replacement key yet; set `qpad_execute_new` / `sidebar_open_spl` under
  `opts.keymaps` if you want one.
- AI keys (`A`, `gA`, `:GripAsk`, `:GripFill`) need an API key in the
  environment. Not set up.

Upstream docs and the `?` help of other panes may still say `<C-CR>`. Read
it as `<C-e>`.

## 14. Cheat sheet

```
<leader>D   connect            go   pick table        q    query pad
i  edit     o  new row         d    delete row        x    NULL
gs preview  a  APPLY           u    undo one          U    undo all
s  sort     f  filter          F    clear filter      r    reload
<C-e> run   <C-s> save query   gq   load query        gh   history
gf follow link    <C-o> back   ?    help
```
