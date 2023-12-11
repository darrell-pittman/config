local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = ' '

require("lazy").setup({
  {
    "oxfist/night-owl.nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    --config = function()
    --  -- load the colorscheme here
    --  vim.cmd.colorscheme("night-owl")
    --end,
  },

  { --LSP
    'neovim/nvim-lspconfig',
    dependencies = {
      "j-hui/fidget.nvim",
      tag = "legacy",
      event = "LspAttach",
    },
  },

  { --Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'saadparwaiz1/cmp_luasnip',
      'L3MON4D3/LuaSnip'
    }
  },

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    init = function()
      pcall(require('nvim-treesitter.install').update { with_sync = true })
    end,
    dependencies = { -- Additional text objects via treesitter
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
  },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },

  -- Fuzzy Finder Algorithm which requires local dependencies to be built.
  -- Only load if `make` is available
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build =
    'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build',
  },

  -- "gc" to comment visual regions/lines
  'numToStr/Comment.nvim',

  'onsails/lspkind.nvim',
  'darrell-pittman/wgc-nvim-utils',
})
