#!/usr/bin/env bash

# general START

if [ -d /project/scripts ]; then chmod -R +x /project/scripts; fi
if [ -f /project/provision/provision.sh ]; then chmod +x /project/provision/provision.sh; fi

mkdir -p ~/logs

if [ ! -f ~/.check-files/basic-packages ]; then
  echo "installing basic packages"
  sudo apt-get update
  sudo apt-get install -y build-essential python-software-properties
  mkdir -p ~/.check-files && touch ~/.check-files/basic-packages
fi

if ! type git > /dev/null 2>&1 ; then
  sudo apt-get install -y git git-extras
  git config --global user.email "foo@bar.com" && \
    git config --global user.name "Foo Bar" && \
    git config --global core.editor "vim"
fi

install_apt_package() {
  PACKAGE="$1"
  if [[ ! -z "$2" ]]; then CMD_CHECK="$2"; else CMD_CHECK="$1"; fi
  if ! type "$CMD_CHECK" > /dev/null 2>&1 ; then
    echo "doing: sudo apt-get install -y $PACKAGE"
    sudo apt-get install -y "$PACKAGE"
  fi
}

install_apt_package moreutils vidir
install_apt_package exuberant-ctags ctags
install_apt_package unzip
install_apt_package curl
install_apt_package tree
install_apt_package entr
install_apt_package htop
install_apt_package jq
install_apt_package ncdu

if [ ! -f ~/.acd_func ]; then
  curl -o ~/.acd_func \
    https://raw.githubusercontent.com/djoot/all-bash-history/master/acd_func.sh
fi

# shellcheck (without using stack, it takes a while to install)
  # if [ ! -f ~/.cabal/bin/shellcheck ]; then
  #   echo "installing shellcheck without using stack"
  #   sudo apt-get install -y cabal-install
  #   cabal update
  #   cabal install shellcheck
  # fi

if [ ! -d ~/src ]; then
  if [ -d /project/src ]; then cp -r /project/src ~; fi
fi

cat > ~/.bash_sources <<"EOF"
source_if_exists() {
  FILE_PATH=$1
  if [ -f $FILE_PATH ]; then source $FILE_PATH; fi
}

source_if_exists ~/.acd_func
source_if_exists ~/.bash_aliases
EOF

cat > ~/.bashrc <<"EOF"
# move from word to word. avoid ctrl+b to use in tmux
  bind '"\C-g":vi-fWord' > /dev/null 2>&1
  bind '"\C-f":vi-bWord' > /dev/null 2>&1

stty -ixon # prevent the terminal from hanging on ctrl+s

export HISTCONTROL=ignoreboth:erasedups
export EDITOR=vim

if [[ -z $TMUX ]]; then
  TMUX_PREFIX_A="" && TMUX_PREFIX_B="·"
else
  TMUX_PREFIX_A="{$(tmux display-message -p '#I')} " && TMUX_PREFIX_B="£"
fi
get_jobs_prefix() {
  JOBS=$(jobs | wc -l)
  if [ "$JOBS" -eq "0" ]; then echo ""; else echo "[$JOBS] "; fi
}
PS1_BEGINNING="\n\[\e[34m\]\u\[\e[m\].\[\e[34m\]\h\[\e[m\]:\[\e[36m\] \W\[\e[m\]"
PS1_MIDDLE="\[\e[32m\]\$(__git_ps1)\[\e[m\]\[\e[33m\] \$(get_jobs_prefix)$TMUX_PREFIX_A\[\e[m\]"
PS1_END="\[\e[32m\]$TMUX_PREFIX_B\[\e[m\] "
export PS1="$PS1_BEGINNING""$PS1_MIDDLE""$PS1_END"

export PATH=$PATH:/project/scripts
export PATH=$PATH:/project/provision
export PATH=$PATH:~/.local/bin
export PATH=$PATH:~/.cabal/bin

source ~/.bash_sources

