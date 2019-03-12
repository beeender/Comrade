scriptencoding utf8
" Most functions Copied from ale.vim

" These variables dictate what signs are used to indicate errors and warnings.
let g:cde_sign_error = get(g:, 'cde_sign_error', '>>')
let g:cde_sign_warning = get(g:, 'cde_sign_warning', '--')
let g:cde_sign_info = get(g:, 'cde_sign_info', g:cde_sign_warning)

if !hlexists('CDEErrorSign')
    highlight link CDEErrorSign error
endif

if !hlexists('CDEWarningSign')
    highlight link CDEWarningSign todo
endif

if !hlexists('CDEInfoSign')
    highlight link CDEInfoSign CDEWarningSign
endif

if !hlexists('CDESignColumnWithErrors')
    highlight link CDESignColumnWithErrors error
endif

" Signs show up on the left for error markers.
execute 'sign define CDEErrorSign text=' . g:cde_sign_error
\   . ' texthl=CDEErrorSign linehl=CDEErrorLine'
execute 'sign define CDEWarningSign text=' . g:cde_sign_warning
\   . ' texthl=CDEWarningSign linehl=CDEWarningLine'
execute 'sign define CDEInfoSign text=' . g:cde_sign_info
\   . ' texthl=CDEInfoSign linehl=CDEInfoLine'
sign define CDEDummySign

function! s:GetSignName(severity)
    if a:severity >= 400
        return 'CDEErrorSign'
    endif

    if a:severity >= 200
        return 'CDEWarningSign'
    endif

    return 'CDEInfoSign'
endfunction

" Read sign data for a buffer to a list of lines.
function! s:ReadSigns(buffer) abort
    redir => l:output
        silent execute 'sign place buffer=' . a:buffer
    redir end

    return split(l:output, "\n")
endfunction

function! s:FindCurrentSigns(buffer) abort
    let l:line_list = s:ReadSigns(a:buffer)

    return s:ParseSigns(l:line_list)
endfunction

" Given a list of lines for sign output, return a List of [line, id, group]
function! s:ParseSigns(line_list) abort
    " Matches output like :
    " line=4  id=1  name=CDEErrorSign
    " строка=1  id=1000001  имя=CDEErrorSign
    " 行=1  識別子=1000001  名前=CDEWarningSign
    " línea=12 id=1000001 nombre=CDEWarningSign
    " riga=1 id=1000001, nome=CDEWarningSign
    let l:pattern = '\v^.*\=(\d+).*\=(\d+).*\=(CDE[a-zA-Z]+Sign)'
    let l:result = []
    let l:is_dummy_sign_set = 0

    for l:line in a:line_list
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) > 0
            if l:match[3] is# 'ALEDummySign'
                let l:is_dummy_sign_set = 1
            else
                call add(l:result, [
                \   str2nr(l:match[1]),
                \   str2nr(l:match[2]),
                \   l:match[3],
                \])
            endif
        endif
    endfor

    return [l:is_dummy_sign_set, l:result]
endfunction

function! s:GenerateCommands(buffer, sign_map) abort
    let l:list = []
    let [l:is_dummy_sign_set, l:current_sign_list] =
                \   s:FindCurrentSigns(a:buffer)

    for l:sign in l:current_sign_list
        let l:sign_id = l:sign[1]
        if has_key(a:sign_map, l:sign_id) && a:sign_map[l:sign_id]['sign_name'] == l:sign[2]
            call remove(a:sign_map, l:sign_id)
        else
            call add(l:list, 'sign unplace '
                        \   . l:sign_id
                        \   . ' buffer=' . a:buffer
                        \)
        endif
    endfor

    for l:key in keys(a:sign_map)
        let l:line = a:sign_map[l:key]['line']
        let l:sign_name = a:sign_map[l:key]['sign_name']
        call add(l:list, 'sign place '
                    \   . (l:key)
                    \   . ' line=' . l:line
                    \   . ' name=' . l:sign_name
                    \   . ' buffer=' . a:buffer
                    \)
    endfor

    return l:list
endfunction

function! comrade#sign#SetSigns(buffer, insights) abort
    let l:sign_map = {}
    let line = -1
    for l:insight_item in a:insights
        " Insights should be sorted by lines and severities
        if line != l:insight_item['s_line']
            let line = l:insight_item['s_line']
            let l:sign_map[l:insight_item['id']] = {
                        \ 'severity' : l:insight_item['severity'],
                        \ 'line' : l:insight_item['s_line'],
                        \ 'sign_name' : s:GetSignName(l:insight_item['severity'])}
        endif
    endfor

    let l:command_list = s:GenerateCommands(a:buffer, l:sign_map)
    let g:test_list = l:command_list
    for l:command in l:command_list
        silent! execute l:command
    endfor
endfunction

