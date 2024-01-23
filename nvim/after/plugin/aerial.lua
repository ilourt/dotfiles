require('aerial').setup({

})

print('in aerial')
vim.keymap.set("n", "<leader>o", "<cmd>AerialToggle! right<CR>")
