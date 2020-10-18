fu! comrade#insight_jump#Jump(direction, ...) abort
  try
    let s:curLine = getpos('.')[1]
    let s:curCol = getpos('.')[2]
    let s:insightMap = comrade#bvar#get(bufnr(''), 'insight_map')

    call s:ResetNearestLocation(a:direction)
    call s:FindNearestLine(a:direction)

    if s:curLine != s:nearestLine
      call s:SetStartCountingCol(a:direction)
    endif

    call s:FindNearestCol(a:direction)

    if s:nearestCol == 0 || s:nearestCol == 9999 && s:curLine == s:nearestLine
      call s:SetNewStartLine(a:direction)
      call s:SetStartCountingCol(a:direction)
      call s:ResetNearestLocation(a:direction)
      call s:FindNearestLine(a:direction)
      call s:FindNearestCol(a:direction)
    end

    call cursor(s:nearestLine, s:nearestCol)
  catch /^Vim\%((\a\+)\)\=:E716/
    " Catch error Key not present in Dictionary: 9998
    " When reach the end of file
  endtry
endfu

fu! s:FindNearestCol(direction) abort
  for l:insight in s:insightMap[s:nearestLine - 1]
    let l:sCol = l:insight['s_col'] + 1
    let l:eCol = l:insight['e_col'] + 1

    if a:direction == 'before'
      let l:delta = s:curCol - l:sCol
    else
      let l:delta = l:sCol - s:curCol
    endif

    if l:delta < 0
      continue
    endif

    if a:direction == 'before' && s:curCol - s:nearestCol > l:delta
      if s:nearestCol <= s:curCol && s:curCol <= l:eCol
        continue
      endif

      let s:nearestCol = l:sCol
    elseif a:direction == 'after' && s:nearestCol - s:curCol > l:delta
      if l:sCol <= s:curCol && s:curCol <= l:eCol
        continue
      endif

      let s:nearestCol = l:sCol
    endif
  endfor

endfu

fu! s:FindNearestLine(direction) abort
  for l:line in keys(s:insightMap)
    for l:insight in s:insightMap[l:line]
      let l:sLine = l:insight['s_line'] + 1

      if a:direction == 'before'
        let l:delta = s:curLine - l:sLine
      else
        let l:delta = l:sLine - s:curLine
      endif

      if l:delta < 0
        continue
      endif

      if a:direction == 'before' && s:curLine - s:nearestLine > l:delta
        let s:nearestLine = l:sLine
      elseif a:direction == 'after' && s:nearestLine - s:curLine > l:delta
        let s:nearestLine = l:sLine
      endif
    endfor
  endfor
endfu

fu! s:ResetNearestLocation(direction)
  if a:direction == 'before'
    let s:nearestLine = 0
    let s:nearestCol = 0
  else
    let s:nearestLine = 9999
    let s:nearestCol = 9999
  endif
endfu

fu! s:SetStartCountingCol(direction)
  if a:direction == "before"
    let s:curCol = 9999
  else
    let s:curCol = 0
  end
endfu

fu! s:SetNewStartLine(direction)
  if a:direction == "before"
    let s:curLine = s:curLine - 1
  else
    let s:curLine = s:curLine + 1
  end
endfu
