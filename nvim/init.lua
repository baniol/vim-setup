-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Basic options
vim.opt.number = true         -- line numbers
vim.opt.relativenumber = true -- relative line numbers
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.clipboard = "unnamedplus"

vim.g.mapleader = " "  -- Space as leader key

-- Close quickfix/loclist from anywhere
vim.keymap.set("n", "<leader>q", ":cclose<CR>:lclose<CR>", { desc = "Close quickfix/loclist" })

-- Copy absolute file path to system clipboard
vim.keymap.set("n", "<leader>cp", function() vim.fn.setreg("+", vim.fn.expand("%:p")) end, { desc = "Copy file path" })

-- Open terminal in bottom split
vim.keymap.set("n", "<leader>sh", function()
  vim.cmd("belowright split | resize 15 | terminal")
  vim.cmd("startinsert")
end, { desc = "Open terminal in bottom split" })

-- Exit terminal mode with double Esc; single Esc passes through to the running app (e.g. Claude Code)
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- Auto-close terminal window when the shell exits cleanly
vim.api.nvim_create_autocmd("TermClose", {
  callback = function(args)
    if vim.v.event.status ~= 0 then return end
    vim.schedule(function()
      for _, win in ipairs(vim.fn.win_findbuf(args.buf)) do
        if vim.api.nvim_win_is_valid(win) then
          pcall(vim.api.nvim_win_close, win, true)
        end
      end
      if vim.api.nvim_buf_is_valid(args.buf) then
        pcall(vim.api.nvim_buf_delete, args.buf, { force = true })
      end
    end)
  end,
})

-- rustaceanvim: must be set before lazy loads the plugin
vim.g.rustaceanvim = {
  server = {
    settings = {
      ["rust-analyzer"] = {
        standalone = true,  -- allows single .rs files without Cargo.toml
      },
    },
  },
}

-- Theme switcher (nvim + Ghostty in sync)
local THEME_MAP = {
  ["tokyonight-night"]     = "TokyoNight Night",
  ["tokyonight-storm"]     = "TokyoNight Storm",
  ["tokyonight-moon"]      = "TokyoNight Moon",
  ["tokyonight-day"]       = "TokyoNight Day",
  ["catppuccin-mocha"]     = "Catppuccin Mocha",
  ["catppuccin-latte"]     = "Catppuccin Latte",
  ["catppuccin-frappe"]    = "Catppuccin Frappe",
  ["catppuccin-macchiato"] = "Catppuccin Macchiato",
  ["kanagawa"]             = "Kanagawa Wave",
  ["kanagawa-dragon"]      = "Kanagawa Dragon",
  ["kanagawa-lotus"]       = "Kanagawa Lotus",
  ["rose-pine"]            = "Rose Pine",
  ["rose-pine-moon"]       = "Rose Pine Moon",
  ["rose-pine-dawn"]       = "Rose Pine Dawn",
  ["gruvbox-material"]     = "Gruvbox Material",
  ["nightfox"]             = "Nightfox",
  ["dayfox"]               = "Dayfox",
  ["carbonfox"]            = "Carbonfox",
  ["nordfox"]              = "Nordfox",
}

local function apply_theme(nvim_name)
  local ghostty_name = THEME_MAP[nvim_name]
  if not ghostty_name then return end
  vim.cmd("colorscheme " .. nvim_name)
  local cfg = vim.fn.expand("~/.config/ghostty/config")
  vim.fn.system({ "sed", "-i", "", "s/^theme = .*/theme = " .. ghostty_name .. "/", cfg })
  vim.fn.jobstart({ "ghostty", "+reload-config" }, { detach = true })
end

