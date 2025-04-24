local M = {}

M.check = function()
    local health = vim.health
    health.start("mods.nvim")
    local ok = pcall(require, "mods")
    if not ok then
        health.error("mods.nvim not found")
        return
    end

    local result = vim.system({ "mods", "--version" }, { text = true }):wait()
    if result.code ~= 0 then
        health.error("Could not run mods.  Is mods installed correctly?")
        return
    end

    local query = "say hello world"
    result = vim.system({ "mods", "-f", query }, { text = true }):wait()
    if result.code ~= 0 then
        health.error("Could not query AI using mods.  Is mods configured correctly?")
        return
    end
    if not string.find(string.lower(result.stdout), "hello") then
        health.error(
            "Unexpected response from mods.  Is mods configured correctly? Query: "
                .. query
                .. " Response: "
                .. result.stdout
        )
        return
    end

    health.ok("mods.nvim setup is ok")
end

--M.check()

return M
