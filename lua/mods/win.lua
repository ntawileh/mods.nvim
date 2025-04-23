local M = {}

---@param opts snacks.win.Config: The options for the window
M.create_floating_window = function(opts)
    opts = opts or {}
    opts.text = opts.text or ""
    return Snacks.win({
        show = true,
        enter = true,
        position = opts.position or "float",
        col = opts.col,
        row = opts.row,
        backdrop = 35,
        height = opts.height or 0.7,
        width = opts.width or 0.7,
        zindex = 50,
        border = opts.border or "double",
        ft = "markdown",
        footer = opts.footer or "",
        bo = opts.bo or {
            filetype = "markdown",
            modifiable = false,
        },
        wo = {
            wrap = true,
            spell = false,
        },
        text = opts.text,
        title = opts.title or "",
        title_pos = "center",
        footer_pos = opts.footer_pos or "left",
        fixbuf = true,
        keys = opts.keys or {},
        actions = opts.actions or {},
    })
end

---@param buf number: The buffer to set the content
---@param lines string[]: The lines to set
M.set_window_content = function(buf, lines)
    vim.bo[buf].modifiable = true
    vim.bo[buf].readonly = false
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    vim.bo[buf].readonly = true
end

return M
