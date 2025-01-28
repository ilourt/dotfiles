local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>fo', builtin.lsp_document_symbols, {})
-- vim.keymap.set('n', '<leader>ss', function()
-- 	builtin.grep_string({ search  = vim.fn.input("Search > ") });
-- end)
vim.keymap.set('n', '<leader>ss', ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>", {})
