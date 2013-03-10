set modeline

" indention
if has("autocmd")
	filetype plugin indent on
endif

syntax on
set hlsearch
set showmatch
set autowrite

nmap <F4> :set invpaste paste?<CR>
imap <F4> <C-0> :set invpaste<CR>
set pastetoggle=<F4>

" spell checking
nmap <F5> :setlocal spell spelllang=en_us<CR>

" delete trailing whitespace at the end of each line
cmap :dtws :%s/[\ \t]\+$//<CR>
" show trailing whitespace at the end of each line
cmap :showws :/\s\+$<CR>

" jump to tag under curser
nmap <C-j> <C-]>
nmap <C-k> <C-t>

" settings for mutt
autocmd BufRead /tmp/mutt* set ft=mail
autocmd BufRead /tmp/mutt* set syntax=mail

" avoid UTF-8 problems
set encoding=utf-8

" automatically remove trailing whitespace before saving
" http://vim.wikia.com/wiki/Remove_unwanted_spaces
autocmd FileType c,cpp,h,hpp,java,php,pl,py,rb,sh autocmd BufWritePre <buffer> :call setline(1,map(getline(1,"$"),'substitute(v:val,"\\s\\+$","","")'))

" set syntax file for protocol buffers
augroup filetype
	au! BufRead,BufNewFile *.proto setfiletype proto
augroup end

"colorscheme pablo
"colorscheme robinhood
"colorscheme xemacs
colorscheme jellybeans
