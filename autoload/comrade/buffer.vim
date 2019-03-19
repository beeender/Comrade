" Called by JetBrains to register the buffer with the calling channel.
function! comrade#buffer#Register(buf, channel) abort
    call comrade#bvar#set(a:buf, 'channel', a:channel)
    call setbufvar(a:buf, '&buftype', 'acwrite')
    augroup ComradeBufEvents
        execute('autocmd! BufWriteCmd <buffer=' . a:buf . '>')

        execute('autocmd BufWriteCmd <buffer=' . a:buf .
                    \ '> call s:WriteBuffer(' . a:buf. ')')
    augroup END
endfunction

" Unregister the given buffer
function! comrade#buffer#Unregister(buf) abort
    if comrade#bvar#has(a:buf, 'channel')
        call comrade#bvar#remove(a:buf, 'channel')
        call setbufvar(a:buf, '&buftype', '')
        execute('autocmd! ComradeBufEvents * <buffer=' . a:buf . '>')
    endif
endfunction

" Unregister the current buffer
function! comrade#buffer#UnregisterCurrent()
    call comrade#buffer#Unregister(bufnr('%'))
endfunction

" To notify the JetBrains that nvim switches to a different buffer.
function! comrade#buffer#Notify() abort
    let l:bufId = bufnr('%')
    let l:bufPath = expand('%:p')

    if (filereadable(l:bufPath))
        for channel in comrade#jetbrain#Channels()
            try
                call call('rpcnotify', [channel, 'comrade_buf_enter', {'id' : l:bufId, 'path' : l:bufPath}])
            catch /./
                call comrade#util#TruncatedEcho('Failed to send new buffer notification to JetBrains instance ' . channel . '.\n' . v:exception)
                call comrade#buffer#Unregister(l:bufId)
                call comrade#jetbrain#Unregister(channel)
            endtry
        endfor
    endif
endfunction

function! s:WriteBuffer(buffer)
    if !comrade#bvar#has(a:buffer, 'channel')
        call comrade#buffer#Unregister(a:buffer)
        return
    endif

    let l:channel = comrade#bvar#get(a:buffer, 'channel')
    try
        call call('rpcrequest', [l:channel, 'comrade_buf_write', {'id' : a:buffer}])
        call setbufvar(a:buffer, '&modified', 0)
    catch /./
        call comrade#buffer#Unregister(a:buffer)
        call comrade#jetbrain#Unregister(channel)
        echoe 'The JetBrain has been disconnected thus please write the buffer again if you want to save it.'
    endtry

endfunction
