return {
  {
    "vague-theme/vague.nvim",
    priority = 1000, -- load before other plugins
    config = function()
      require("vague").setup({
        -- optional custom settings
      })

      vim.cmd.colorscheme("vague")
    end,
  },
}
