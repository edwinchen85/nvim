return {
    "dominic-righthere/markdown-pipetable.nvim",
    ft = { "markdown" },
    cmd = { "Pipetable" },
    -- Repo name doesn't match the module name, so lazy can't infer it for `opts`.
    main = "pipetable",
    -- render-markdown's `pipe_table` is disabled to match -- both on stacks two
    -- sets of borders and they fight over `concealcursor`.
    -- `format_on_edit` repads the table source on commit; without it the raw
    -- text stays ragged even though the overlay renders aligned, which shows up
    -- in diffs and anywhere the file is read outside Neovim.
    opts = { format_on_edit = true },
}
