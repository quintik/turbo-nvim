" === Utils ==================================================================

" === Options
let g:utils_mru_size = exists("g:utils_mru_size") ? g:utils_mru_size : 10

" === Editor Commands
command! -nargs=0 BufClean   call BufClean()
command! -nargs=0 Rand       echo RandNr()
command! -nargs=0 InitVim    edit $MYVIMRC
command! -nargs=0 LoremIpsum put =LoremIpsum()
command! -nargs=0 MRU        call MRU()

" =============================================================================

" Show list of recently used files, excluding /tmp/
" files, and prompt which one to open.
function! MRU() abort
    let lines = split(execute("oldfiles"), "\n")
    let reindexed = []
    let index = 0

    call filter(lines, {i, v -> match(v, '^\d\+: /tmp/') < 0})
    for line in lines
        if index <= g:utils_mru_size
            call add(reindexed, substitute(line, '^\d\+: ', "", ""))
            echo index . ": " . reindexed[index]
            let index = index + 1
        else
            break
        endif
    endfor

    echo repeat("- ", 5)
    let i = input("Open file <non-digit to exit>: ")

    " check no non-digit character
    if match(i, '\D') < 0
        let n = str2nr(i)
        " check index range
        if n >= 0 && n <= g:utils_mru_size
            execute "edit " . reindexed[n]
        endif
    endif
endfunction

" Delete all buffers except current one
" Errors if a buffer is unsaved
function! BufClean() abort
    let l:cnt = 0
    for buf in getbufinfo()
        " check if buffer is active or not
        if buf.bufnr == bufnr()
            continue
        " check if buffer is listed or not
        elseif buf.listed
            let l:cnt = l:cnt + 1
            " if listed, delete it
            execute 'bd' . buf.bufnr
        endif
    endfor

    echo 'Cleaned ' . l:cnt . ' buffers'
endfunction

" gives a random number from 0-9
function! RandNr() abort
    let l:n = str2nr(matchstr(reltimestr(reltime()), '\v\.@<=\d+'))[0]
    return l:n
endfunction

function! WSLToWinPath(path)
    return ""
endfunction

function! WinToWSLPath(path)
    return ""
endfunction

function! LoremIpsum()
    let str = [ "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed",
              \ "do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
              \ "Ut enim ad minim veniam, quis nostrud exercitation ullamco",
              \ "laboris nisi ut aliquip ex ea commodo consequat. Duis aute",
              \ "irure dolor in reprehenderit in voluptate velit esse cillum",
              \ "dolore eu fugiat nulla pariatur. Excepteur sint occaecat",
              \ "cupidatat non proident, sunt in culpa qui officia deserunt",
              \ "deserunt mollit anim id est laborum."
              \ ]
    return join(str, "\n")
endfunction