if [ "$(pwd)" = "/home/$USER" ]; then
  if [ -d ~/src ]; then cd ~/src; fi
fi
EOF

cat > ~/.bash_aliases <<"EOF"
alias cp="cp -r"
alias ll="ls -lah"
alias mkdir="mkdir -p"
alias rm="rm -rf"

DisplayFilesConcatenated(){ xargs tail -n +1 | sed "s|==>|\n\n\n\n\n$1==>|; s|<==|<==\n|" | $EDITOR -; }
Find() { find "$@" ! -path "*node_modules*" ! -path "*.git*"; }
GetProcessUsingPort(){ fuser $1/tcp; }
MkdirCd(){ mkdir -p $1; cd $1; }
Popd(){ popd -n +"$1" > /dev/null; cd --; }
alias AliasesReload='source ~/.bash_aliases'
alias ConfigureTimezone='sudo dpkg-reconfigure tzdata'
alias EditProvision="$EDITOR /project/provision/provision.sh && provision.sh"
alias Exit="killall tmux > /dev/null 2>&1 || exit"
alias Tmux="tmux; exit"

alias GitStatus='git status -u'
GitAdd() { git add -A $@; GitStatus; }
GitResetLastCommit() { LAST_COMMIT_MESSAGE=$(git log -1 --pretty=%B); \
  git reset --soft HEAD^; git add -A .; git commit -m "$LAST_COMMIT_MESSAGE"; }
alias GitAddAll='GitAdd .'
alias GitCommit='git commit -m'
alias GitEditorCommit='git commit -v'

UpdateSrc() {
  rm -rf /project/src
  rsync -av \
    --exclude='*node_modules*' \
    ~/src /project
}
EOF

cat > ~/.inputrc <<"EOF"
set show-all-if-ambiguous on
C-h:unix-filename-rubout
EOF

cat > ~/.tmux.conf <<"EOF"
set -g status off
set-window-option -g xterm-keys on

bind-key S-Left swap-window -t -1
bind-key S-Right swap-window -t +1
EOF

# general END

# vim START

install_vim_package() {
  REPO=$1
  DIR=$(echo $REPO | sed -r "s|.+/(.+)|\1|") # foo/bar => bar
  EXTRA_CMD=$2
  if [ ! -d ~/.vim/bundle/"$DIR" ]; then
    git clone https://github.com/$REPO.git ~/.vim/bundle/"$DIR"
    if [[ ! -z $EXTRA_CMD ]]; then eval $EXTRA_CMD; fi
  fi
}

mkdir -p ~/.vim/autoload/ ~/.vim/bundle
if [ ! -f ~/.vim/autoload/pathogen.vim ]; then
  curl https://raw.githubusercontent.com/tpope/vim-pathogen/master/autoload/pathogen.vim \
    > ~/.vim/autoload/pathogen.vim
fi

if ! type nvim > /dev/null 2>&1 ; then
  echo "installing neovim"
  sudo add-apt-repository -y ppa:neovim-ppa/unstable
  sudo apt-get update && sudo apt-get install -y neovim
  sudo apt-get install -y python3-pip
  sudo pip3 install neovim
  mkdir -p ~/.config
  rm -rf ~/.config/nvim
  ln -s ~/.vim ~/.config/nvim
  ln -s ~/.vimrc ~/.config/nvim/init.vim
  git config --global core.editor "nvim"
fi

