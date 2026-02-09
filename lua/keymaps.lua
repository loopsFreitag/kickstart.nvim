-- Set <space> as the leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local silent = { silent = true }

-- [[ Basic Keymaps ]]
-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Split navigation: Use CTRL+<hjkl> to switch between windows
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- ToggleTerm Mappings
vim.keymap.set('n', '<C-\\>', '<cmd>ToggleTerm direction=float<CR>', { desc = 'Toggle floating terminal' })

vim.keymap.set('n', '<leader>tv', function()
  require('toggleterm.terminal').Terminal:new({ direction = 'vertical' }):toggle()
end, { desc = 'New vertical terminal' })

vim.keymap.set('n', '<leader>tt', function()
  require('toggleterm.terminal').Terminal:new({ direction = 'horizontal', size = 55 }):toggle()
end, { desc = 'New horizontal terminal' })

-- Barbar (Tabs/Buffers)
-- Navigate buffers
vim.keymap.set('n', '<A-,>', '<Cmd>BufferPrevious<CR>', silent)
vim.keymap.set('n', '<A-.>', '<Cmd>BufferNext<CR>', silent)
vim.keymap.set('n', '<A-w>', '<Cmd>BufferClose<CR>', silent)

-- Re-order buffers
vim.keymap.set('n', '<A-<>', '<Cmd>BufferMovePrevious<CR>', silent)
vim.keymap.set('n', '<A->>', '<Cmd>BufferMoveNext<CR>', silent)

-- Go to buffer in position...
for i = 1, 9 do
  vim.keymap.set('n', '<A-' .. i .. '>', '<Cmd>BufferGoto ' .. i .. '<CR>', silent)
end
vim.keymap.set('n', '<A-0>', '<Cmd>BufferLast<CR>', silent)

-- Close buffer
vim.keymap.set('n', '<A-w>', '<Cmd>BufferClose<CR>', { silent = true })

-- Telescope + Buffer Splits
vim.keymap.set('n', '<leader>bo', function()
  vim.cmd 'vsplit'
  require('telescope.builtin').find_files {
    attach_mappings = function(_, map)
      map('i', '<CR>', function(prompt_bufnr)
        local action_state = require 'telescope.actions.state'
        local actions = require 'telescope.actions'
        local file = action_state.get_selected_entry().value
        actions.close(prompt_bufnr)
        vim.cmd('edit ' .. file)
      end)
      return true
    end,
  }
end, { desc = '[B]uffer split and [O]pen file with Telescope' })

vim.keymap.set('n', '<leader>bs', function()
  vim.cmd 'vsplit'
end, { desc = '[B]uffer [S]plit' })

-- [[ Telescope Keymaps ]]
-- We wrap these in functions so they don't crash if Telescope isn't loaded yet
local function tel(name)
  return function(opts)
    require('telescope.builtin')[name](opts)
  end
end

vim.keymap.set('n', '<leader>sh', tel 'help_tags', { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', tel 'keymaps', { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', tel 'find_files', { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>ss', tel 'builtin', { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>sw', tel 'grep_string', { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', tel 'live_grep', { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', tel 'diagnostics', { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', tel 'resume', { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', tel 'oldfiles', { desc = '[S]earch Recent Files' })
vim.keymap.set('n', '<leader><leader>', tel 'buffers', { desc = '[ ] Find existing buffers' })

-- The smarter "Search in Open Files" fix
vim.keymap.set('n', '<leader>s/', function()
  local builtin = require 'telescope.builtin'
  local bufs = vim.api.nvim_list_bufs()
  local files = {}
  for _, buf in ipairs(bufs) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local name = vim.api.nvim_buf_get_name(buf)
      if vim.fn.getftype(name) == 'file' and not name:match 'NvimTree' then
        table.insert(files, name)
      end
    end
  end

  if #files > 0 then
    builtin.live_grep { search_dirs = files, prompt_title = 'Grep in Open Files' }
  else
    print 'No real files open to search!'
  end
end, { desc = '[S]earch [/] in Open Files' })

-- Define the custom search function once
local function telescope_live_grep_search()
  local builtin = require 'telescope.builtin'

  builtin.live_grep {
    prompt_title = 'Search (n/N to navigate)',
    -- Restrict search to ONLY the current file path
    search_dirs = { vim.fn.expand '%:p' },

    attach_mappings = function(prompt_bufnr, map)
      local actions = require 'telescope.actions'
      local action_state = require 'telescope.actions.state'

      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        local current_query = action_state.get_current_line()

        actions.close(prompt_bufnr)

        if selection then
          -- Move cursor to the selected line and column
          vim.api.nvim_win_set_cursor(0, { selection.lnum, selection.col or 0 })

          -- Set the native search register to your EXACT query
          vim.fn.setreg('/', current_query)

          -- Enable search highlighting
          vim.opt.hlsearch = true
        end
      end)
      return true
    end,
  }
end

-- Assign the function to both / and <leader>/
vim.keymap.set('n', '/', telescope_live_grep_search, { desc = 'Telescope replace native search' })
vim.keymap.set('n', '<leader>/', telescope_live_grep_search, { desc = '[/] Search in current file' })
