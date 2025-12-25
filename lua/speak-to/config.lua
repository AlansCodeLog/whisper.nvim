local M = {}

M.defaults = {
  -- Binary detection
  binary_path = nil, -- Auto-detect if nil

  -- Model settings
  model = 'base.en', -- Options: 'base.en', 'small.en', 'tiny.en', 'medium.en', 'large-v1', 'large-v2', 'large-v3'
  auto_download_model = true,

  -- Whisper parameters
  threads = 4,
  step_ms = 3000, -- Process audio every 3 seconds
  length_ms = 10000, -- 10 second audio buffer
  language = 'en',

  -- UI settings
  show_whisper_output = false,
  notifications = true,

  -- Keybindings
  keybind = '<C-g>',
  modes = { 'n', 'i', 'v' },

  -- Future: LLM settings (v0.2+)
  llm = {
    enabled = false, -- Not implemented in v0.1
  },
}

M.config = nil

M.setup = function(user_config)
  M.config = vim.tbl_deep_extend('force', M.defaults, user_config or {})
  return M.config
end

M.get = function()
  return M.config or M.defaults
end

return M
