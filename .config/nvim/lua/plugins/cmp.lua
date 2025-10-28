return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        ["<CR>"] = { "fallback" }, -- make Enter insert a newline instead of confirming
        ["<Tab>"] = { "accept" }, -- optional: use Tab to confirm
      },
    },
  },
}
