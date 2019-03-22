" Called by JetBrains to register the buffer with the calling channel.
" If lines is not empty, the content of buffer will be set. This means
" whenever JetBrains try to register the buffer, the nvim buffer's content
" will be synced with JetBrains' corresponding file content.
function! comrade#buffer#Register(buf, channel, lines) abort
    call comrade#bvar#set(a:buf, 'channel', a:channel)
    call setbufvar(a:buf, '&buftype', 'acwrite')
    augroup ComradeBufEvents
        execute('autocmd! BufWriteCmd <buffer=' . a:buf . '>')

        execute('autocmd BufWriteCmd <buffer=' . a:buf .
                    \ '> call s:WriteBuffer(' . a:buf. ')')
    augroup END

    if !empty(a:lines)
        call nvim_buf_set_lines(a:buf, 0, -1, v:true, a:lines)
        " treat the buffer as an unmodified one since its content is the same
        " with JetBrains' which has auto-save feature always enabled.
        call setbufvar(a:buf, '&modified', 0)
    endif
endfunction

" Unregister the given buffer
function! comrade#buffer#Unregister(buf) abort
    let l:has_channel = comrade#bvar#has(a:buf, 'channel')
    call comrade#bvar#clear(a:buf)

    if l:has_channel
        call setbufvar(a:buf, '&buftype', '')
        execute('autocmd! ComradeBufEvents * <buffer=' . a:buf . '>')

        call comrade#sign#SetSigns(a:buf)
        call comrade#highlight#SetHighlights(a:buf)
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
        let l:channels = comrade#jetbrain#Channels()

        for channel in l:channels
            try
                call call('rpcnotify', [channel, 'comrade_buf_enter', {'id' : l:bufId, 'path' : l:bufPath}])
            catch /./
                call comrade#util#TruncatedEcho('Failed to send new buffer notification to JetBrains instance ' . channel . '.\n' . v:exception)
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
        if !comrade#jetbrain#IsChannelExisting(l:channel)
            call comrade#buffer#Unregister(a:buffer)
            echoe 'The JetBrain has been disconnected thus please write the buffer again if you want to save it.'
        else
            " The disconnecting takes a few seconds, user may have to write
            " again to trigger the unregister.
            echoe 'JetBrain failed to save file.' . v:exception
        endif
    endtry

endfunction
