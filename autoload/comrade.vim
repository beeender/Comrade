" Called by JetBrains to set the code insight result.
" insight_map format:
" { start_line_number :
"   [
"     {id: , s_line: , e_line: , s_col: , e_col: , severity: }
"     {id: , s_line: , e_line: , s_col: , e_col: , severity: }
"   ]
" }
" Line number is 0 based.
function! comrade#SetInsights(buf, insight_map)
    call comrade#bvar#set(a:buf, 'insight_map', a:insight_map)
    call comrade#sign#SetSigns(a:buf)
    call comrade#highlight#SetHighlights(a:buf)
endfunction

" Called by python when deoplete wants do completion.
function! comrade#RequestCompletion(buf, param)
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

function! comrade#RequestQuickFix(buf, insight, fix) abort
    if comrade#bvar#has(a:buf, 'channel')
        try
            let result = call('rpcrequest', [comrade#bvar#get(a:buf, 'channel'), 'comrade_quick_fix',
                        \ {'buf' : a:buf, 'insight' : a:insight, 'fix' : a:fix}])
            if !empty(result)
                call comrade#util#TruncatedEcho(result)
            endif
        catch /./ " The channel has been probably closed
            call comrade#util#TruncatedEcho('Failed to send completion request to JetBrains instance. \n' . v:exception)
            call comrade#bvar#remove(a:buf, 'channel')
        endtry
    endif
    return []
endfunction
