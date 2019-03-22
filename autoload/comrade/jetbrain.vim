" Handle APIs interactions with JetBrains

let s:jetbrain_channels = {}

" Called by JetBrains to register with the channel id.
function! comrade#jetbrain#Register(channel)
    let s:jetbrain_channels[a:channel] = a:channel
    call comrade#util#TruncatedEcho('Connected to ComradeNeovim . ID: ' . a:channel)
endfunction

" To unregister with a channel id.
function! comrade#jetbrain#Unregister(channel)
    if has_key(s:jetbrain_channels, a:channel)
        call remove(s:jetbrain_channels, a:channel)
        call comrade#util#TruncatedEcho('Disconnected from ComradeNeovim. ID: ' . a:channel)
    endif
endfunction

" Return a list of registered JetBrains channel ids.
function! comrade#jetbrain#Channels()
    return values(s:jetbrain_channels)
endfunction
