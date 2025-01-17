local M = {}

---@class mods.Prompt
---@field name string
---@field prompt string
---@field role string | nil

---@class mods.State
---@field file_name string
---@field window snacks.win | {}
---@field context string[]
---@field response string[]
---@field prompt mods.Prompt
---@field loading boolean

---@class mods.Options
---@field prompts mods.Prompt[]

---@type mods.Prompt[]
local prompts = require("mods.prompts").prompts

---@type mods.State
local state = {
    file_name = "",
    window = {},
    context = {},
    response = {},
    prompt = prompts[1],
    loading = false,
}

---@param opts mods.Options
M.setup = function(opts)
    opts = opts or {}
    opts.prompts = opts.prompts or {}
    vim.list_extend(prompts, opts.prompts)
end

---Sanitize lines for rendering.
---Replace newlines with literal \n
---@private
---@param lines string[]
---@return string[]
local function sanitize_lines(lines)
    return vim.tbl_map(
        ---@param line string
        function(line)
            return line and line:gsub("\n", "\\n") or ""
        end,
        lines
    )
end

---@param buf number: The buffer to set the content
---@param lines string[]: The lines to set
local function set_window_content(buf, lines)
    vim.bo[buf].modifiable = true
    vim.bo[buf].readonly = false
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, sanitize_lines(lines))
    vim.bo[buf].modifiable = false
    vim.bo[buf].readonly = true
end

local reset_state = function()
    state = {
        file_name = "",
        context = {},
        response = {},
        prompt = prompts[1],
        window = {},
        loading = false,
    }
end

local function mods_keymap(mode, key, callback)
    vim.keymap.set(mode, key, callback, {
        buffer = state.window.buf,
    })
end

local function make_prompt_content()
    local lines = {}
    local prompt = vim.split(state.prompt.prompt, "\n")
    table.insert(lines, "# Prompt")
    vim.list_extend(lines, prompt)
    table.insert(lines, "")

    if state.prompt.role then
        table.insert(lines, "# Mods Role")
        table.insert(lines, state.prompt.role)
        table.insert(lines, "")
    end

    table.insert(lines, "# Context")
    table.insert(lines, "")
    table.insert(lines, "```")
    vim.list_extend(lines, state.context)
    table.insert(lines, "```")
    return lines
end

local function setup_keymaps()
    mods_keymap("n", "p", function()
        vim.schedule(function()
            if state.loading then
                return
            end
            state.window.opts.footer = "(r) show response, (q) close"
            state.window:update()
            set_window_content(state.window.buf, make_prompt_content())
        end)
    end)

    mods_keymap("n", "r", function()
        vim.schedule(function()
            if state.loading then
                return
            end
            state.window.opts.footer = "(p) show prompt, (Y) yank response, (q) close"
            state.window:update()
            set_window_content(state.window.buf, state.response)
        end)
    end)

    mods_keymap("n", "Y", function()
        vim.schedule(function()
            if state.loading then
                return
            end

            vim.api.nvim_input("<Esc>ggVGy")
        end)
    end)
end
local function execute_mods(opts)
    opts = opts or { prompt = state.prompt, context = state.context }
    if not opts.prompt then
        return
    end
    opts.context = opts.context or {}
    local win = require("mods.win")
    local command = { "mods", "-f", "-c", "nvim:mods " .. state.file_name }

    if opts.prompt.role then
        vim.list_extend(command, { "--role", opts.prompt.role })
    end

    table.insert(command, opts.prompt.prompt)
    local output = {
        "## Asking AI, please wait...",
        "```",
        "",
    }
    vim.list_extend(output, opts.context)
    table.insert(output, "```")

    state.window = win.create_floating_window({
        text = output,
        footer = "(q) abort/close",
    })
    local on_exit = function(obj)
        vim.schedule(function()
            state.loading = false
            if not state.window:win_valid() then
                return
            end
            state.response = vim.split(obj.stdout, "\n")
            set_window_content(state.window.buf, state.response)
            state.window.opts.footer = "(p) show prompt, (Y) yank, (q) close"
            state.window:update()
            setup_keymaps()
        end)
    end
    vim.system(command, { text = true, stdin = opts.context }, on_exit)
    state.loading = true
end

local function get_visual_selection()
    ---@type {[number]: {startcol:integer, endcol:integer}}
    local region = vim.region(0, "'<", "'>", vim.fn.visualmode(), true)
    ---@type string[]
    local lines = {}
    local maxcol = vim.v.maxcol
    for line, cols in vim.spairs(region) do
        local endcol = cols[2] == maxcol and -1 or cols[2]
        local chunk = vim.api.nvim_buf_get_text(0, line, cols[1], line, endcol, {})[1]
        lines[#lines + 1] = chunk
    end
    return lines
end

---@class mods.QueryOptions
---@field bufnr number|nil: The buffer to query on.  Defaults to current buffer
---@field exclude_context boolean|nil: If true, no content from the buffer will be passed in the prompt

---@param opts mods.QueryOptions
M.query = function(opts)
    opts = opts or {}
    opts.bufnr = opts.bufnr or 0
    opts.exclude_context = opts.exclude_context or false
    local mode = vim.api.nvim_get_mode().mode
    local lines = {}
    local select_options = {}
    reset_state()

    local custom_query = function()
        vim.ui.input({
            prompt = "Enter the prompt to use for the code selection",
            enabled = true,
        }, function(value)
            if not value or value == "" then
                return
            end
            state.prompt = {
                name = "custom",
                prompt = value,
            }
            execute_mods()
        end)
    end

    if not opts.exclude_context then
        if mode == "v" or mode == "V" then
            -- vim.fn.feedkeys(":", "nx")
            -- vim.api.nvim_input("<Esc>")
            vim.fn.feedkeys(mode, "nx")
            -- vim.api.nvim_input("")
            lines = get_visual_selection()
        else
            lines = vim.api.nvim_buf_get_lines(opts.bufnr, 0, -1, false)
        end

        vim.list_extend(select_options, prompts)
        table.insert(select_options, {
            prompt = "__custom",
            name = "Type my own",
        })
    end

    state.file_name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(opts.bufnr), ":p")
    state.context = lines

    if opts.exclude_context then
        custom_query()
        return
    end

    vim.ui.select(select_options, {
        prompt = "Select prompt: ",
        format_item = function(p)
            return p.name
        end,
    }, function(selection)
        if selection == nil then
            return
        end
        if selection.prompt == "__custom" then
            custom_query()
            return
        end
        state.prompt = selection
        execute_mods()
    end)
end

-- testing
-- M.setup({
--     prompts = {
--         {
--             name = "Caveman",
--             prompt = "Explain the following code snippet to a caveman",
--         },
--     },
-- })
-- M.query({ exclude_context = true })
-- M.query()
--
-- vim.keymap.set("v", "<leader>aa", function()
--     M.query()
-- end)

return M
