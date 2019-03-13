call deoplete#enable()
"call deoplete#enable_logging('DEBUG', 'deoplete.log')

" Called by python when deoplete wants do completion.
function g:ComradeRequestComplete(buf, param)
    if comrade#bvar#has(a:buf, 'channel')
        try
            let result = call('rpcrequest', [comrade#bvar#get(a:buf, 'channel'), 'comrade_complete', a:param])
            return result
        catch /./ " The channel has been probably closed
            call comrade#util#TruncatedEcho('Failed to send completion request to JetBrains instance. \n' . v:exception)
            call comrade#bvar#remove(a:buf, 'channel')
        endtry
    endif
    return []
endfunction

" Called by JetBrains to register the buffer with the calling channel.
function g:ComradeRegisterBuffer(buf, channel)
    call comrade#bvar#set(a:buf, 'channel', a:channel)
endfunction

" Unregister the current buffer when it gets deleted.
function s:ComradeUnregisterCurrentBuffer()
    let l:buf = nvim_get_current_buf()
    if comrade#bvar#has(l:buf, 'channel')
        call comrade#bvar#remove(l:buf, 'channel')
    endif
endfunction

" To notify the JetBrains that nvim switches to a different buffer.
function s:NotifyNewBuffer()
    let l:bufId = nvim_get_current_buf()
    let l:bufPath = expand('%:p')

    if (filereadable(l:bufPath))
        for channel in comrade#jetbrain#channels()
            try
                call call('rpcnotify', [channel, 'comrade_buf_enter', {'id' : l:bufId, 'path' : l:bufPath}])
            catch /./
                call comrade#util#TruncatedEcho('Failed to send new buffer notification request to JetBrains instance ' . channel . '.\n' . v:exception)
                call comrade#jetbrain#unregister(channel)
            endtry
        endfor
    endif
endfunction

if !exists('comrade_loaded')
    let comrade_loaded = 1
    let g:comrade_major_version = 0
    let g:comrade_minor_version = 1
    let g:comrade_patch_version = 0
    let g:comrade_version = '' . g:comrade_major_version . '.' . g:comrade_minor_version . '.' . g:comrade_patch_version

    let s:path = fnamemodify(resolve(expand('<sfile>:p')), ':h')
    let s:init_path = s:path . '/init.py'
    exe 'py3file' s:init_path

    autocmd BufEnter * call s:NotifyNewBuffer()
    autocmd BufDelete * call s:ComradeUnregisterCurrentBuffer()
    call comrade#events#Init()
endif

