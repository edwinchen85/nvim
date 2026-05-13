# Git knowledge base

## Git diff: two-dot vs three-dot

git diff a..b (two dots)

- Direct comparison between commit a and commit b
- Answers: "What changes turn a's tree into b's tree?"
- Commits unique to a appear as deletions in the output
- Equivalent to git diff a b

git diff a...b (three dots)

- Compares the merge base of a and b to b
- Answers: "What's new on b since it diverged from a?"
- Ignores commits made on a after the fork point
- Equivalent to git diff $(git merge-base a b) b

Common use case

- git diff main...feature → reviews only the feature branch's changes, unaffected by new commits on main
- This is what GitHub/GitLab pull request diffs show

Quick mental model

- Two dots: endpoint-to-endpoint
- Three dots: fork-point-to-endpoint (for diff)