install_vim_package airblade/vim-gitgutter
install_vim_package ctrlpvim/ctrlp.vim
install_vim_package easymotion/vim-easymotion
install_vim_package elzr/vim-json
install_vim_package evidens/vim-twig
install_vim_package haya14busa/incsearch.vim
install_vim_package honza/vim-snippets
install_vim_package jelera/vim-javascript-syntax
install_vim_package jiangmiao/auto-pairs
install_vim_package luochen1990/rainbow
install_vim_package mbbill/undotree
install_vim_package milkypostman/vim-togglelist
install_vim_package ntpeters/vim-better-whitespace
install_vim_package plasticboy/vim-markdown
install_vim_package scrooloose/nerdcommenter
install_vim_package scrooloose/syntastic
install_vim_package shougo/deoplete.nvim # :UpdateRemotePlugins
install_vim_package shougo/neosnippet.vim
install_vim_package shougo/vimproc.vim "cd ~/.vim/bundle/vimproc.vim && make; cd -"
install_vim_package takac/vim-hardtime
install_vim_package terryma/vim-expand-region
install_vim_package tpope/vim-fugitive
install_vim_package tpope/vim-repeat
install_vim_package tpope/vim-surround
install_vim_package vim-airline/vim-airline
install_vim_package vim-airline/vim-airline-themes
install_vim_package vim-ruby/vim-ruby
install_vim_package vim-scripts/cream-showinvisibles
install_vim_package yggdroot/indentLine

echo 'Control-x: " fg\n"' >> ~/.inputrc

cat > ~/.vimrc <<"EOF"
execute pathogen#infect()
filetype plugin indent on
syntax on
set background=dark

let mapleader = "\<Space>"
let g:hardtime_default_on = 1

" disable mouse to be able to select + copy
  set mouse-=a

" buffers
  nnoremap <F10> :buffers<CR>:buffer<Space>
  nnoremap <silent> <F12> :bn<CR>
  nnoremap <silent> <S-F12> :bp<CR>

" don't copy when using del
  vnoremap <Del> "_d
  nnoremap <Del> "_d

" numbers maps
  set relativenumber
  nnoremap <leader>h :set relativenumber!<CR>

" open file in same dir
  map ,e :e <C-R>=expand("%:p:h") . "/" <CR>

" replace selection
  vmap <leader>g y:%s/\C<C-r>"//g<left><left>

" prevent saving backup files
  set nobackup
  set noswapfile

" support all hex colors (e.g. for syntastic)
  set  t_Co=256

" incsearch.vim
  map /  <Plug>(incsearch-forward)
  map ?  <Plug>(incsearch-backward)
  map g/ <Plug>(incsearch-stay)

" move lines up and down
  nnoremap <C-j> :m .+1<CR>==
  nnoremap <C-k> :m .-2<CR>==
  inoremap <C-j> <Esc>:m .+1<CR>==gi
  inoremap <C-k> <Esc>:m .-2<CR>==gi
  vnoremap <C-j> :m '>+1<CR>gv=gv
  vnoremap <C-k> :m '<-2<CR>gv=gv

" remove trailing spaces
  nmap <leader>t :%s/\s\+$<CR><C-o>

" folding
  set foldmethod=indent
  set nofoldenable
  set fml=0
  set nowrap
  hi Folded ctermbg=236

" improve indentation
  xnoremap <Tab> >gv
  xnoremap <S-Tab> <gv

" to easily copy with the mouse
  nnoremap <leader>n :set number!<CR>:GitGutterToggle<CR>

" fix c-b mapping to use with tmux (one page up)
  nnoremap <C-d> <c-b>

set nohlsearch
set autoindent
set clipboard=unnamedplus
set cursorline
set expandtab
set number
set shiftwidth=2
set softtabstop=2
set tabstop=2
set smartcase
set wildmenu

" better completion menu colors
  highlight Pmenu ctermfg=white ctermbg=17
  highlight PmenuSel ctermfg=white ctermbg=29

" better matching color
  hi MatchParen ctermfg=black

" ignore case in searches
  set ic

nnoremap <C-w>v :vsplit<CR><C-w><right>
nnoremap <leader>w :set wrap!<CR>

" airline
  set laststatus=2
  let g:airline_left_sep=''
  let g:airline_right_sep=''

" remove autoindentation when pasting
  set pastetoggle=<F2>

" deoplete
  let g:deoplete#enable_at_startup = 1

let g:NERDSpaceDelims = 1
let g:rainbow_active = 1
let g:vim_json_syntax_conceal = 0
let g:vim_markdown_conceal = 0
let g:vim_markdown_folding_disabled = 1

