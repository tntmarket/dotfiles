au BufEnter *.hs compiler ghc
let g:haddock_browser='/usr/bin/google-chrome-stable'

" Autocomplete
let g:ycm_semantic_triggers = {
   \ 'haskell' : ['.', ' '],
   \ 'purescript' : ['.', ' ']
   \ }
let g:haskellmode_completion_ghc = 0
autocmd! FileType haskell setlocal omnifunc=necoghc#omnifunc
autocmd BufWritePost *.hs exec "normal _ct"

" Shortcuts
map <leader>t :GhcModType<CR>
map <leader>i :call HaskellSearchEngine('hoogle')<CR>
map <leader>nt :GhcModTypeClear<CR>
map <leader>gb :GhcModSigCodegen<CR>
map <leader>gt :GhcModTypeInsert<CR>
map <leader>gc :GhcModSplitFunCase<CR>
map <leader><Space> :Tmux :load <C-r>%<CR>

" Auto lint on save
let g:syntastic_haskell_checkers = ['hlint', 'ghc_mod']
let g:syntastic_always_populate_loc_list = 1
