-- zdiff.nvim rewrites the whole buffer on every redraw; under the global
-- foldmethod = "indent" that trips E351 ("Cannot delete fold with current
-- 'foldmethod'") because deleting the old lines requires manual fold deletion.
vim.opt_local.foldmethod = "manual"
