" speak-to.nvim - Speech-to-text for Neovim
" Maintainer: Avi D
" Version: 0.1.0

if exists('g:loaded_speak_to')
  finish
endif
let g:loaded_speak_to = 1

" Plugin is loaded via Lua
" Users should call require('speak-to').setup() in their config
