local h_status_ok, leap = pcall(require, "leap")
if not h_status_ok then
    return
end

leap.set_default_keymaps()
