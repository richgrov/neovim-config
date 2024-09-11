set number
set relativenumber
set tabstop=3
set shiftwidth=3

" https://vimtricks.com/p/vimtrick-moving-lines/
nnoremap <C-j> :m .+1<CR>==
nnoremap <C-k> :m .-2<CR>==
inoremap <C-j> <Esc>:m .+1<CR>==gi
inoremap <C-k> <Esc>:m .-2<CR>==gi
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv

autocmd BufNewFile,BufRead *.ino :set filetype=cpp

let g:prettier#autoformat = 1
let g:prettier#autoformat_require_pragma = 0
