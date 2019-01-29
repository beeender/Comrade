let s:path = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let s:init_path = s:path . "/init.py"
let g:intelliJID = -1
exe "py3file" s:init_path

call deoplete#enable()
"call deoplete#enable_logging('DEBUG', 'deoplete.log')
"autocmd VimLeave * lua require("main").deinit()

function g:ComradeRpcNotify(event, ...)
    if g:intelliJID > 0
        try
            call call("rpcnotify", [g:intelliJID, a:event] + a:000)
        catch /^Vim\%((\a\+)\)\=:E475.*Channel doesn't exist/	" E475: Invalid argument: Channel doesn't exist
            let g:intelliJID = -1
        endtry
    endif
endfunction

function g:ComradeRpcRequest(method, ...)
    if g:intelliJID > 0
        try
            let result = call("rpcrequest", [g:intelliJID, a:method] + a:000)
            return result
        catch /^Vim\%((\a\+)\)\=:E475.*Channel doesn't exist/	" E475: Invalid argument: Channel doesn't exist
            let g:intelliJID = -1
        endtry
    endif
endfunction

function s:NotifyNewBuffer()
    let l:bufId = nvim_get_current_buf()
    call ComradeRpcNotify("IntelliJBufEnter", {"id" : l:bufId, "path" : expand('%:p')})
endfunction

autocmd BufEnter * call s:NotifyNewBuffer()

