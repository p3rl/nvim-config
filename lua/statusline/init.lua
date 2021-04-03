local gl = require'galaxyline'
local gls = gl.section
local condition = require('galaxyline.condition')
local vcs = require('galaxyline.provider_vcs')
local buffer = require('galaxyline.provider_buffer')
local fileinfo = require('galaxyline.provider_fileinfo')
local diagnostic = require('galaxyline.provider_diagnostic')
local lspclient = require('galaxyline.provider_lsp')
local icons = require('galaxyline.provider_fileinfo').define_file_icon()
local p4 = require'p4'
local fastbuf = require'fastbuf'

local colorschemes = {
  nord = {
    nord0     = "#2E3440",
    nord1     = "#3B4252",
    nord2     = "#434C5E",
    nord3     = "#7b88a1",
    nord3_bright  = "#616E88",
    nord4     = "#D8DEE9",
    nord5       = "#E5E9F0",
    nord6       = "#ECEFF4",
    nord7       = "#8FBCBB",
    nord8       = "#88C0D0",
    nord9       = "#81A1C1",
    nord10      = "#5E81AC",
    nord11      = "#BF616A",
    nord12      = "#D08770",
    nord13      = "#EBCB8B",
    nord14      = "#A3BE8C",
    nord15      = "#B48EAD",
  },
  gruvbox8 = {
    light = {
      bg0_h = "#f9f5d7",
      bg0_s = "#f2e5bc",
      bg0   = "#fbf1c7",
      bg1   = "#ebdbb2",
      bg2   = "#d5c4a1",
      bg3   = "#bdae91",
      bg4   = "#a89984",
      fg0   = "#282828",
      fg1   = "#3c3836",
      fg2   = "#504945",
      fg3   = "#665c54",
      fg4   = "#7c6f64",
      gray0 = "#928374",
      orange0 = "#d65d0e",
      orange1 = "#af3a03",
      red0  = "#cc241d",
      red1  = "#9d0006",
      green0  = "#98971a",
      green1  = "#79740e",
      yellow0 = "#d79921",
      yellow1 = "#b57614",
      blue0 = "#458588",
      blue1 = "#076678",
      purple0 = "#b16286",
      purple1 = "#8f3f71",
      aqua0 = "#689d6a",
      aqua1 = "#427b58",
    }
  }
}

local default_colors  = {
  filename = nil,
  filedir = nil,
  filetype = nil,
  lineinfo = nil,
  empty = nil,
  vcs = nil,
}

local themes = {
  default = default_colors,
  nord = {
    filename  = { colorschemes.nord.nord0, colorschemes.nord.nord8, 'bold' },
    filedir   = { colorschemes.nord.nord4, colorschemes.nord.nord2 },
    filetype  = { colorschemes.nord.nord14, colorschemes.nord.nord0 },
    lineinfo  = { colorschemes.nord.nord0, colorschemes.nord.nord4, 'bold' },
    empty   = { colorschemes.nord.nord0, colorschemes.nord.nord1 },
    vcs     = { colorschemes.nord.nord0, colorschemes.nord.nord7, 'bold' },
  },
  gruvbox8 = {
    light = {
      filename  = { colorschemes.gruvbox8.light.bg0_h, colorschemes.gruvbox8.light.blue0, 'bold' },
      filedir   = { colorschemes.gruvbox8.light.fg1, colorschemes.gruvbox8.light.bg2 },
      filetype  = { colorschemes.gruvbox8.light.fg1, colorschemes.gruvbox8.light.bg2 },
      lineinfo  = { colorschemes.gruvbox8.light.bg0_h, colorschemes.gruvbox8.light.fg3 },
      empty   = { colorschemes.gruvbox8.light.fg1, colorschemes.gruvbox8.light.bg2 , 'bold' },
      vcs     = { colorschemes.gruvbox8.light.fg1, colorschemes.gruvbox8.light.bg2 },
    },
    dark      = default_colors
  },
  gruvbox8_hard = {
    light = {
      filename  = { colorschemes.gruvbox8.light.bg0_h, colorschemes.gruvbox8.light.blue0, 'bold' },
      filedir   = { colorschemes.gruvbox8.light.fg1, colorschemes.gruvbox8.light.bg2 },
      filetype  = { colorschemes.gruvbox8.light.fg1, colorschemes.gruvbox8.light.bg2 },
      lineinfo  = { colorschemes.gruvbox8.light.bg0_h, colorschemes.gruvbox8.light.fg3 },
      empty   = { colorschemes.gruvbox8.light.fg1, colorschemes.gruvbox8.light.bg2 , 'bold' },
      vcs     = { colorschemes.gruvbox8.light.fg1, colorschemes.gruvbox8.light.bg2 },
    },
    dark      = default_colors
  }
}

local Statusline = { colorscheme = nil, background = nil }

function Statusline.setup(colorscheme, background)
  local colors = themes.default
  local theme = themes[colorscheme]
  if theme then
    colors = theme[background] or theme
    print("applying " .. colorscheme .. " with background " .. background)
  end

  Statusline.colorscheme = colorscheme
  Statusline.background = background

  gl.short_line_list = {
    'fzf',
    'term',
    'plug',
    'netrw',
    'nvimtree'
  }

  gls.left = {
    {
      filename = {
        provider = function()
          local status_text = ''
          if vim.bo.readonly == true then
            status_text = '[RO]'
          elseif vim.bo.modified then
            status_text = '[+]'
          end
          local pinned_text = fastbuf.is_buffer_pinned() and '[P]' or ''
          return string.format('%3s %s %s ', status_text, vim.fn.expand('%:t'), pinned_text)
        end,
        condition = condition.buffer_not_empty,
        highlight = colors.filename,
      }
    },
    {
      filedir = {
        provider = function()
          return string.format('  %s  ', vim.fn.expand('%:h'))
        end,
        condition = function() return condition.buffer_not_empty() and condition.hide_in_width() end,
        highlight = colors.filedir,
      }
    },
    {
      empty = {
        provider = function()
          return ''
        end,
        condition = condition.buffer_not_empty,
        highlight = colors.empty
      }
    }
  }

  gls.right = {
    {
      perforce = {
        provider = function()
          return string.format('    %s    ', p4.get_client_name())
        end,
        condition = function() return condition.buffer_not_empty and p4.has_active_workspace() and condition.hide_in_width() end,
        highlight = colors.vcs
      }
    },
    {
      filetype = {
        provider = function()
          return string.format('  %s  ', buffer.get_buffer_filetype())
        end,
        condition = condition.buffer_not_empty,
        highlight = filetype
      }
    },
    {
      fileformat = {
        provider = function()
          return string.format('  %s  ', fileinfo.get_file_format())
        end,
        condition = condition.buffer_not_empty,
      }
    },
    {
      fileencoding = {
        provider = function()
          return string.format('  %s  ', fileinfo.get_file_encode())
        end,
        condition = condition.buffer_not_empty,
      }
    },
    {
      lineinfo = {
        provider = function()
          return string.format('%12s  ', fileinfo.line_column())
        end,
        highlight = colors.lineinfo
      }
    }
  }
end

function Statusline.reload()
  local colorscheme, background = Statusline.colorscheme, Statusline.background
  package.loaded['statusline'] = nil
  require'statusline'.init(colorscheme, background)
  require'galaxyline'.load_galaxyline()
end

return Statusline

