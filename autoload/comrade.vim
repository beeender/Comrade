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
    call setbufvar(a:buf, 'comrade_insight_map', a:insight_map)
    call comrade#sign#SetSigns(a:buf)
    call comrade#highlight#SetHighlights(a:buf)
endfunction
