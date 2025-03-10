return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  init = function()
    vim.g.lualine_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      -- set an empty statusline till lualine loads
      vim.o.statusline = " "
    else
      -- hide the statusline on the starter page
      vim.o.laststatus = 0
    end
  end,
  opts = function()
    -- PERF: we don't need this lualine require madness 🤷
    local lualine_require = require("lualine_require")
    lualine_require.require = require
    local icons = LazyVim.config.icons

    vim.o.laststatus = vim.g.lualine_laststatus
    local opts = {
      options = {
        theme = "auto",
        component_separators = "",
        section_separators = "",
        globalstatus = vim.o.laststatus == 1,
        disabled_filetypes = {
          statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" },
          winbar = { "dashboard", "alpha", "ministarter", "snacks_dashboard" },
        },
      },
      sections = {
        lualine_a = {
          {
            function()
              local mode = vim.api.nvim_get_mode()["mode"]
              return "" .. string.format("%-1s", mode)
            end,
          },
        },
        lualine_b = {},
        lualine_c = {
          {
            function()
              local root = vim.fn.getcwd()
              return "󱉭 " .. vim.fs.basename(root)
            end,
            color = { fg = Snacks.util.color("Special") },
          },
          -- stylua: ignore
          ---@diagnostic disable-next-line: assign-type-mismatch
          LazyVim.lualine.root_dir({ icon = ">" }),
          Snacks.profiler.status(),
          {
            function()
              return require("noice").api.status.mode.get()
            end,
            cond = function()
              return package.loaded["noice"] and require("noice").api.status.mode.has()
            end,
            color = function()
              return { fg = Snacks.util.color("Constant") }
            end,
          },
          -- stylua: ignore
          {
            function() return "  " .. require("dap").status() end,
            cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
            color = function() return { fg = Snacks.util.color("Debug") } end,
          },
          -- stylua: ignore
          {
            require("lazy.status").updates,
            cond = require("lazy.status").has_updates,
            color = function() return { fg = Snacks.util.color("Special") } end,
          },
          {
            "diagnostics",
            symbols = {
              error = icons.diagnostics.Error,
              warn = icons.diagnostics.Warn,
              info = icons.diagnostics.Info,
              hint = icons.diagnostics.Hint,
            },
          },
          { "%=" },
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          {
            "filename",
            file_status = true,
            newfile_status = true,
            color = { fg = Snacks.util.color("Special"), gui = "BOLD" },
          },
        },

        lualine_x = {
          {
            "diff",
            symbols = {
              added = icons.git.added,
              modified = icons.git.modified,
              removed = icons.git.removed,
            },
            source = function()
              local gitsigns = vim.b.gitsigns_status_dict
              if gitsigns then
                return {
                  added = gitsigns.added,
                  modified = gitsigns.changed,
                  removed = gitsigns.removed,
                }
              end
            end,
          },
          { "branch", color = { fg = Snacks.util.color("Special") } },
        },

        lualine_y = {},
        lualine_z = {
          function()
            local mode = vim.api.nvim_get_mode()["mode"]
            return "" .. string.format("%-1s", mode)
          end,
        },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
          { "%=" },
          {
            "filename",
            file_status = true,
            newfile_status = true,
            color = { fg = Snacks.util.color("Normal"), gui = "italic" },
          },
        },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
      extensions = { "lazy", "fzf" },
    }

    return opts
  end,
}