" ctrlp
  let g:ctrlp_map = '<c-p>'
  let g:ctrlp_cmd = 'CtrlP'
  let g:ctrlp_show_hidden = 1
  let g:ctrlp_custom_ignore = '\v[\/](node_modules|target|dist)|(\.(swp|ico|git|svn))$'
  nnoremap <leader>p :CtrlP %:p:h<CR> " CtrlP in file's dir

" syntastic
  set statusline+=%#warningmsg#
  set statusline+=%{SyntasticStatuslineFlag()}
  set statusline+=%*
  let g:syntastic_always_populate_loc_list = 1
  let g:syntastic_auto_loc_list = 1
  let g:syntastic_check_on_open = 1
  let g:syntastic_check_on_wq = 0
  let g:syntastic_javascript_checkers = ['eslint']
  let g:syntastic_typescript_checkers = ['tsc', 'tslint']
  let g:syntastic_scss_checkers = ['stylelint']
  let g:syntastic_json_checkers=[]
  highlight link SyntasticErrorSign SignColumn
  highlight link SyntasticWarningSign SignColumn
  highlight link SyntasticStyleErrorSign SignColumn
  highlight link SyntasticStyleWarningSign SignColumn
  let g:syntastic_error_symbol = '❌'
  let g:syntastic_style_error_symbol = '⁉️'
  hi Error ctermbg=lightred ctermfg=black
  hi SpellBad ctermbg=lightred ctermfg=black
  nnoremap <leader>o :SyntasticToggleMode<CR>

map ,e :e <C-R>=expand("%:p:h") . "/" <CR>
au BufNewFile,BufRead *.ejs set filetype=html

" move up/down from the beginning/end of lines
  set ww+=<,>

" change to current file directory
  nnoremap ,cd :cd %:p:h<CR>:pwd<CR>

" run macro on d
  nnoremap <leader>d @d

" sort lines
  vmap <F3> :sort<CR>

inoremap <C-e> <Esc>A
inoremap <C-a> <Esc>I

" vp doesn't replace paste buffer
  function! RestoreRegister()
    let @" = s:restore_reg
    return ''
  endfunction
  function! s:Repl()
    let s:restore_reg = @"
    return "p@=RestoreRegister()\<cr>"
  endfunction
  vmap <silent> <expr> p <sid>Repl()

" neosnippet
  imap <C-l>     <Plug>(neosnippet_expand_or_jump)
  smap <C-l>     <Plug>(neosnippet_expand_or_jump)
  xmap <C-l>     <Plug>(neosnippet_expand_target)
  imap <expr><TAB>
   \ pumvisible() ? "\<C-n>" :
   \ neosnippet#expandable_or_jumpable() ?
   \    "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
  smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
   \ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
  if has('conceal')
    set conceallevel=2 concealcursor=niv
  endif
  let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets'
  let g:neosnippet#disable_runtime_snippets={'c' : 1, 'cpp' : 1,}

" save file shortcuts
  nmap <C-s> :update<Esc>
  inoremap <C-s> <Esc>:update<CR>

" copy - paste between files and vms
  vmap <leader>fy :w! /vm-shared/_vitmp<CR>
  nmap <leader>fp :r! cat /vm-shared/_vitmp<CR>
  vmap <leader>fp d:r! cat /vm-shared/_vitmp<CR>

" fast grep
  vnoremap <leader>b y:tabnew\|te clear;
  \ Grep() { grep -rin --color=always "$@"; printf "\n\n\n----\n\n\n"; grep --color=always -ril "$@"; }
  \ && Grep "" \| less -R<left><left><left><left><left><left><left><left><left><left><left><C-r>"<right><right>

" improve the 'preview window' behaviour
  autocmd CompleteDone * pclose " close when done
  set splitbelow " move to the bottom

" vim-expand-region
  vmap v <Plug>(expand_region_expand)
  vmap <C-v> <Plug>(expand_region_shrink)

