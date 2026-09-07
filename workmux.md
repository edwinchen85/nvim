# Worktree workflow: tmux-sessionizer + workmux

One repo, many rooms. Every project is a tmux session; every branch you work on
in parallel is a git worktree with its own session, its own Neovim and its own
Claude Code. No stashing, and an agent never edits the folder you are typing in.

## Keys

| Key            | Where | Does                                                            |
|----------------|-------|-----------------------------------------------------------------|
| `prefix + o`   | tmux  | Fuzzy-jump to any repo in `~/projects` or any running session   |
| `prefix + w`   | tmux  | workmux menu, then one letter (see below)                       |
| `prefix + f`   | tmux  | tmux-thumbs (unchanged, which is why the jumper is on `o`)      |
| `prefix + 1/2/3` | tmux | editor / server / agent window inside a worktree session      |
| `tms`          | shell | Same picker as `prefix + o`                                     |
| `<leader>zd`   | nvim  | Whole-branch diff in one buffer (`<leader>zD` against main)     |
| `<leader>at`   | nvim  | Send file + selection to the Claude that sidekick owns          |
| `<leader>ay`   | nvim  | Copy `path:start:end note` for the Claude in tmux window 3      |

`prefix` is `C-Space`.

### workmux menu (`prefix + w`, then…)

| Key | Action                                             | When                                  |
|-----|----------------------------------------------------|---------------------------------------|
| `a` | new branch + worktree + session                    | starting a ticket                     |
| `b` | worktree from an existing branch                   | a review landed on a branch you have  |
| `p` | new worktree, Claude starts on your prompt         | "go do this while I work on X"        |
| `o` | reopen a worktree whose session you closed         | back to yesterday's work              |
| `c` | close the session, keep folder and branch          | done for now                          |
| `r` | delete the worktree without merging                | experiment failed                     |
| `m` | merge into main, then delete everything            | shipped                               |
| `d` | full-screen dashboard of agents and worktrees      | "what is running?"                    |
| `s` | toggle the live agent sidebar                      | running 3+ agents                     |

## The daily loop

1. `prefix + o` — pick the repo.
2. `prefix + w`, `a` — name the branch. You land in `repo/branch` with nvim (1),
   an empty server window (2) and Claude (3).
3. Talk to Claude. Inside nvim use `<leader>at`; for the Claude in window 3,
   select lines, `<leader>ay`, `prefix + 3`, paste.
4. `<leader>zd` — review the whole diff. `Enter` jumps into the file, `C-o` back.
5. `prefix + w`, `m` — merge and clean up. `detach-on-destroy off` drops you into
   another session instead of the shell.

While step 3 runs, go back to step 1 and start another ticket.

## Where things live

| Piece                     | Path                                                  |
|---------------------------|-------------------------------------------------------|
| sessionizer script        | `~/.dotfiles/tmux/scripts/tmux-sessionizer.sh` → `~/scripts/tms` |
| workmux helper popups     | `~/.dotfiles/tmux/scripts/workmux-*.sh` → `~/.config/tmux/` |
| tmux bindings             | `~/.dotfiles/tmux/.tmux.conf`, after the `bind r` reload line |
| sessionizer search paths  | `~/.zshenv` (`TMUX_SESSIONIZER_PATHS`, `TMUX_SESSIONIZER_EXTRA`) |
| workmux global config     | `~/.dotfiles/workmux/.config/workmux/config.yaml` (stowed to `~/.config/workmux`) |
| per-repo config           | `<repo>/.workmux.yaml` (ignored via `.git/info/exclude`) |
| worktrees on disk         | `~/.worktrees/<project>/<branch>/`                    |
| `<leader>ay` keymap       | `lua/config/keymaps.lua` (bottom)                     |
| Claude status hooks       | `workmux-status` plugin in `~/.claude/settings.json`  |

Global config: `mode: session`, sessions named `{project}/branch`, worktrees
outside `~/projects` so they never appear as bogus repos in the picker.

## Branching and merging

- **`base_branch: auto`** (global): new worktrees branch from the repo's main
  branch, not from whatever is checked out in the main repo. Override per call
  with `workmux add <name> --base <ref>`.
- **`main_branch`**: the branch `m` merges into, and what `base_branch: auto`
  resolves to. Default is auto-detected from the remote HEAD, falling back to
  `main` / `master`. For a repo that ships from `develop`, set
  `main_branch: develop` in its `.workmux.yaml`. One-off:
  `workmux merge <branch> --into develop`.
- `m` does a plain merge and then deletes worktree, session and branch.
  `workmux merge --squash` or `--rebase` for other shapes, `--keep` to merge
  without cleanup.

## Adding a repo

```sh
cd ~/projects/<repo>
workmux init            # scaffolds .workmux.yaml
echo .workmux.yaml >> .git/info/exclude
```

Minimum useful `.workmux.yaml`:

```yaml
files:
  copy: [.env, .env.local]     # each worktree may want its own values
  symlink: [node_modules]      # one dependency tree, not one per branch
post_create:
  - pnpm install --prefer-offline
```

Added a file to `copy` later? `workmux sync-files` back-fills open worktrees.

## Gotchas

- **Empty picker** after editing `.zshenv`: the tmux server caches its
  environment. `tmux kill-server`, let continuum restore.
- **Symlinked `node_modules`** is shared. If a branch changes `package.json`,
  switch that repo's config to `copy` for `node_modules`.
- **Dev servers on fixed ports** collide across worktrees (allobase-frontend
  binds 3000/3001). The server window is left empty; start it by hand.
- **Ghost sessions**: tmux-resurrect may restore a `repo/branch` session whose
  folder was deleted on merge. `tmux kill-session -t repo/branch`. If it becomes
  a nuisance, add the `@resurrect-hook-pre-save-all` hook that kills sessions
  containing `/` before each save.
- **`C-l` in the agent pane** moves tmux panes (smart-splits), it does not clear
  Claude's screen.
- **Two worktree systems**: Claude Code has its own `worktree` setting. Treat
  `workmux list` as the source of truth and leave the native one unused.
- **Env vars** exported only in `.zshrc` do not reach worktree sessions; put
  them in `.zshenv`.
- **`workmux setup`** needs a real TTY and fails from Claude Code. The plugin
  route does the same job: `claude plugin marketplace add raine/workmux` then
  `claude plugin install workmux-status`.

## Backing out

`brew uninstall workmux`, delete `~/.config/workmux/config.yaml` and any
`.workmux.yaml`, remove the `bind o` / `bind w` blocks and the `<leader>ay`
function, `claude plugin uninstall workmux-status`. Leftover worktrees are plain
git: `git worktree remove <path>`.

Source: Sam Natale, "My 2026 Developer Workflow: Terminal + AI" and
"Tmux is Still Better Than Herdr", adapted to this machine's config.
