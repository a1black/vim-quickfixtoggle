" vi: sw=4 ts=4 et

" Resolve prefix of open/close command for quickfix window.
function! s:Resolve_cmd_prefix(abbrev) abort
    let l:prefix = 'l'
    if a:abbrev ==? 'qf' || a:abbrev ==? 'quickfix' || a:abbrev ==? 'q'
        let l:prefix = 'c'
    endif

    return l:prefix
endfunction

" Open quickfix window.
function! s:Open_quickfix_window(prefix)
    let l:linenr = line('.')
    let l:colnr = col('.')
    let l:winid = win_getid()
    silent! execute 'botright '.a:prefix.'open'
    let l:line_err = s:Focus_quickfix_on_error(a:prefix, l:winid, l:linenr, l:colnr)
    if l:line_err > 0
        call cursor(l:line_err, 0)
    endif
endfunction

" Get list of items in quickfix buffer.
" Args:
"   prefix: Window type.
"   winid:  Window-ID.
function! s:List_quickfix_error(prefix, winid)
    if a:prefix ==? 'q'
        let l:items = getqflist({'nr': win_id2win(a:winid), 'items': 1})
    else
        let l:items = getloclist(win_id2win(a:winid), {'items': 1})
    endif

    return l:items.items
endfunction

" Find error in quickfix for current line in buffer.
" Args:
"   prefix: Window type.
"   winid:  Window-ID.
"   line:   Current line in buffer.
"   col:    Current column in buffer.
function! s:Focus_quickfix_on_error(prefix, winid, line, col)
    let l:line_err = -1
    let l:line_count = 0
    for l:item in s:List_quickfix_error(a:prefix, a:winid)
        let l:line_count = l:line_count + 1
        if l:item.lnum > a:line
            break
        elseif l:line_err < 1 && l:item.lnum ==# a:line
            let l:line_err = l:line_count
        elseif l:item.lnum ==# a:line && l:item.col ==# a:col
            let l:line_err = l:line_count
            break
        elseif l:item.lnum ==# a:line && l:item.col < a:col
            let l:line_err = l:line_count
        endif
    endfor
    if l:line_count ==# 0
        call s:Close_quickfix_buf(-1)
    endif

    return l:line_err
endfunction

" Close all buffers with type of 'quickfix'.
" Args:
"   exclude: Number of window to keep open.
function! s:Close_quickfix_buf(exclude) abort
    let l:win_nr = winnr('$')
    while l:win_nr > 0
        let l:buf_nr = winbufnr(l:win_nr)
        let l:win_nr = l:win_nr - 1
        if a:exclude ==# l:win_nr + 1 | continue | endif
        if l:buf_nr != -1 && getbufvar(l:buf_nr, '&buftype') ==? 'quickfix'
            execute 'bdelete '.l:buf_nr
        endif
    endwhile
endfunction

" Get command prefix for quickfix window.
" Args:
"   winid:   Windows-ID.
"   default: Default value.
function! s:Get_cmd_prefix(winid, default)
    let l:wininfo = getwininfo(a:winid)
    try
        let l:qf = (l:wininfo[0]['quickfix'] ==# 1 ? 'c' : a:default)
        return (l:wininfo[0]['loclist'] ==# 1 ? 'l' : l:qf)
    catch /.*/
        return a:default
    endtry
endfunction

" Get buffer name associated with quickfix window.
function! s:Get_assoc_filename(winid)
    let l:filename = getwinvar(a:winid, 'netrw_prvfile')
    if !empty(l:filename) && !bufexists(l:filename)
        let l:filename = ''
    endif

    return l:filename
endfunction

function! a1black#quickfixtoggle#toggle(bang, prefix)
    " Initialize some variables.
    let l:prefix = s:Resolve_cmd_prefix(a:prefix)
    " If in quickfix window close all.
    if &l:buftype ==# 'quickfix'
        let l:cur = s:Get_cmd_prefix(win_getid(), l:prefix)
        let l:buf = s:Get_assoc_filename(win_getid())
        let l:win = (empty(l:buf) ? -1 : bufwinid(l:buf))
        call s:Close_quickfix_buf(-1)
        if l:win > 0
            call win_gotoid(l:win)
            if l:cur !=# l:prefix
                call s:Open_quickfix_window(l:prefix)
            endif
        endif
    else
        " Preser current state.
        let l:last_win = winnr('$')
        let l:winid = win_getid()
        " Open quickfix window.
        call s:Open_quickfix_window(l:prefix)
        if l:last_win < winnr('$') || a:bang ==# 0
            call s:Close_quickfix_buf(winnr())
        else
            call s:Close_quickfix_buf(-1)
            call win_gotoid(l:winid)
        endif
    endif
endfunction
