" Called by JetBrains to register the buffer with the calling channel.
function! comrade#buffer#Register(buf, channel)
    call comrade#bvar#set(a:buf, 'channel', a:channel)
endfunction

" Unregister the given buffer
function! comrade#buffer#Unregister(buf)
    if comrade#bvar#has(a:buf, 'channel')
        call comrade#bvar#remove(a:buf, 'channel')
    endif
endfunction

" Unregister the current buffer
function! comrade#buffer#UnregisterCurrent()
    call comrade#buffer#Unregister(bufnr('%'))
endfunction

" To notify the JetBrains that nvim switches to a different buffer.
function! comrade#buffer#Notify()
    let l:bufId = bufnr('%')
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
