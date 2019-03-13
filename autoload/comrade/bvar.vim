" Manage comrade ralated buffer vars

let s:bvar_key='comrade_info'

function! comrade#bvar#set(buffer, name, value)
    let l:map = getbufvar(a:buffer, s:bvar_key)
    if empty(l:map)
        let l:map = {}
        call setbufvar(a:buffer, s:bvar_key, l:map)
    endif
    let map[a:name] = a:value
endfunction

function! comrade#bvar#get(buffer, name)
    let l:map = getbufvar(a:buffer, s:bvar_key)
    if empty(l:map) || !has_key(l:map, a:name)
        return 0
    endif
    return map[a:name]
endfunction

function! comrade#bvar#has(buffer, name)
    let l:map = getbufvar(a:buffer, s:bvar_key)
    if empty(l:map) || !has_key(l:map, a:name)
        return 0
    endif
    return 1
endfunction

function! comrade#bvar#remove(buffer, name)
    let l:map = getbufvar(a:buffer, s:bvar_key)
    if empty(l:map) || !has_key(l:map, a:name)
        return
    endif
    call remove(l:map, a:name)
endfunction
