"=============================================================================
" AUTHOR:  beeender <chenmulong at gmail.com>
" License: GPLv3
"=============================================================================

" Handle APIs interactions with JetBrains

" Return a list of registered JetBrains channel ids.
function! comrade#jetbrain#Channels()
    let l:channels = nvim_list_chans()
    let list = []
    for l:channel in l:channels
        if !has_key(l:channel, 'client')
            continue
        endif

        let l:client = l:channel['client']
        if has_key(l:client, 'name') && l:client['name'] ==# 'ComradeNeovim'
            let list = add(list, l:channel['id'])
        endif
    endfor
    return list
endfunction

" Return false if the given channel doesn't exist.
function! comrade#jetbrain#IsChannelExisting(channel)
    let l:channels = comrade#jetbrain#Channels()
    for l:c in l:channels
        if (l:c ==# a:channel)
            return v:true
        endif
    endfor
    return v:false
endfunction