" search and replace (using cs on first match and n.n.n.)
  vnoremap <silent> s //e<C-r>=&selection=='exclusive'?'+1':''<CR><CR>
      \:<C-u>call histdel('search',-1)<Bar>let @/=histget('search',-1)<CR>gv
  omap s :normal vs<CR>

" autocmd Filetype sh setlocal softtabstop=2 tabstop=2 shiftwidth=2

" quickly move to lines
  nnoremap <CR> G
  nnoremap <BS> gg
" undo tree
  nnoremap <leader>m :UndotreeShow<CR><C-w><left>

" tabs
  nnoremap <leader>1 1gt
  nnoremap <leader>2 2gt
  nnoremap <leader>3 3gt
  nnoremap <leader>4 4gt
  nnoremap <leader>5 5gt
  nnoremap <leader>6 6gt
  nnoremap <leader>7 7gt
  nnoremap <leader>8 8gt
  nnoremap <leader>9 9gt
  nnoremap <C-h> :execute "tabmove" tabpagenr() - 2 <CR>
  nnoremap <C-l> :execute "tabmove" tabpagenr() + 1 <CR>
  nnoremap <C-t> :tabnew<CR>
  nnoremap <C-d> :tabclose<CR>
  hi TabLine ctermfg=gray ctermbg=black
  hi TabLineFill ctermfg=black ctermbg=black
  " Rename tabs to show tab number.
  if exists("+showtabline")
      function! MyTabLine()
          let s = ''
          let wn = ''
          let t = tabpagenr()
          let i = 1
          while i <= tabpagenr('$')
              let buflist = tabpagebuflist(i)
              let winnr = tabpagewinnr(i)
              let s .= '%' . i . 'T'
              let s .= (i == t ? '%1*' : '%2*')
              let s .= ' '
              let wn = tabpagewinnr(i,'$')

              let s .= '%#TabNum#'
              let s .= i
              " let s .= '%*'
              let s .= (i == t ? '%#TabLineSel#' : '%#TabLine#')
              let bufnr = buflist[winnr - 1]
              let file = bufname(bufnr)
              let buftype = getbufvar(bufnr, 'buftype')
              if buftype == 'nofile'
                  if file =~ '\/.'
                      let file = substitute(file, '.*\/\ze.', '', '')
                  endif
              else
                  let file = fnamemodify(file, ':p:t')
              endif
              if file == ''
                  let file = '[No Name]'
              endif
              let s .= ' ' . file . ' '
              let i = i + 1
          endwhile
          let s .= '%T%#TabLineFill#%='
          let s .= (tabpagenr('$') > 1 ? '%999XX' : 'X')
          return s
      endfunction
      set stal=2
      set tabline=%!MyTabLine()
      set showtabline=1
      highlight link TabNum Special
  endif
EOF

cat >> ~/.bashrc <<"EOF"
export EDITOR=nvim
export TERM=xterm-256color
source ~/.bash_aliases # some aliases depend on $EDITOR
EOF

cat >> ~/.bash_aliases <<"EOF"
alias nv='nvim'
EOF

# vim END

# js START

NODE_VERSION=6.3.0
if [ ! -f ~/.check-files/node ]; then
  echo "setup node with nodenv"
  cd ~
  sudo add-apt-repository -y ppa:chris-lea/node.js && \
    sudo apt-get update && \
    sudo curl -O -L https://npmjs.org/install.sh | sh && \
    if [ ! -d ~/.nodenv ]; then git clone https://github.com/nodenv/nodenv.git ~/.nodenv && cd ~/.nodenv && src/configure && make -C src; fi && \
    export PATH=$PATH:/home/$USER/.nodenv/bin && \
    eval "$(nodenv init -)" && \
    if [ ! -d ~/.nodenv/plugins/node-build ]; then git clone https://github.com/nodenv/node-build.git $(nodenv root)/plugins/node-build; fi && \
    if [ ! -d .nodenv/versions/$NODE_VERSION ]; then nodenv install $NODE_VERSION; fi && \
    nodenv global $NODE_VERSION && \
    mkdir -p ~/.check-files && touch ~/.check-files/node
  rm -f ~/install.sh
