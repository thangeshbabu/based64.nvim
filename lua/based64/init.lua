local M = {}

local function get_visually_selected_string(start_row, start_col, end_row, end_col)

    local selected_text = table.concat(vim.api.nvim_buf_get_text(0, start_row-1, start_col-1, end_row-1, end_col, {}), "\n")

    return selected_text

end

local function base64(str,action)

    local command =""

    if action == "encode" then
        command = "base64"
    elseif action == "decode" then
        command = "base64 -d"
    end

    local handle = io.popen("<<< '" .. str .. "' " .. command)
    local result = string.gsub(handle:read("*a"), "\n", "")
    handle:close()

    return result

end


local function executer(action)

       local start_row = vim.fn.line "v"
       local start_col = vim.fn.col "v"
       local _, end_row, end_col = unpack(vim.fn.getcurpos())

        -- multiline selection is not allowed, because there is no multiple line base64.
        if start_row ~= end_row then 
            print("Multiline Visual Selection is not allowed.")
            return
        end 


        -- swap start and end if start is greater than end
        if start_col > end_col then 

            tmp=start_col
            start_col=end_col
            end_col=tmp

        end
        

        local selected_text=get_visually_selected_string(start_row, start_col, end_row, end_col)
        local result = base64(selected_text,action)

       -- Replace the selected text with the result
       vim.api.nvim_buf_set_text(0, start_row-1, start_col-1, end_row-1, end_col, {result})

        -- Move the cursor to the start of the selection 
       vim.api.nvim_win_set_cursor(0, {start_row, start_col-1})

       -- go to normal mode
        vim.api.nvim_input('<Esc>')

       -- hello aGVsbG8K aGVsbG8K
end

function M.encode()
    executer("encode")
end

function M.decode()
    executer("decode")
end

return M

