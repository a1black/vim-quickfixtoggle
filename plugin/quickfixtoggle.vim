" vim: sw=4 ts=4 et
" Command for toggling quickfix window.

if exists('g:loaded_a1black#quickfixtoggle') || &compatible
    finish
endif
let g:loaded_a1black#quickfixtoggle=1

command! -bar -bang Ltoggle :call a1black#quickfixtoggle#toggle(<bang>0, 'locallist')
command! -bar -bang Ctoggle :call a1black#quickfixtoggle#toggle(<bang>0, 'quickfix')

nnoremap <silent> <Plug>(a1black#quickfixtoggle#qf) :call a1black#quickfixtoggle#toggle(0, 'quickfix')<CR>
nnoremap <silent> <Plug>(a1black#quickfixtoggle#ll) :call a1black#quickfixtoggle#toggle(0, 'locallist')<CR>