fi

install_node_modules() {
  for MODULE_NAME in "$@"; do
    if [ ! -d ~/.nodenv/versions/$NODE_VERSION/lib/node_modules/$MODULE_NAME ]; then
      echo "doing: npm i -g $MODULE_NAME"
      npm i -g $MODULE_NAME
    fi
  done
}

install_node_modules http-server diff-so-fancy yarn

cat >> ~/.bashrc <<"EOF"

export PATH=$PATH:/home/$USER/.nodenv/bin
export PATH=$PATH:/home/$USER/.nodenv/versions/6.3.0/bin/
eval "$(nodenv init -)"
source <(npm completion)
EOF

cat >> ~/.bash_aliases <<"EOF"

alias Serve="http-server -c-1 -p 9000"
GitDiff() { git diff --color $@ | diff-so-fancy | less -R; }
EOF

# not installing vim-javascript as it doesn't work with rainbow
install_vim_package kchmck/vim-coffee-script
install_vim_package leafgarland/typescript-vim
install_vim_package quramy/tsuquyomi

cat >> ~/.vimrc <<"EOF"

" quick console.log (use s to replace and the . to repeat)
  let ConsoleMapping="nnoremap <leader>k iconsole.log('a', a);<C-c>hhhhhh"
  autocmd FileType javascript :exe ConsoleMapping
  autocmd FileType typescript :exe ConsoleMapping
EOF

# js END

# jvm START

if ! type java > /dev/null 2>&1 ; then
  sudo add-apt-repository -y ppa:webupd8team/java
  sudo apt-get update
  echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
  sudo apt-get install -y oracle-java8-installer
fi

if [ ! -d /usr/local/lib/elasticsearch ]; then
  ELASTIC=elasticsearch-5.0.1
  ELASTIC_FILE="$ELASTIC".tar.gz
  cd ~
  curl -L -O https://artifacts.elastic.co/downloads/elasticsearch/$ELASTIC_FILE
  tar -xvf $ELASTIC_FILE
  rm $ELASTIC_FILE
  sudo mv $ELASTIC /usr/local/lib/elasticsearch
fi
echo "export PATH=\$PATH:/usr/local/lib/elasticsearch/bin/" >> ~/.bashrc

if [ ! -d /usr/local/lib/kibana ]; then
  cd ~
  KIBANA=kibana-5.0.1-linux-x86_64
  KIBANA_FILE="$KIBANA".tar.gz
  wget https://artifacts.elastic.co/downloads/kibana/$KIBANA_FILE
  sha1sum $KIBANA_FILE
  tar -xzf $KIBANA_FILE
  mv $KIBANA kibana
  rm $KIBANA_FILE
  sudo mv kibana /usr/local/lib/
fi
echo "export PATH=\$PATH:/usr/local/lib/kibana/bin" >> ~/.bashrc
cat >> ~/.bash_aliases <<"EOF"
alias Kibana='kibana -H 0.0.0.0'
EOF

# jvm END

# custom START

cat >> ~/.vimrc <<"EOF"
let g:hardtime_default_on = 0
EOF

cat >> ~/.bash_aliases <<"EOF"
alias ModifySrcReadme='nvim ~/src/Readme.md'
GitDiff() { git add -A .; git diff HEAD; } # replace alias to avoid mistakes
GitReset() { git reset --hard $@ ; git clean -fd :/; }
GitApply() { GitReset; git apply $1; }
EOF

if [ ! -d ~/repository ]; then
  cd ~
  git clone https://github.com/balderdashy/sails.git repository
  cd repository
  git reset --hard 35d30a5534570f
  npm i
fi

# custom END

echo "finished provisioning"
