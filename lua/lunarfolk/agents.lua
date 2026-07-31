local M = {}

M.agents = {
    codex = { cmd = "codex" },
    opencode = { cmd = "opencode" },
    pi = { cmd = "pi" },
}

local state = {}
for name, agent in pairs(M.agents) do
    state[name] = {
        bufnr = nil,
        cmd = agent.cmd,
    }
end

local function get_agent(name)
    local agent = state[name]
    if not agent then
        error("Unknown agent: " .. tostring(name))
    end
    return agent
end

local function get_job_id(name)
    local agent = get_agent(name)
    if not (agent.bufnr and vim.api.nvim_buf_is_valid(agent.bufnr)) then
        return nil
    end

    local job_id = vim.b[agent.bufnr].terminal_job_id
    if type(job_id) ~= "number" or job_id <= 0 then
        return nil
    end

    return job_id
end

local function get_visual_selection()
    local visual_pos = vim.fn.getpos("v")
    local cursor_pos = vim.fn.getpos(".")
    local mode = vim.fn.visualmode()

    local start_line = visual_pos[2]
    local start_col = visual_pos[3]
    local end_line = cursor_pos[2]
    local end_col = cursor_pos[3]

    if start_line > end_line or (start_line == end_line and start_col > end_col) then
        start_line, end_line = end_line, start_line
        start_col, end_col = end_col, start_col
    end

    local lines
    if mode == "V" then
        lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    else
        lines = vim.api.nvim_buf_get_text(0, start_line - 1, start_col - 1, end_line - 1, end_col, {})
    end

    return {
        lines = lines,
        start_line = start_line,
        end_line = end_line,
        filepath = vim.fn.expand("%:p"),
        filetype = vim.bo.filetype ~= "" and vim.bo.filetype or "text",
    }
end

local function format_selection_context(selection)
    return table.concat({
        "From file: " .. selection.filepath,
        "Lines: " .. selection.start_line .. "-" .. selection.end_line,
        "",
        "```" .. selection.filetype,
        table.concat(selection.lines, "\n"),
        "```",
        "",
    }, "\n")
end

function M.focus(name)
    local agent = get_agent(name)
    if not (agent.bufnr and vim.api.nvim_buf_is_valid(agent.bufnr)) then
        return
    end

    local winid = vim.fn.bufwinid(agent.bufnr)
    if winid == -1 then
        vim.cmd("rightbelow vsplit")
        vim.api.nvim_win_set_buf(0, agent.bufnr)
    else
        vim.api.nvim_set_current_win(winid)
    end

    vim.cmd("startinsert")
end

function M.toggle(name)
    local agent = get_agent(name)
    if agent.bufnr and vim.api.nvim_buf_is_valid(agent.bufnr) then
        local winid = vim.fn.bufwinid(agent.bufnr)
        if winid ~= -1 then
            vim.api.nvim_win_close(winid, true)
            return
        end

        vim.cmd("rightbelow vsplit")
        vim.api.nvim_win_set_buf(0, agent.bufnr)
        return
    end

    vim.cmd("rightbelow vsplit")
    vim.cmd("terminal " .. agent.cmd)
    agent.bufnr = vim.api.nvim_get_current_buf()
end

function M.send_selection(name)
    local job_id = get_job_id(name)
    if not job_id then
        vim.notify(name .. " agent is not running", vim.log.levels.ERROR)
        return
    end

    local selection = get_visual_selection()
    if not selection.lines or vim.tbl_isempty(selection.lines) then
        vim.notify("No visual selection found", vim.log.levels.WARN)
        return
    end

    local payload = format_selection_context(selection)
    vim.api.nvim_chan_send(job_id, "\x1b[200~" .. payload .. "\x1b[201~")
    M.focus(name)
end

return M
