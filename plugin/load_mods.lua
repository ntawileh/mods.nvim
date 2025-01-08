vim.api.nvim_create_user_command("Mods", function()
    require("mods").query()
end, {
    desc = "Mods AI query",
})
