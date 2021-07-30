" === TeX =====================================================================

" === Editor commands
command! -buffer -nargs=0 Open      call s:open()
command! -buffer -nargs=0 Build     call s:build()
command! -buffer -nargs=0 SetMain   let s:tex_maindoc=expand("%")
command! -buffer -nargs=0 OpenHere  call s:open(expand("%:p"))
command! -buffer -nargs=0 BuildHere call s:build(expand("%:p"))

command! -range -buffer -nargs=0 Glance <line1>,<line2>call s:preview()

" === Options
let g:tex_viewer   = exists("g:tex_viewer") ? g:tex_viewer : ""
let g:tex_preamble = exists("g:tex_preamble") ? g:tex_preamble : ""

" =============================================================================

" First arg is the file to open. If
" no arg is given, then it uses the
" main doc. If no main doc is set,
" then it defaults to the current
" buffer.
function! s:open(...) abort
    if g:tex_viewer ==# ""
        echo "No viewer set!"
        return
    endif

    if a:0 > 0
        let l:fpath = a:1
    elseif exists("s:tex_maindoc")
        let l:fpath = s:tex_maindoc
    else
        let l:fpath = expand("%:p")
    endif

    " Get the outpath for the file and change extension to pdf
    let l:file = fnamemodify(l:fpath, ":s?src?out?:rp") . ".pdf"
    let l:cmd  = g:tex_viewer . " " . l:file

    call jobstart(l:cmd, {"detach": 1})
endfunction

" First arg is the file to build. If
" no arg is given, then it uses the
" main doc. If no main doc is set,
" then it defaults to the current
" buffer.
function! s:build(...) abort
    if a:0 > 0
        let l:fpath = a:1
    elseif exists("s:tex_maindoc")
        let l:fpath = s:tex_maindoc
    else
        let l:fpath = expand("%:p")
    endif

    " Get source file absolute path (and remove extension)
    let l:srcfile = fnamemodify(l:fpath, ":p")
    " Replace src/ with aux/ (and remove filename)
    let l:auxpath = fnamemodify(l:fpath, ":s?src?bin?:hp")
    " Replace src/ with out/ (and remove filename)
    let l:outpath = fnamemodify(l:fpath, ":s?src?out?:hp")
    " Obtain absolute path to source file's directory
    let l:incpath = fnamemodify(l:fpath, ":hp")

    let l:exe = "pdflatex"
    let l:aux = " --aux-directory=" . l:auxpath
    let l:out = " --output-directory=" . l:outpath
    let l:inc = " --include-directory=" . l:incpath

    let l:cmd = l:exe . l:aux . l:out . l:inc . " " . l:srcfile

    echo "Compiling..."
    let l:output = split(system(l:cmd), "\n")

    return s:printFormatted(l:output)
endfunction

" Prints errors/warnings from given pdflatex output
" Returns 1 if no errors or warnings, 0 otherwise.
function! s:printFormatted(output) abort
    " Clear previous output
    redraw

    if len(a:output) <= 0
        echo "No output available."
        return 1
    endif

    " Only keep important lines
    call filter(a:output,
        \ {idx, val ->
        \ match(val, "!") == 0 ||
        \ match(val, "l\\.") == 0 })

    if len(a:output) <= 0
        echo "Finished compiling."
        return 1
    endif

    echom "Errors/Warnings:"
    for line in a:output
        echom line
    endfor

    return 0
endfunction


" Returns path to a temp tex file
" for the preview method, and creates
" the necessary directories.
function! s:get_tmpfile() abort
    if exists("s:tmpfile")
        return s:tmpfile
    else
        let l:tmpdir = fnamemodify(tempname(), ":h") . "/src"
        call mkdir(l:tmpdir, "p")

        let s:tmpfile = fnamemodify(l:tmpdir . "/preview.tex", ":p")
        return s:tmpfile
    endif
endfunction

" Builds selected range (or by
" default the current line) and
" opens it for preview.
function! s:preview() range
    if filereadable(g:tex_preamble)
        let l:preamble = readfile(g:tex_preamble)
    else
        let l:preamble = []
    endif

    let l:src = []
    for line in range(a:firstline, a:lastline)
        call add(l:src, getline(line))
    endfor

    let l:raw = ["\\documentclass{article}", ""]
    call extend(l:raw, l:preamble)
    call extend(l:raw, ["\\begin{document}", ""])
    call extend(l:raw, l:src)
    call extend(l:raw, ["", "\\end{document}", ""])

    let l:file = s:get_tmpfile()
    call writefile(l:raw, l:file)

    let l:successful = s:build(l:file)
    if l:successful
        call s:open(l:file)
    endif
endfunction

