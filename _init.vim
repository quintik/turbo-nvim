" === init ====================================================================
set showmatch              " Show matching brackets
set ignorecase             " Case insensitive matching
set hlsearch               " Highlight search results
set tabstop=4              " Number of columns occupied by a tab character
set softtabstop=4          " Set multiple spaces as tabstops
set expandtab              " Converts tabs to whitespace
set shiftwidth=4           " Width for autoindents
set autoindent             " Indent new line the same as the last line
set number                 " Add line numbers
set ruler                  " Show cursor position in default statusline
set cc=80                  " Set color column for cleaner code
set wildmode=longest,list  " Get bash-like tab completions
set termguicolors          " Use 24-bit RGB colors (see :help tgc)
set cursorline             " Highlight current line
set notitle                " Do not set terminal title
set nowrap                 " Do not wrap lines by default
set laststatus=2           " Always show statusline
set showtabline=0          " Always show tabline
set spelllang=en_gb        " Set spelling language
set complete+=k            " Enable dictionary words in completion list
set list                   " Show trailing whitespace
set ff=unix                " Use unix file endings

" Save undo tree
set undofile
execute "set undodir=" . stdpath("config") . "/undo/"

filetype plugin indent on  " Allow autoindenting depending on filetype
syntax on                  " Syntax highlighting

" === Mappings & Commands =====================================================

" Use space/backspace to repeat f/F/t/T motions
nnoremap <Space> ;
nnoremap <BS> ,

" Enter to insert new line without leaving normal
nnoremap <Enter> o<Esc>

" Avoid having to press shift all the time
nnoremap ; :

" Use Esc to exit terminal-insert mode
tmap <Esc> <C-\><C-n>

" Window sizes
" Up/Down: +/- height
" Right/Left: +/- width
nnoremap <Up> <C-W>+
nnoremap <Down> <C-W>-
nnoremap <Left> <C-W><
nnoremap <Right> <C-W>>

" === Other stuff =============================================================

" Highlighting for ejs files
autocmd BufNewFile,BufRead *.ejs set filetype=html

" Allow Snip to parse larger files
set maxfuncdepth=200

" TeX options
let g:tex_flavor   = "latex"
let g:tex_viewer   = "SumatraPDF.exe"
let g:tex_conceal  = "d"
let g:tex_preamble = stdpath("config") . "ftplugin/tex/preamble.tex"

" === Plugins =================================================================

lua << EOF
require "jet"

-- My own plugins
Jet.pack "quintik" {
    { name = "jet",
      uri  = "git@github.com:quintik/jet-nvim" },

    { uri = "git@github.com:quintik/onedark-minimal",
      cfg = function() vim.cmd("colorscheme onedark-minimal") end },

    { uri = "git@github.com:quintik/Snip",
      opt = true }
}

-- Nvim stuff
Jet.pack "nvim" {
    { name = "treesitter",
      uri  = "git@github.com:nvim-treesitter/nvim-treesitter",
      cfg  = function() require "config/treesitter" end },

    { name = "lspconfig",
      uri  = "git@github.com:neovim/nvim-lspconfig",
      opt  = true,
      on   = { "CmdUndefined" },
      pat  = { "LspStart" },
      cfg  = function() require "config/lsp" end }
}

-- Misc. plugins
Jet.pack "misc" { "git@github.com:ervandew/supertab" }

EOF

set statusline=\ %n\ │\ %f\ │\ %m%r%h%=%y\ │\ %l:%c\ 
highlight StatusLine   guifg=#91B1F1 guibg=#202020
highlight StatusLineNC guifg=#818181 guibg=#202020
