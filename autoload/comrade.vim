function! comrade#SetInsights(buf, loc_list)
    call comrade#sign#SetSigns(a:buf, a:loc_list)
    call comrade#highlight#SetHighlights(a:buf, a:loc_list)
endfunction