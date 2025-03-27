return {
  "folke/which-key.nvim",
  opts = {
    spec = {
      { "<leader>w", desc = "Save files" },
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
      {
        "<leader>W",
        group = "windows",
        proxy = "<c-w>",
        expand = function()
          return require("which-key.extras").expand.win()
        end,
      },
    },
  },
}