vim.keymap.set("n", "<leader>ft", function()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf    = require("telescope.config").values
  local actions = require("telescope.actions")
  local state   = require("telescope.actions.state")

  local names = vim.tbl_keys(THEME_MAP)
  table.sort(names)
  local original = vim.g.colors_name

  pickers.new({}, {
    prompt_title = "Themes",
    finder       = finders.new_table({ results = names }),
    sorter       = conf.generic_sorter({}),
    previewer    = false,
    attach_mappings = function(buf, map)
      vim.api.nvim_create_autocmd("CursorMoved", {
        buffer = buf,
        callback = function()
          local entry = state.get_selected_entry()
          if entry then pcall(vim.cmd, "colorscheme " .. entry.value) end
        end,
      })
      actions.select_default:replace(function()
        local entry = state.get_selected_entry()
        actions.close(buf)
        if entry then apply_theme(entry.value) end
      end)
      map({ "i", "n" }, "<Esc>", function()
        actions.close(buf)
        if original then pcall(vim.cmd, "colorscheme " .. original) end
      end)
      return true
    end,
  }):find()
end, { desc = "Pick theme (nvim + Ghostty)" })

-- Plugins
require("lazy").setup({
  -- Colorschemes (switch live with :Telescope colorscheme)
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("colorscheme tokyonight-night")
    end,
  },
  { "catppuccin/nvim", name = "catppuccin" },
  { "rebelot/kanagawa.nvim" },
  { "EdenEast/nightfox.nvim" },
  { "rose-pine/neovim", name = "rose-pine" },
  { "sainnhe/gruvbox-material" },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { theme = "tokyonight" },
        tabline = {
          lualine_a = { { "tabs", mode = 2, max_length = vim.o.columns } },
        },
      })
    end,
  },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 50 },
        sync_root_with_cwd = true,
        respect_buf_cwd = true,
        update_focused_file = {
          enable = true,
          update_root = false,
        },
        actions = {
          open_file = {
            quit_on_open = false,
          },
          change_dir = {
            global = false,
          },
        },
      })
      vim.keymap.set("n", "<leader>t",  ":NvimTreeToggle<CR>",   { desc = "Toggle file tree" })
      vim.keymap.set("n", "<leader>tr", ":NvimTreeFindFile<CR>", { desc = "Reveal file in tree" })

      -- Auto-close nvim-tree if it's the last window
      vim.api.nvim_create_autocmd("QuitPre", {
        callback = function()
          local wins = vim.api.nvim_list_wins()
          local non_tree = vim.tbl_filter(function(w)
            local buf = vim.api.nvim_win_get_buf(w)
            return vim.bo[buf].filetype ~= "NvimTree"
          end, wins)
          if #non_tree == 0 then return end
          if #non_tree == 1 then
            vim.cmd("NvimTreeClose")
          end
        end,
      })
    end,
  },

  -- Keybinding hints
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup()
    end,
  },

  -- Syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = { "lua", "rust", "go", "toml", "json", "yaml", "markdown", "python" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- Auto-close brackets/quotes
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },

  -- Comment with gcc / gc
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep,  { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers,    { desc = "Buffers" })
    end,
  },

  -- LSP installer
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  -- Bridges mason <-> lspconfig, auto-installs servers
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "gopls", "lua_ls", "rust_analyzer", "pyright" },
        automatic_installation = true,
      })
    end,
  },

  -- Provides server configs in lsp/ dir (data-only, no require needed)
  -- nvim-lspconfig v3+ uses vim.lsp.config / vim.lsp.enable (Nvim 0.11+)
  {
    "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason-lspconfig.nvim", "hrsh7th/cmp-nvim-lsp" },
    config = function()
      -- Apply cmp capabilities to all servers globally
      vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })

      -- Enable servers (configs come from nvim-lspconfig's lsp/ dir)
      vim.lsp.enable({ "gopls", "lua_ls", "pyright" })

      -- Keymaps applied whenever any LSP attaches
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local opts = { buffer = args.buf }
          vim.keymap.set("n", "gd",        vim.lsp.buf.definition,                         opts)
          vim.keymap.set("n", "K",          vim.lsp.buf.hover,                              opts)
          vim.keymap.set("n", "gr",         vim.lsp.buf.references,                         opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,                             opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action,                        opts)
          vim.keymap.set("n", "<leader>f",  function() vim.lsp.buf.format({ async = true }) end, opts)
          vim.keymap.set("n", "gl",         vim.diagnostic.open_float,                      opts)
          vim.keymap.set("n", "[d",         vim.diagnostic.goto_prev,                       opts)
          vim.keymap.set("n", "]d",         vim.diagnostic.goto_next,                       opts)
        end,
      })
    end,
  },

  -- Completion engine
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")

      -- Load VSCode-style snippets (friendly-snippets)
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<Tab>"]     = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"]   = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- Rust LSP with extras (inlay hints, expand macros, debugger, etc.)
  -- mason installs rust-analyzer; rustaceanvim picks it up automatically
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    ft = { "rust" },
  },

  -- Go tooling (auto-import, test runner, struct tags, etc.)
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    ft    = { "go", "gomod" },
    build = ':lua require("go.install").update_all_sync()',
    config = function()
      require("go").setup()
    end,
  },

  -- Git diff signs in gutter + hunk actions
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        on_attach = function(bufnr)
          local gs = require("gitsigns")
          local opts = { buffer = bufnr }
          vim.keymap.set("n", "]h", gs.next_hunk,               { buffer = bufnr, desc = "Next hunk" })
          vim.keymap.set("n", "[h", gs.prev_hunk,               { buffer = bufnr, desc = "Prev hunk" })
          vim.keymap.set("n", "<leader>hs", gs.stage_hunk,      { buffer = bufnr, desc = "Stage hunk" })
          vim.keymap.set("n", "<leader>hr", gs.reset_hunk,      { buffer = bufnr, desc = "Reset hunk" })
          vim.keymap.set("n", "<leader>hp", gs.preview_hunk,    { buffer = bufnr, desc = "Preview hunk" })
          vim.keymap.set("n", "<leader>hb", gs.blame_line,      { buffer = bufnr, desc = "Blame line" })
          vim.keymap.set("n", "<leader>hd", gs.diffthis,        { buffer = bufnr, desc = "Diff this" })
        end,
      })
    end,
  },

  -- Markdown rendering in buffer (styled headings, code blocks, tables, etc.)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    config = function()
      require("render-markdown").setup()
    end,
  },

  -- Git workflow (status, commit, push, log, blame, diff, ...)
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G" },
    keys = {
      { "<leader>gs", "<cmd>Git<CR>",          desc = "Git status" },
      { "<leader>gc", "<cmd>Git commit<CR>",   desc = "Git commit" },
      { "<leader>gp", "<cmd>Git push<CR>",     desc = "Git push" },
      { "<leader>gl", "<cmd>Git log<CR>",      desc = "Git log" },
      { "<leader>gd", "<cmd>Gdiffsplit<CR>",   desc = "Git diff split" },
    },
  },

  -- AI CLI integration (Claude Code via subscription)
  {
    "folke/sidekick.nvim",
    opts = {
      nes = { enabled = false }, -- Next Edit Suggestions require Copilot; disabled
      cli = {
        watch = true, -- auto-reload buffers when the CLI edits files
        win = {
          split = { width = 110 },
        },
        tools = {
          claude = {},
        },
        prompts = {
          explain  = "Explain {this}",
          fix      = "Can you fix {this}?",
          tests    = "Can you write tests for {this}?",
          document = "Add documentation to {function|line}",
          review   = "Can you review {file} for any issues?",
          optimize = "How can {this} be optimized?",
          diag     = "Fix the diagnostics in this file: {diagnostics}",
        },
      },
    },
    keys = {
      { "<leader>ac", function() require("sidekick.cli").toggle({ name = "claude", focus = true }) end, desc = "Toggle Claude" },
      { "<leader>aa", function() require("sidekick.cli").toggle() end,                                  desc = "Toggle Sidekick CLI" },
      { "<leader>ap", function() require("sidekick.cli").prompt() end,                                  desc = "Sidekick prompt" },
      { "<leader>as", function() require("sidekick.cli").send({ msg = "{this}" }) end, mode = { "n", "x" }, desc = "Send selection/context to CLI" },
      { "<C-.>",      function() require("sidekick.cli").focus() end, mode = { "n", "t", "i", "x" },     desc = "Focus Sidekick CLI" },
    },
  },
})
