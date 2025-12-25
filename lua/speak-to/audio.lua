local M = {}

local state = require('speak-to.state')
local binary = require('speak-to.binary')
local model = require('speak-to.model')
local insert = require('speak-to.insert')

M.toggle_recording = function(config)
  if state.is_recording() then
    M.stop_recording()
  else
    M.start_recording(config)
  end
end

M.start_recording = function(config)
  -- Check prerequisites
  local binary_path, err = binary.find_binary(config)
  if not binary_path then
    vim.notify('whisper-stream not found. Install via: brew install whisper-cpp', vim.log.levels.ERROR)
    return
  end

  local model_path = model.get_model_path(config.model)
  if not model.model_exists(config.model) then
    if config.auto_download_model then
      local model_info = model.get_model_info(config.model)
      local size_mb = math.floor(model_info.size / 1024 / 1024)
      vim.notify(
        string.format('Downloading %s model (%d MB)...', config.model, size_mb),
        vim.log.levels.INFO
      )

      model.download_model(config.model, nil, function(success, msg)
        if success then
          vim.notify('Model downloaded successfully!', vim.log.levels.INFO)
          M.start_recording(config) -- Retry after download
        else
          vim.notify('Model download failed: ' .. msg, vim.log.levels.ERROR)
        end
      end)
      return
    else
      vim.notify('Model not found. Run :SpeakToDownloadModel to download.', vim.log.levels.ERROR)
      return
    end
  end

  -- Create temp file for output
  local temp_file = vim.fn.tempname()
  state.set_temp_file(temp_file)

  -- Build command
  local cmd = string.format(
    '%s -m "%s" -t %d --step %d --length %d -f "%s"',
    binary_path,
    model_path,
    config.threads or 4,
    config.step_ms or 3000,
    config.length_ms or 10000,
    temp_file
  )

  -- Add language if specified
  if config.language then
    cmd = cmd .. ' -l ' .. config.language
  end

  -- Redirect stderr to suppress verbose output
  if not config.show_whisper_output then
    cmd = cmd .. ' 2>/dev/null'
  end

  -- Start process using jobstart (non-blocking)
  local job_id = vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code)
      vim.schedule(function()
        if exit_code == 0 or exit_code == 143 then -- 143 is SIGTERM
          M.on_recording_complete(temp_file, config)
        else
          vim.notify('Recording failed with exit code: ' .. exit_code, vim.log.levels.ERROR)
        end
        state.clear()
      end)
    end,
  })

  if job_id <= 0 then
    vim.notify('Failed to start recording', vim.log.levels.ERROR)
    return
  end

  state.set_job_id(job_id)
  state.set_recording(true)

  if config.notifications then
    vim.notify('Recording... (press ' .. config.keybind .. ' to stop)', vim.log.levels.INFO)
  end
end

M.stop_recording = function()
  local job_id = state.get_job_id()
  if job_id then
    vim.fn.jobstop(job_id) -- Send SIGTERM, triggers on_exit
  end
end

M.on_recording_complete = function(temp_file, config)
  -- Read last line of output
  local lines = vim.fn.readfile(temp_file)
  if #lines == 0 then
    if config.notifications then
      vim.notify('No transcription result', vim.log.levels.WARN)
    end
    vim.fn.delete(temp_file)
    return
  end

  local text = lines[#lines]

  -- Clean up text (trim whitespace)
  text = text:match('^%s*(.-)%s*$')

  if text == '' then
    if config.notifications then
      vim.notify('Transcription was empty', vim.log.levels.WARN)
    end
    vim.fn.delete(temp_file)
    return
  end

  -- Insert at cursor
  insert.insert_text(text)

  if config.notifications then
    vim.notify('Transcribed: ' .. text:sub(1, 50) .. (text:len() > 50 and '...' or ''), vim.log.levels.INFO)
  end

  -- Cleanup temp file
  vim.fn.delete(temp_file)
end

return M
