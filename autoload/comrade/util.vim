"=============================================================================
" AUTHOR:  beeender <chenmulong at gmail.com>
" License: GPLv3
"=============================================================================

" When there are multiple lines echoed, echom will block the UI thread.
" This function will truncate the input string to one line and display
" it without input enter prompt.
" Function copied from ale.vim
function! comrade#util#TruncatedEcho(original_message) abort
    let l:message = a:original_message
    " Change tabs to spaces.
    let l:message = substitute(l:message, "\t", ' ', 'g')
    " Remove any newlines in the message.
    let l:message = substitute(l:message, "\n", '', 'g')

    " We need to remember the setting for shortmess and reset it again.
    let l:shortmess_options = &l:shortmess

    try
        let l:cursor_position = getpos('.')

        " The message is truncated and saved to the history.
        setlocal shortmess+=T

        try
            exec "norm! :echomsg l:message\n"
        catch /^Vim\%((\a\+)\)\=:E523/
            " Fallback into manual truncate (#1987)
            let l:winwidth = winwidth(0)

            if l:winwidth < strdisplaywidth(l:message)
                " Truncate message longer than window width with trailing '...'
                let l:message = l:message[:l:winwidth - 4] . '...'
            endif

            exec 'echomsg l:message'
        endtry

        " Reset the cursor position if we moved off the end of the line.
        " Using :norm and :echomsg can move the cursor off the end of the
        " line.
        if l:cursor_position != getpos('.')
            call setpos('.', l:cursor_position)
        endif
    finally
        let &l:shortmess = l:shortmess_options
    endtry
endfunction
