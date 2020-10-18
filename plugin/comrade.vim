"=============================================================================
" AUTHOR:  beeender <chenmulong at gmail.com>
" License: GPLv3
"=============================================================================

" Command definitions

" Fix the problem at the cursor
command! -nargs=0 ComradeFix call comrade#fixer#FixAtCursor()

" Jump to next/prev insight
command! -nargs=0 ComradeNextInsight call comrade#insight_jump#Jump("after")
command! -nargs=0 ComradePrevInsight call comrade#insight_jump#Jump("before")

" Init
if !exists('comrade_loaded')
    let comrade_loaded = 1
    let g:comrade_major_version = 0
    let g:comrade_minor_version = 1
    let g:comrade_patch_version = 1
    let g:comrade_version = '' . g:comrade_major_version .
                \'.' . g:comrade_minor_version .
                \'.' . g:comrade_patch_version

    let s:path = fnamemodify(resolve(expand('<sfile>:p')), ':h')
    let s:init_path = s:path . '/init.py'
    exe 'py3file' s:init_path

    call comrade#events#Init()
endif

