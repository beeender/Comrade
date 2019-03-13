
function! comrade#events#Init() abort
    augroup ComradeEvents
        autocmd!

        autocmd CursorMoved,CursorHold * call comrade#cursor#EchoCursorWarningWithDelay()
        " Look for a warning to echo as soon as we leave Insert mode.
        " The script's position variable used when moving the cursor will
        " not be changed here.
        autocmd InsertLeave * call comrade#cursor#EchoCursorWarning()
    augroup END
endfunction
