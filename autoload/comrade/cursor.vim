" Based on ALE cursor.vim

let g:comrade_echo_delay = get(g:, 'comrade_echo_delay', 10)

let s:cursor_timer = -1
let s:last_pos = [0, 0, 0]

function! s:StopCursorTimer() abort
    if s:cursor_timer != -1
        call timer_stop(s:cursor_timer)
        let s:cursor_timer = -1
    endif
endfunction

function! comrade#cursor#EchoCursorWarningWithDelay() abort
    let l:buffer = bufnr('')

    " Only echo the warnings in normal mode, otherwise we will get problems.
    if mode(1) isnot# 'n'
        return
    endif

    call s:StopCursorTimer()

    let l:pos = getpos('.')[0:2]

    " Check the current buffer, line, and column number against the last
    " recorded position. If the position has actually changed, *then*
    " we should echo something. Otherwise we can end up doing processing
    " the echo message far too frequently.
    if l:pos != s:last_pos
        let l:delay = g:comrade_echo_delay

        let s:last_pos = l:pos
        let s:cursor_timer = timer_start(
        \   l:delay,
        \   function('comrade#cursor#EchoCursorWarning')
        \)
    endif
endfunction

function! s:FindInsightAtCursor(buffer)
    let l:insight_map = comrade#bvar#get(a:buffer, 'insight_map')
    if empty(l:insight_map)
        return 0
    endif

    let l:pos = getpos('.')
    let l:line = l:pos[1] - 1
    let l:col = l:pos[2]
    if !has_key(l:insight_map, l:line)
        return 0
    endif
    let l:list = l:insight_map[l:line]
    if empty(l:list)
        return 0
    endif

    for l:insight in l:list
        if l:col >= l:insight['s_col'] && l:col <= l:insight['e_col']
            return l:insight
        endif
    endfor
    return l:list[0]
endfunction

function! comrade#cursor#EchoCursorWarning(...) abort
    let l:buffer = bufnr('')

    " Only echo the warnings in normal mode, otherwise we will get problems.
    if mode(1) isnot# 'n'
        return
    endif

    let l:insight = s:FindInsightAtCursor(l:buffer)

    if !empty(l:insight)
        let l:desc = l:insight['desc']
        call comrade#util#TruncatedEcho(l:desc)
        call comrade#bvar#set(buffer, 'echoed', 1)
    elseif comrade#bvar#get(buffer, 'echoed')
        " We'll only clear the echoed message when moving off errors once,
        " so we don't continually clear the echo line.
        execute 'echo'
        call comrade#bvar#set(buffer, 'echoed', 0)
    endif

endfunction
