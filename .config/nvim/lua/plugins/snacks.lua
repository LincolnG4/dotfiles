return {
  "folke/snacks.nvim",
  opts = {
    notifier = { enabled = true },
    picker = {
      hidden = true, -- show hidden files globally
      ignored = true, -- respect .gitignore

      matcher = {
        ignore_patterns = { "%.git/", "%.bruno/" }, -- always ignore these
      },

      sources = {
        explorer = {
          hidden = true, -- show dotfiles
          ignored = true, -- respect .gitignore
          auto_close = true,
        },
        files = {
          hidden = true,
          ignored = true,
        },
        grep = {
          hidden = true,
          ignored = true,
        },
      },
    },
  },

  init = function()
    -- prevent Snacks explorer from opening automatically
    vim.g.snacks_explorer_auto_open = false
  end,
}
