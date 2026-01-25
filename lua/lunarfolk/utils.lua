local M = {}

function M.is_codediff_buffer()
    local buf_name = vim.api.nvim_buf_get_name(0)
    return buf_name:match("codediff:") ~= nil
end

function M.is_in_codediff_tab()
    -- Check if any window in the current tab has a codediff buffer
    local wins = vim.api.nvim_tabpage_list_wins(0)
    for _, win in ipairs(wins) do
        local buf = vim.api.nvim_win_get_buf(win)
        local buf_name = vim.api.nvim_buf_get_name(buf)
        if buf_name:match("codediff:") ~= nil then
            return true
        end
    end
    return false
end

return M