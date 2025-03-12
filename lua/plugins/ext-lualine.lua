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

    local mode_width = 0
    local root_width = 0
    local cwd_width = 0
    local profiler_width = 0
    local noice_width = 0
    local dap_width = 0
    local lazy_width = 0
    local diagnostic_width = 0
    local filetype_width = 0
    local filename_width = 0
    local noice_name = ""

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
            fmt = function(str)
              local eval_str = vim.api.nvim_eval_statusline(str, {}).str
              mode_width = #eval_str
              return str
            end,
          },
        },
        lualine_b = {},
        lualine_c = {
          {
            function()
              local cwd = vim.fn.getcwd()
              return "󱉭 " .. vim.fs.basename(cwd)
            end,
            color = { fg = Snacks.util.color("Special") },
            fmt = function(str)
              if str == "" then
                cwd_width = 0
                return str
              end
              local eval_str = vim.api.nvim_eval_statusline(str, {}).str
              cwd_width = #eval_str
              return str
            end,
          },
          -- stylua: ignore
          ---@diagnostic disable-next-line: assign-type-mismatch
          {
            function()
              return LazyVim.lualine.root_dir({ icon = ">" })[1]()
            end,
            color = { fg = Snacks.util.color("Special") }, -- Optional: Customize the appearance
            padding = {left = 0, right = 0},
            fmt = function (str)
              if str == "" then
                root_width = 0
                return str
              end
               local eval_str = vim.api.nvim_eval_statusline(str, {}).str
              root_width = #eval_str
              return str

            end
          },
          {
            function()
              return Snacks.profiler.status()[1]()
            end,
            color = "DiagnosticError",
            cond = function()
              return require("snacks.profiler").core.running
            end,
            fmt = function(str)
              if str == "" then
                profiler_width = 0
                return str
              end
              local eval_str = vim.api.nvim_eval_statusline(str, {}).str
              profiler_width = #eval_str
              return str
            end,
          },
          -- {
          --   function()
          --     return require("noice").api.status.mode.get()
          --   end,
          --   cond = function()
          --     return package.loaded["noice"] and require("noice").api.status.mode.has()
          --   end,
          --   color = function()
          --     return { fg = Snacks.util.color("Constant") }
          --   end,
          --   fmt = function(str)
          --     noice_name = str
          --     if str == nil then
          --       noice_width = 0
          --       return str
          --     end
          --     local eval_str = vim.api.nvim_eval_statusline(str, {}).str
          --     noice_width = #eval_str
          --     return str
          --   end,
          -- },
          {
            function()
              local reg = vim.fn.reg_recording()
              if reg == "" then
                return ""
              end -- not recording
              return " recording to @" .. reg
            end,
            padding = { left = 0, right = 0 },
            color = function()
              return { fg = Snacks.util.color("Constant") }
            end,
            fmt = function(str)
              if str == nil then
                noice_width = 0
                return str
              end
              local eval_str = vim.api.nvim_eval_statusline(str, {}).str
              noice_width = #eval_str
              return str
            end,
          },
          {
            function()
              return "  " .. require("dap").status()
            end,
            cond = function()
              return package.loaded["dap"] and require("dap").status() ~= ""
            end,
            color = function()
              return { fg = Snacks.util.color("Debug") }
            end,
            fmt = function(str)
              if str == "" then
                dap_width = 0
                return str
              end
              local eval_str = vim.api.nvim_eval_statusline(str, {}).str
              dap_width = #eval_str
              return str
            end,
          },
          {
            require("lazy.status").updates,
            cond = require("lazy.status").has_updates,
            color = function()
              return { fg = Snacks.util.color("Special") }
            end,
            fmt = function(str)
              if str == "" then
                lazy_width = 0
                return str
              end
              local eval_str = vim.api.nvim_eval_statusline(str, {}).str
              lazy_width = #eval_str
              return str
            end,
          },
          {
            "diagnostics",
            symbols = {
              error = icons.diagnostics.Error,
              warn = icons.diagnostics.Warn,
              info = icons.diagnostics.Info,
              hint = icons.diagnostics.Hint,
            },
            fmt = function(str)
              if str == "" then
                diagnostic_width = 0
                return str
              end
              local eval_str = vim.api.nvim_eval_statusline(str, {}).str
              diagnostic_width = #eval_str
              return str
            end,
          },
          {
            function()
              local used_space = mode_width
                + root_width
                + cwd_width
                + profiler_width
                + noice_width
                + lazy_width
                + dap_width
                + diagnostic_width
              local term_width = vim.opt.columns:get()
              local fill_space =
                string.rep(" ", math.floor((term_width - filename_width - filetype_width) / 2) - used_space)
              return fill_space
            end,
            padding = { left = 0, right = 0 },
          },
          {
            "filetype",
            icon_only = true,
            separator = "",
            padding = { left = 0, right = 0 },
            fmt = function(str)
              if str == "" then
                filetype_width = 0
                return str
              end
              local eval_str = vim.api.nvim_eval_statusline(str, {}).str
              filetype_width = #eval_str
              return str
            end,
          },
          {
            "filename",
            file_status = true,
            newfile_status = true,
            color = { fg = Snacks.util.color("Special"), gui = "BOLD" },
            padding = { left = 0, right = 0 },
            fmt = function(str)
              if str == "" then
                filename_width = 0
                return str
              end
              local eval_str = vim.api.nvim_eval_statusline(str, {}).str
              filename_width = #eval_str
              return str
            end,
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
