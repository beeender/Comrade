function! s:Map(map_cmd, key, command)
    silent! execute('' . a:map_cmd . ' <buffer> ' . a:key. ' ' . a:command)
endfunction

function! s:Unmap(unmap_cmd, key)
    silent! execute('' . a:unmap_cmd. ' <buffer> ' . a:key)
endfunction

" Register all comrade hotkeys to the current buffer
function! comrade#key#Register(buffer) abort
    let l:cur_buf = bufnr('%')
    if l:cur_buf != a:buffer
        return
    endif

    let l:key = get(g:, 'comrade_key_fix', '<LEADER><LEADER>f')
    call s:Map('nmap', l:key, ':ComradeFix<CR>')
endfunction

" Unregister all comrade hotkeys from the current buffer
function! comrade#key#Unregister(buffer) abort
    let l:cur_buf = bufnr('%')
    if l:cur_buf != a:buffer
        return
    endif

    let l:key = get(g:, 'comrade_key_fix', '<LEADER><LEADER>f')
    call s:Unmap('nmap', l:key)
endfunction
