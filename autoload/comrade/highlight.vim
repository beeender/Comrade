scriptencoding utf8

if !hlexists('CDEError')
    highlight link CDEError SpellBad
endif

if !hlexists('CDEWarning')
    highlight link CDEWarning SpellCap
endif

if !hlexists('CDEWeakWarning')
    highlight link CDEWeakWarning SpellRare
endif

if !hlexists('CDEInfo')
    highlight link CDEInfo SpellLocal
endif

function! s:GetHighlightGroup(severity)
    if a:severity >= 400
        return 'CDEError'
    endif

    if a:severity >= 300
        return 'CDEWarning'
    endif

    if a:severity >= 200
        return 'CDEWeakWarning'
    endif

    return 'CDEInfo'
endfunction

function! s:SetHighlight(buffer, insight)
    let l:id = a:insight['id']
    let l:hl_group = s:GetHighlightGroup(a:insight['severity'])
    let l:start_line = a:insight['s_line']
    let l:end_line = a:insight['e_line']
    let l:cur_line = l:start_line
    while l:cur_line <= l:end_line
        if l:cur_line != l:start_line
            let l:start_col = 0
        else
            let l:start_col = a:insight['s_col']
        endif
        if l:cur_line != l:end_line
            let l:end_col = 0
        else
            let l:end_col = a:insight['e_col']
        endif
        call nvim_buf_add_highlight(a:buffer,
                    \ l:id, l:hl_group, l:cur_line, l:start_col, l:end_col)
        let l:cur_line = l:cur_line + 1
    endwhile

    return l:id
endfunction

function! comrade#highlight#SetHighlights(buffer, loc_list) abort
    try
        let l:highlight_ids_to_remove = nvim_buf_get_var(a:buffer, 'comrade_highlight_ids')
    catch /./
        let l:highlight_ids_to_remove = {}
    endtry

    let l:highlight_ids = {}
    let l:new_highlight_indices  = []

    let l:idx = 0
    for l:insight in a:loc_list
        let l:id = l:insight['id']
        if has_key(l:highlight_ids_to_remove, l:id)
            call remove(l:highlight_ids_to_remove, l:id)
            let l:highlight_ids[l:id] = ''
        else
            let l:new_highlight_indices = add(l:new_highlight_indices, idx)
        endif
        let l:idx = l:idx + 1
    endfor

    for l:id_to_remove in keys(l:highlight_ids_to_remove)
        call nvim_buf_clear_namespace(a:buffer, str2nr(l:id_to_remove), 0, -1)
    endfor

    for l:idx in l:new_highlight_indices
        let l:insight = a:loc_list[l:idx]
        let l:id = l:insight['id']
        let l:highlight_ids[s:SetHighlight(a:buffer, l:insight)] = ''
    endfor

    call nvim_buf_set_var(a:buffer, 'comrade_highlight_ids', l:highlight_ids)
endfunction
