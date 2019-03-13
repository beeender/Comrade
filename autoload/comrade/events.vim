
function! comrade#events#Init() abort
    augroup ComradeEvents
        autocmd!

        autocmd BufEnter * call comrade#buffer#Notify()
        autocmd BufDelete * call comrade#buffer#UnregisterCurrent()

        autocmd CursorMoved,CursorHold * call comrade#cursor#EchoCursorWarningWithDelay()
        " Look for a warning to echo as soon as we leave Insert mode.
        " The script's position variable used when moving the cursor will
        " not be changed here.
        autocmd InsertLeave * call comrade#cursor#EchoCursorWarning()
    augroup END
endfunction