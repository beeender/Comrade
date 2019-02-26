let s:path = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let s:init_path = s:path . "/init.py"
let g:ComradeNeovimId = -1
exe "py3file" s:init_path

call deoplete#enable()
"call deoplete#enable_logging('DEBUG', 'deoplete.log')

function g:ComradeRpcNotify(event, ...)
    if g:ComradeNeovimId > 0
        try
            call call("rpcnotify", [g:ComradeNeovimId, a:event] + a:000)
        catch /^Vim\%((\a\+)\)\=:E475.*Channel doesn't exist/	" E475: Invalid argument: Channel doesn't exist
            let g:ComradeNeovimId = -1
        endtry
    endif
endfunction

function g:ComradeRpcRequest(method, ...)
    if g:ComradeNeovimId > 0
        try
            let result = call("rpcrequest", [g:ComradeNeovimId, a:method] + a:000)
            return result
        catch /^Vim\%((\a\+)\)\=:E475.*Channel doesn't exist/	" E475: Invalid argument: Channel doesn't exist
            let g:ComradeNeovimId = -1
        endtry
    endif
endfunction

function s:NotifyNewBuffer()
    let l:bufId = nvim_get_current_buf()
    let l:bufPath = expand('%:p')
    if (filereadable(l:bufPath))
        call ComradeRpcNotify("comrade_buf_enter", {"id" : l:bufId, "path" : l:bufPath})
    endif
endfunction

autocmd BufEnter * call s:NotifyNewBuffer()

