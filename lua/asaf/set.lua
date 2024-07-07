-- Hybrid line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Tabs/Spaces
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"json", "typescriptreact"},
  callback = function()
    vim.opt.tabstop = 2
    vim.opt.softtabstop = 2
    vim.opt.shiftwidth = 2
  end
})

-- Search highlighting
vim.api.nvim_set_keymap('n', '<Esc>', ':nohlsearch<CR>', {noremap = true, silent = true })
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Search casing
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Boundary
vim.opt.wrap = false
vim.opt.colorcolumn = "100"

-- Clipboard
vim.opt.clipboard:append("unnamedplus")

-- Cursor update time 
vim.opt.updatetime = 100

-- Razor support
vim.api.nvim_create_autocmd("FileType", {
    pattern = "razor",
    callback = function()
        vim.cmd("runtime syntax/razor.vim") -- Ensure the syntax is loaded for Razor files
    end,
})

-- JQ command (thanks ChatGPT!)
vim.api.nvim_create_user_command('FormatJson', function()
    local old_lines = vim.api.nvim_buf_get_lines(0, vim.fn.line("'<")-1, vim.fn.line("'>"), false)
    local json_text = table.concat(old_lines, "\n")
    local formatted_json = vim.fn.system('jq .', json_text)

    if vim.v.shell_error == 0 then
        vim.api.nvim_buf_set_lines(0, vim.fn.line("'<")-1, vim.fn.line("'>"), false, vim.split(formatted_json, "\n"))
    else
        print("Error formatting JSON")
    end
end, {range = true})
vim.api.nvim_set_keymap('v', '<leader>jq',[[:FormatJson<CR>]], {noremap = true, silent = true})
