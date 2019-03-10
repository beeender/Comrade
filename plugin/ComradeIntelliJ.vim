call deoplete#enable()
"call deoplete#enable_logging('DEBUG', 'deoplete.log')

" Called by python when deoplete wants do completion.
function g:ComradeRequestComplete(buf, param)
    if has_key(s:buf_channel_map, a:buf)
        try
            let result = call('rpcrequest', [s:buf_channel_map[a:buf], 'comrade_complete', a:param])
            return result
        catch /./ " The channel has be probably closed
            echom 'Failed to send completion request to JetBrains instance. ' . v:exception
            call remove(s:buf_channel_map, a:buf)
        endtry
    endif
    return []
endfunction

" Called from the JetBrains to register it with this nvim.
function g:ComradeRegisterJetBrains(channel)
    let s:jetbrain_channels[a:channel] = a:channel
    echom 'ComradeNeovim connected. ID: ' . a:channel
endfunction

" Called by JetBrains to register the buffer with the calling channel.
function g:ComradeRegisterBuffer(buf, channel)
    let s:buf_channel_map[a:buf] = a:channel
endfunction

" Unregister the current buffer when it gets deleted.
function s:ComradeUnregisterCurrentBuffer()
    let l:bufId = nvim_get_current_buf()
    if has_key(s:buf_channel_map, l:bufId)
        call remove(s:buf_channel_map, l:bufId)
    endif
endfunction

" To notify the JetBrains that nvim switches to a different buffer.
function s:NotifyNewBuffer()
    let l:bufId = nvim_get_current_buf()
    let l:bufPath = expand('%:p')

    if (filereadable(l:bufPath))
        for channel in values(s:jetbrain_channels)
            try
                call call('rpcnotify', [channel, 'comrade_buf_enter', {'id' : l:bufId, 'path' : l:bufPath}])
            catch /./
                echom 'Failed to send new buffer notification request to JetBrains instance ' . channel . '.' . v:exception
                call remove(s:jetbrain_channels, channel)
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
    " buf_id to channel_id map. The last registered JetBrains channel will
    " overwrite the existing one.
    let s:buf_channel_map = {}
    " All the JetBrains channels.
    let s:jetbrain_channels = {}
    exe 'py3file' s:init_path

    autocmd BufEnter * call s:NotifyNewBuffer()
    autocmd BufDelete * call s:ComradeUnregisterCurrentBuffer()
endif

