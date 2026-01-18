local M = {}

M.insert_text = function(text)
  if not text or text == '' then
    return
  end

  local mode = vim.api.nvim_get_mode().mode

  if mode == 'i' then
    -- Insert mode: insert at cursor
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()
    local new_line = line:sub(1, col) .. text .. line:sub(col + 1)
    vim.api.nvim_set_current_line(new_line)
    vim.api.nvim_win_set_cursor(0, { row, col + #text })
  elseif mode == 'n' then
    -- Normal mode: paste after cursor
    vim.fn.setreg('a', text)
    vim.cmd('normal! "ap')
  elseif mode == 'v' or mode == 'V' or mode == '\22' then -- \22 is visual block mode
    -- Visual mode: replace selection
    vim.cmd('normal! c')
    vim.api.nvim_put({ text }, 'c', true, true)
  else
    vim.api.nvim_put({ text }, 'c', true, true)
  end

  -- Post-insert hook: call config callback + fire a User autocmd
  local config = require('whisper.config').get()
  local ok, cur = pcall(vim.api.nvim_win_get_cursor, 0)
  if ok and cur then
    local buf = vim.api.nvim_get_current_buf()
    local row = cur[1]
    local col = cur[2]

    -- Schedule callback and autocmd on the main loop to allow plugin callbacks to use Neovim API
    vim.schedule(function()
      -- Safe callback
      if config and config.post_insert and type(config.post_insert) == 'function' then
        local ok_cb, err = pcall(config.post_insert, { buf = buf, row = row, col = col, text = text })
        if not ok_cb then
          vim.notify('whisper.nvim: post_insert callback error: ' .. tostring(err), vim.log.levels.ERROR)
        end
      end

      -- Publish last insert info for autocmds
      vim.b.whisper_last_insert = { buf = buf, row = row, col = col, text = text }

      -- Trigger a User autocommand that users can listen for
      pcall(vim.cmd, 'doautocmd User WhisperNvimPostInsert')
    end)
  end
end

return M
