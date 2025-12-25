local M = {}

local state = {
  recording = false,
  job_id = nil,
  temp_file = nil,
}

M.is_recording = function()
  return state.recording
end

M.get_job_id = function()
  return state.job_id
end

M.get_temp_file = function()
  return state.temp_file
end

M.set_recording = function(val)
  state.recording = val
end

M.set_job_id = function(id)
  state.job_id = id
end

M.set_temp_file = function(file)
  state.temp_file = file
end

M.clear = function()
  state.recording = false
  state.job_id = nil
  state.temp_file = nil
end

return M
