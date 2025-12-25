# speak-to.nvim

Speech-to-text for Neovim using whisper.cpp

## Features

- Real-time speech transcription
- Automatic whisper model download
- Text insertion at cursor position
- Works in Normal, Insert, and Visual modes
- Toggle recording mode (press once to start, again to stop)
- `:checkhealth` integration for diagnostics

## Installation

### 1. Install whisper.cpp

```bash
# macOS
brew install whisper-cpp

# Linux
# Use your distribution's package manager or build from source
# https://github.com/ggerganov/whisper.cpp
```

### 2. Install plugin with lazy.nvim

```lua
{
  'Avi-D-coder/speak-to.nvim',
  config = function()
    require('speak-to').setup()
  end,
}
```

Or with lazy loading on keybind:

```lua
{
  'Avi-D-coder/speak-to.nvim',
  config = function()
    require('speak-to').setup({
      model = 'base.en',
      keybind = '<C-g>',
    })
  end,
  keys = {
    { '<C-g>', mode = {'n', 'i', 'v'}, desc = 'Toggle speech-to-text' }
  },
}
```

## Usage

1. Press `<C-g>` (or your configured keybind) to start recording
2. Speak into your microphone
3. Press `<C-g>` again to stop recording and transcribe
4. Transcribed text will be inserted at your cursor position

On first use, the plugin will automatically download the whisper base.en model (~148 MB).

## Configuration

Default configuration:

```lua
require('speak-to').setup({
  -- Binary detection
  binary_path = nil,  -- Auto-detect if nil

  -- Model settings
  model = 'base.en',  -- Options: 'base.en', 'small.en'
  auto_download_model = true,

  -- Whisper parameters
  threads = 4,
  step_ms = 3000,     -- Process audio every 3 seconds
  length_ms = 10000,  -- 10 second audio buffer
  language = 'en',

  -- UI settings
  show_whisper_output = false,
  notifications = true,

  -- Keybindings
  keybind = '<C-g>',
  modes = {'n', 'i', 'v'},
})
```

## Commands

- `:SpeakToToggle` - Toggle recording (same as keybind)
- `:SpeakToDownloadModel [model]` - Download a specific model
- `:checkhealth speak-to` - Check plugin health and configuration

## Troubleshooting

### Check plugin status

```vim
:checkhealth speak-to
```

This will verify:
- whisper-stream binary is installed and working
- Models are downloaded
- Directory permissions are correct

### Common Issues

**"whisper-stream not found"**
- Install whisper-cpp: `brew install whisper-cpp`
- Or specify path: `binary_path = '/path/to/whisper-stream'`

**"No speech detected"**
- Check microphone is working
- Speak louder or closer to microphone
- Check system microphone permissions (macOS: System Settings → Privacy & Security → Microphone)

**"Model download failed"**
- Check internet connection
- Manually download from: https://huggingface.co/ggerganov/whisper.cpp
- Place in: `~/.local/share/nvim/speak-to/models/`

## Models

The plugin supports the following whisper models:

- **base.en** (148 MB) - Default, good balance of speed and accuracy
- **small.en** (488 MB) - Better accuracy, slower

Models are stored in: `~/.local/share/nvim/speak-to/models/`

## Platform Support

- **macOS**: Full support (ARM and Intel)
- **Linux**: Full support (tested on Ubuntu, should work on other distributions)

## Future Features

### v0.2: LLM Integration
- Local LLM via Ollama for command detection
- Async diff-based editing
- Natural language commands (e.g., "delete the last line", "fix indentation")
- Smart text cleanup and formatting

### v0.3+
- OpenAI API-compatible endpoint support
- WhisperX integration for better accuracy
- Voice commands for navigation
- Multi-step command chaining

## Requirements

- Neovim >= 0.8.0
- whisper-cpp binary (`whisper-stream`)
- Working microphone
- Internet connection (for initial model download)

## License

MIT

## Credits

- [whisper.cpp](https://github.com/ggerganov/whisper.cpp) - High-performance inference of OpenAI's Whisper model
- Inspired by the whisper.nvim example in whisper.cpp repository
