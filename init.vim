" Lightweight Apple Silicon Neovim config with Colemak keys + native LSP + nvim-cmp.
" Designed as a replacement for a large Coc-based init.vim.
"
" Install target:
"   ~/.config/nvim/init.vim
"
" This file intentionally does not load coc.nvim.

set nocompatible
scriptencoding utf-8

" ---------------------------------------------------------------------------
" Local switches
" ---------------------------------------------------------------------------
let g:lite_enable_mason = get(g:, 'lite_enable_mason', 1)
let g:lite_enable_copilot = get(g:, 'lite_enable_copilot', 0)
let g:lite_enable_treesitter = get(g:, 'lite_enable_treesitter', 0)
let g:lite_enable_lua_extras = get(g:, 'lite_enable_lua_extras', 0)
let g:lite_enable_file_managers = get(g:, 'lite_enable_file_managers', 0)
let g:lite_auto_install_plug = get(g:, 'lite_auto_install_plug', 1)
let g:lite_plug_url = get(g:, 'lite_plug_url', 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim')

" Put personal overrides here; it is sourced before plugins so switches work.
let s:local_vim = expand('~/.config/nvim/local.vim')
if filereadable(s:local_vim)
  execute 'source ' . fnameescape(s:local_vim)
endif

" ---------------------------------------------------------------------------
" Plugins
" ---------------------------------------------------------------------------
" Plugins are managed by vim-plug. If plug.vim is missing and
" g:lite_auto_install_plug is enabled, this config downloads plug.vim on first
" startup and then runs :PlugInstall automatically on VimEnter.
let s:plug_file = expand('~/.config/nvim/autoload/plug.vim')
let s:plug_bootstrapped = 0

function! s:InstallVimPlug() abort
  if filereadable(s:plug_file)
    echo 'vim-plug already exists: ' . s:plug_file
    return
  endif
  if !executable('curl')
    echoerr 'curl not found. Install vim-plug manually into ~/.config/nvim/autoload/plug.vim'
    return
  endif
  call mkdir(fnamemodify(s:plug_file, ':h'), 'p')
  execute 'silent !curl -fLo ' . shellescape(s:plug_file) . ' --create-dirs ' . shellescape(g:lite_plug_url)
  if v:shell_error || !filereadable(s:plug_file)
    echoerr 'Failed to install vim-plug from: ' . g:lite_plug_url
    return
  endif
  let s:plug_bootstrapped = 1
  execute 'source ' . fnameescape(s:plug_file)
  echo 'vim-plug installed. :PlugInstall will run automatically.'
endfunction

command! LiteInstallPlug call <SID>InstallVimPlug()

if !filereadable(s:plug_file) && g:lite_auto_install_plug
  call s:InstallVimPlug()
endif

if filereadable(s:plug_file)
  call plug#begin(expand('~/.config/nvim/plugged'))

  " Completion and LSP. No Coc.
  Plug 'hrsh7th/nvim-cmp'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/cmp-path'
  Plug 'hrsh7th/cmp-cmdline'
  if g:lite_enable_mason
    Plug 'mason-org/mason.nvim'
  endif

  " Stable editing and navigation from your original config.
  Plug 'theniceboy/nvim-deus'
  Plug 'theniceboy/eleline.vim', { 'branch': 'no-scrollbar' }
  Plug 'itchyny/vim-cursorword'
  Plug 'RRethy/vim-illuminate'
  Plug 'airblade/vim-rooter'
  Plug 'junegunn/fzf'
  Plug 'junegunn/fzf.vim'
  Plug 'pechorin/any-jump.vim'
  Plug 'wellle/tmux-complete.vim'
  Plug 'theniceboy/vim-snippets'

  " Git, kept lightweight.
  Plug 'theniceboy/vim-gitignore', { 'for': ['gitignore', 'vim-plug'] }
  Plug 'cohama/agit.vim'

  " Filetype support.
  Plug 'elzr/vim-json'
  Plug 'neoclide/jsonc.vim'
  Plug 'othree/html5.vim'
  Plug 'alvan/vim-closetag'
  Plug 'pangloss/vim-javascript'
  Plug 'MaxMEllon/vim-jsx-pretty'
  Plug 'leafgarland/typescript-vim'
  Plug 'peitalin/vim-jsx-typescript'
  Plug 'styled-components/vim-styled-components', { 'branch': 'main' }
  Plug 'pantharshit00/vim-prisma'
  Plug 'fatih/vim-go', { 'for': ['go', 'vim-plug'], 'tag': '*' }
  Plug 'Vimjas/vim-python-pep8-indent', { 'for': ['python', 'vim-plug'] }
  Plug 'tweekmonster/braceless.vim', { 'for': ['python', 'vim-plug'] }
  Plug 'dart-lang/dart-vim-plugin', { 'for': ['dart', 'vim-plug'] }
  Plug 'keith/swift.vim'
  Plug 'arzg/vim-swift'
  Plug 'wlangstroth/vim-racket'
  Plug 'hashivim/vim-terraform'

  " Text / Markdown.
  Plug 'dhruvasagar/vim-table-mode', { 'on': 'TableModeToggle', 'for': ['text', 'markdown', 'vim-plug'] }
  Plug 'mzlogin/vim-markdown-toc', { 'for': ['markdown', 'vim-plug'] }
  Plug 'dkarter/bullets.vim'
  Plug 'junegunn/goyo.vim'
  Plug 'reedes/vim-wordy'

  " Editing operators and text objects.
  Plug 'mbbill/undotree'
  Plug 'jiangmiao/auto-pairs'
  Plug 'mg979/vim-visual-multi'
  Plug 'theniceboy/tcomment_vim'
  Plug 'theniceboy/antovim'
  Plug 'tpope/vim-surround'
  Plug 'gcmt/wildfire.vim'
  Plug 'junegunn/vim-after-object'
  Plug 'godlygeek/tabular'
  Plug 'tpope/vim-capslock'
  Plug 'svermeulen/vim-subversive'
  Plug 'theniceboy/argtextobj.vim'
  Plug 'rhysd/clever-f.vim'
  Plug 'AndrewRadev/splitjoin.vim'
  Plug 'theniceboy/pair-maker.vim'
  Plug 'theniceboy/vim-move'
  Plug 'Yggdroot/indentLine'

  " Utilities.
  Plug 'skywind3000/asynctasks.vim'
  Plug 'skywind3000/asyncrun.vim'
  Plug 'luochen1990/rainbow'
  Plug 'mg979/vim-xtabline'
	Plug 'wincent/terminus'
	Plug 'lambdalisue/suda.vim'

	" Optional heavier integrations. Enable from ~/.config/nvim/local.vim.
	if g:lite_enable_copilot
    Plug 'github/copilot.vim'
  endif
  if g:lite_enable_treesitter
    Plug 'nvim-treesitter/nvim-treesitter'
  endif
  if g:lite_enable_lua_extras
    Plug 'nvim-lua/plenary.nvim'
    Plug 'lewis6991/gitsigns.nvim'
    Plug 'kevinhwang91/nvim-hlslens'
    Plug 'NvChad/nvim-colorizer.lua'
    Plug 'nvim-pack/nvim-spectre'
  endif
  if g:lite_enable_file_managers
    Plug 'kdheepak/lazygit.nvim'
    Plug 'theniceboy/joshuto.nvim'
    Plug 'kevinhwang91/rnvimr'
  endif

  call plug#end()

  if s:plug_bootstrapped
    augroup lite_plug_bootstrap
      autocmd!
      autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    augroup END
  endif
endif

" ---------------------------------------------------------------------------
" Core editor behavior
" ---------------------------------------------------------------------------
filetype plugin indent on
syntax enable
silent! runtime macros/matchit.vim

let &t_ut = ''
set autochdir
set exrc
set secure
set number
set relativenumber
set cursorline
set noexpandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoindent
set list
set listchars=tab:\|\ ,trail:-
set scrolloff=4
set sidescrolloff=4
set viewoptions=cursor,folds,slash,unix
set wrap
set textwidth=0
set indentexpr=
set foldmethod=indent
set foldlevel=99
set foldenable
set splitright
set splitbelow
set noshowmode
set ignorecase
set smartcase
set shortmess+=c
set completeopt=menu,menuone,noselect
set pumheight=12
set lazyredraw
set noerrorbells
set novisualbell
set t_vb=
set updatetime=300
set virtualedit=block
set timeout
set timeoutlen=700
set ttimeout
set ttimeoutlen=20
set formatoptions-=t
set formatoptions-=c

if exists('&belloff')
  set belloff=all
endif
if exists('&inccommand')
  set inccommand=split
endif
if exists('&termguicolors')
  set termguicolors
endif
if exists('&colorcolumn')
  set colorcolumn=100
endif
if has('clipboard')
  set clipboard=unnamedplus
endif

let s:tmp_root = expand('~/.config/nvim/tmp')
silent! call mkdir(s:tmp_root . '/backup', 'p')
silent! call mkdir(s:tmp_root . '/undo', 'p')
execute 'set backupdir^=' . fnameescape(s:tmp_root . '/backup//')
execute 'set directory^=' . fnameescape(s:tmp_root . '/backup//')
if has('persistent_undo')
  set undofile
  execute 'set undodir^=' . fnameescape(s:tmp_root . '/undo//')
endif

augroup lite_core
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g'\"" | endif
  autocmd BufEnter * silent! lcd %:p:h
  autocmd BufWritePost init.vim,.nvimrc nested source $MYVIMRC
  autocmd TermOpen term://* startinsert
  autocmd BufRead,BufNewFile *.md,*.markdown setlocal spell
  autocmd BufRead,BufNewFile tsconfig.json setlocal filetype=jsonc
augroup END

" ---------------------------------------------------------------------------
" Basic mappings
" ---------------------------------------------------------------------------
let mapleader = ' '

noremap ; :
nnoremap Q :q<CR>
nnoremap S :w<CR>
nnoremap <Leader>rc :e $MYVIMRC<CR>
nnoremap <Leader>rv :e .nvimrc<CR>
noremap l u
noremap k i
noremap K I
vnoremap Y "+y
noremap ,. %
vnoremap ki $%
nnoremap <Leader><CR> :nohlsearch<CR>
nnoremap <Leader>dw /\(\<\w\+\>\)\_s*\1<CR>
nnoremap <Leader>tt :%s/    /\t/g<CR>
vnoremap <Leader>tt :s/    /\t/g<CR>
noremap <silent> <Leader>o za
inoremap <C-y> <Esc>A {}<Esc>i<CR><Esc>ko
" 跳转目标词
nnoremap <silent> = nzz
nnoremap <silent> - Nzz

" ---------------------------------------------------------------------------
" Colemak cursor movement
" ---------------------------------------------------------------------------
"     ^
"     u
" < n   i >
"     e
"     v
noremap <silent> u k
noremap <silent> n h
noremap <silent> e j
noremap <silent> i l
noremap <silent> gu gk
noremap <silent> ge gj
noremap <silent> \v v$h
noremap <silent> U 5k
noremap <silent> E 5j
noremap <silent> N 0
noremap <silent> I $
noremap W 5w
noremap B 5b
noremap h e
noremap <C-U> 5<C-y>
noremap <C-E> 5<C-e>

inoremap <C-a> <Esc>A
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <M-b> <S-Left>
cnoremap <M-w> <S-Right>

" ---------------------------------------------------------------------------
" Window and tab management
" ---------------------------------------------------------------------------
noremap <Leader>w <C-w>w
noremap <Leader>u <C-w>k
noremap <Leader>e <C-w>j
noremap <Leader>n <C-w>h
noremap <Leader>i <C-w>l
noremap qf <C-w>o
noremap s <Nop>
noremap su :set nosplitbelow<CR>:split<CR>:set splitbelow<CR>
noremap se :set splitbelow<CR>:split<CR>
noremap sn :set nosplitright<CR>:vsplit<CR>:set splitright<CR>
noremap si :set splitright<CR>:vsplit<CR>
noremap <Up> :resize +5<CR>
noremap <Down> :resize -5<CR>
noremap <Left> :vertical resize -5<CR>
noremap <Right> :vertical resize +5<CR>
noremap sh <C-w>t<C-w>K
noremap sv <C-w>t<C-w>H
noremap srh <C-w>b<C-w>K
noremap srv <C-w>b<C-w>H
noremap <Leader>q <C-w>j:q<CR>

noremap tu :tabe<CR>
noremap tU :tab split<CR>
noremap tn :-tabnext<CR>
noremap ti :+tabnext<CR>
noremap tmn :-tabmove<CR>
noremap tmi :+tabmove<CR>

" ---------------------------------------------------------------------------
" Text / Markdown conveniences
" ---------------------------------------------------------------------------
noremap <Leader><Leader> <Esc>/<++><CR>:nohlsearch<CR>"_c4l
noremap <Leader>sc :setlocal spell!<CR>
noremap ` ~
noremap <C-c> zz
noremap \s :%s//g<Left><Left>
noremap <Leader>sw :set wrap!<CR>
nnoremap \p :echo expand('%:p')<CR>

" ---------------------------------------------------------------------------
" Compile/run command
" ---------------------------------------------------------------------------
noremap r :call CompileRunCurrentFile()<CR>
function! CompileRunCurrentFile() abort
  write
  if &filetype ==# 'c'
    split | resize 12 | terminal gcc % -o %< && time ./%<
  elseif &filetype ==# 'cpp'
    execute '!g++ -std=c++11 ' . shellescape(expand('%')) . ' -Wall -o ' . shellescape(expand('%<'))
    split | resize 12 | execute 'terminal ' . shellescape(expand('%<'))
  elseif &filetype ==# 'sh'
    execute '!time bash ' . shellescape(expand('%'))
  elseif &filetype ==# 'python'
    split | resize 12 | execute 'terminal python3 ' . shellescape(expand('%'))
  elseif &filetype ==# 'javascript'
    split | resize 12 | terminal node .
  elseif &filetype ==# 'go'
    split | resize 12 | terminal go run .
  elseif &filetype ==# 'racket'
    split | resize 12 | execute 'terminal racket ' . shellescape(expand('%'))
  else
    echo 'No run command for filetype: ' . &filetype
  endif
endfunction

" ---------------------------------------------------------------------------
" Theme and Vimscript plugin settings
" ---------------------------------------------------------------------------
silent! colorscheme deus
hi NonText ctermfg=gray guifg=grey10
let g:airline_powerline_fonts = 0

let g:fzf_preview_window = 'right:40%'
let g:fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'
let g:fzf_layout = { 'window': { 'width': 0.95, 'height': 0.95 } }

let g:undotree_DiffAutoOpen = 1
let g:undotree_SetFocusWhenToggle = 1
let g:undotree_ShortIndicators = 1
let g:undotree_WindowLayout = 2
let g:undotree_DiffpanelHeight = 8
let g:undotree_SplitWidth = 24
function! g:Undotree_CustomMap() abort
  nmap <buffer> u <Plug>UndotreeNextState
  nmap <buffer> e <Plug>UndotreePreviousState
  nmap <buffer> U 5<Plug>UndotreeNextState
  nmap <buffer> E 5<Plug>UndotreePreviousState
endfunction

let g:VM_leader = {'default': ',', 'visual': ',', 'buffer': ','}
let g:VM_maps = {}
let g:VM_custom_motions = {'n': 'h', 'i': 'l', 'u': 'k', 'e': 'j', 'N': '0', 'I': '$', 'h': 'e'}
let g:VM_maps['i'] = 'k'
let g:VM_maps['I'] = 'K'
let g:VM_maps['Find Under'] = '<C-k>'
let g:VM_maps['Find Subword Under'] = '<C-k>'
let g:VM_maps['Find Next'] = ''
let g:VM_maps['Find Prev'] = ''
let g:VM_maps['Remove Region'] = 'q'
let g:VM_maps['Skip Region'] = '<C-n>'
let g:VM_maps['Undo'] = 'l'
let g:VM_maps['Redo'] = '<C-r>'

let g:wildfire_objects = {
      \ '*' : ["i'", 'i"', 'i)', 'i]', 'i}', 'it'],
      \ 'html,xml' : ['at', 'it'],
      \}

let g:bullets_enabled_file_types = ['markdown', 'text', 'gitcommit', 'scratch']
let g:table_mode_cell_text_object_i_map = 'k|'
let g:vmt_cycle_list_item_markers = 1
let g:vmt_fence_text = 'TOC'
let g:vmt_fence_closing_text = '/TOC'
let g:go_echo_go_info = 0
let g:go_def_mapping_enabled = 0
let g:go_template_autocreate = 0
let g:go_textobj_enabled = 0
let g:vim_jsx_pretty_colorful_config = 1
let g:rainbow_active = 1
let g:move_key_modifier = 'C'
let g:asyncrun_open = 6
let g:typescript_ignore_browserwords = 1
let g:rooter_patterns = ['__vim_project_root', '.git/']
let g:rooter_silent_chdir = 1
let g:dart_corelib_highlight = v:false
let g:dart_format_on_save = v:false
let g:Illuminate_delay = 750
hi illuminatedWord cterm=undercurl gui=undercurl

let g:xtabline_settings = {}
let g:xtabline_settings.enable_mappings = 0
let g:xtabline_settings.tabline_modes = ['tabs', 'buffers']
let g:xtabline_settings.enable_persistance = 0
let g:xtabline_settings.last_open_first = 1

cnoreabbrev sudowrite w suda://%
cnoreabbrev sw w suda://%

function! s:SafePluginMaps() abort
  if exists(':Files') == 2
    nnoremap <silent> <C-p> :Files<CR>
  endif
  if exists(':Rg') == 2
    nnoremap <silent> <C-f> :Rg<CR>
  endif
  if exists(':Buffers') == 2
    nnoremap <silent> <C-w> :Buffers<CR>
  endif
  if exists(':History') == 2
    nnoremap <leader>; :History:<CR>
  endif
  if exists(':UndotreeToggle') == 2
    nnoremap L :UndotreeToggle<CR>
  endif
  if exists(':TableModeToggle') == 2
    nnoremap <Leader>tm :TableModeToggle<CR>
  endif
  if exists(':Tabularize') == 2
    vnoremap ga :Tabularize /
  endif
  if exists(':Goyo') == 2
    nnoremap <Leader>gy :Goyo<CR>
  endif
  if exists(':XTabCycleMode') == 2
    nnoremap to :XTabCycleMode<CR>
  endif
  if exists(':Agit') == 2
    nnoremap <Leader>gl :Agit<CR>
  endif
  if exists(':AnyJump') == 2
    nnoremap j :AnyJump<CR>
  endif
  if exists(':AsyncRun') == 2
    nnoremap gp :AsyncRun git push<CR>
  endif
  if exists(':TComment') == 2
    nnoremap ci cl
    nmap <Leader>cn g>c
    vmap <Leader>cn g>
    nmap <Leader>cu g<c
    vmap <Leader>cu g<
  endif
  if exists('*after_object#enable')
    call after_object#enable('=', ':', '-', '#', ' ')
  endif
  if maparg('<Plug>(wildfire-quick-select)', 'n') !=# ''
    map <C-b> <Plug>(wildfire-quick-select)
  endif
  if maparg('<Plug>(SubversiveSubstitute)', 'n') !=# ''
    nmap s <Plug>(SubversiveSubstitute)
    nmap ss <Plug>(SubversiveSubstituteLine)
  endif
endfunction

augroup lite_plugin_maps
  autocmd!
  autocmd VimEnter * call <SID>SafePluginMaps()
augroup END

" ---------------------------------------------------------------------------
" Native LSP + nvim-cmp completion
" ---------------------------------------------------------------------------
lua << EOF
local has_cmp, cmp = pcall(require, 'cmp')
local has_cmp_lsp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
local has_mason, mason = pcall(require, 'mason')

if has_mason and vim.g.lite_enable_mason ~= 0 then
  mason.setup()
end

local function has_words_before()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  if col == 0 then return false end
  local text = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
  return text:sub(col, col):match('%s') == nil
end

if has_cmp then
  cmp.setup({
    completion = { completeopt = 'menu,menuone,noselect' },
    snippet = {
      expand = function(args)
        if vim.snippet and vim.snippet.expand then
          vim.snippet.expand(args.body)
        end
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<C-d>'] = cmp.mapping.scroll_docs(4),
      ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'path' },
    }, {
      { name = 'buffer' },
    }),
  })

  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = { { name = 'buffer' } },
  })

  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' },
    }, {
      { name = 'cmdline' },
    }),
    matching = { disallow_symbol_nonprefix_matching = false },
  })
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
if has_cmp_lsp then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

local function command_exists(cmd)
  if type(cmd) == 'table' then
    for _, item in ipairs(cmd) do
      if vim.fn.executable(item) == 1 then return item end
    end
    return nil
  end
  if vim.fn.executable(cmd) == 1 then return cmd end
  return nil
end

local function with_capabilities(config)
  config.capabilities = vim.tbl_deep_extend('force', capabilities, config.capabilities or {})
  return config
end

local servers = {
  lua_ls = {
    check = 'lua-language-server',
    config = {
      cmd = { 'lua-language-server' },
      filetypes = { 'lua' },
      root_markers = { '.luarc.json', '.luarc.jsonc', '.stylua.toml', 'stylua.toml', 'selene.toml', '.git' },
      settings = {
        Lua = {
          runtime = { version = 'LuaJIT' },
          diagnostics = { globals = { 'vim' } },
          workspace = {
            checkThirdParty = false,
            library = vim.api.nvim_get_runtime_file('', true),
          },
        },
      },
    },
  },
  pyright = {
    check = 'pyright-langserver',
    config = {
      cmd = { 'pyright-langserver', '--stdio' },
      filetypes = { 'python' },
      root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', 'pyrightconfig.json', '.git' },
    },
  },
  ts_ls = {
    check = 'typescript-language-server',
    config = {
      cmd = { 'typescript-language-server', '--stdio' },
      filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx' },
      root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
    },
  },
  html = {
    check = 'vscode-html-language-server',
    config = {
      cmd = { 'vscode-html-language-server', '--stdio' },
      filetypes = { 'html' },
      root_markers = { 'package.json', '.git' },
    },
  },
  cssls = {
    check = 'vscode-css-language-server',
    config = {
      cmd = { 'vscode-css-language-server', '--stdio' },
      filetypes = { 'css', 'scss', 'less' },
      root_markers = { 'package.json', '.git' },
    },
  },
  jsonls = {
    check = 'vscode-json-language-server',
    config = {
      cmd = { 'vscode-json-language-server', '--stdio' },
      filetypes = { 'json', 'jsonc' },
      root_markers = { 'package.json', '.git' },
    },
  },
  bashls = {
    check = 'bash-language-server',
    config = {
      cmd = { 'bash-language-server', 'start' },
      filetypes = { 'sh', 'bash', 'zsh' },
      root_markers = { '.git' },
    },
  },
  yamlls = {
    check = 'yaml-language-server',
    config = {
      cmd = { 'yaml-language-server', '--stdio' },
      filetypes = { 'yaml', 'yaml.docker-compose' },
      root_markers = { '.git' },
    },
  },
  gopls = {
    check = 'gopls',
    config = {
      cmd = { 'gopls' },
      filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
      root_markers = { 'go.work', 'go.mod', '.git' },
    },
  },
  clangd = {
    check = 'clangd',
    config = {
      cmd = { 'clangd', '--background-index' },
      filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
      root_markers = { '.clangd', 'compile_commands.json', 'compile_flags.txt', 'configure.ac', '.git' },
    },
  },
  rust_analyzer = {
    check = 'rust-analyzer',
    config = {
      cmd = { 'rust-analyzer' },
      filetypes = { 'rust' },
      root_markers = { 'Cargo.toml', 'rust-project.json', '.git' },
    },
  },
  dartls = {
    check = 'dart',
    config = {
      cmd = { 'dart', 'language-server', '--protocol=lsp' },
      filetypes = { 'dart' },
      root_markers = { 'pubspec.yaml', '.git' },
    },
  },
  sourcekit = {
    check = 'sourcekit-lsp',
    config = {
      cmd = { 'sourcekit-lsp' },
      filetypes = { 'swift' },
      root_markers = { 'Package.swift', '.git' },
    },
  },
  prismals = {
    check = 'prisma-language-server',
    config = {
      cmd = { 'prisma-language-server', '--stdio' },
      filetypes = { 'prisma' },
      root_markers = { 'schema.prisma', 'package.json', '.git' },
    },
  },
  terraformls = {
    check = 'terraform-ls',
    config = {
      cmd = { 'terraform-ls', 'serve' },
      filetypes = { 'terraform', 'terraform-vars' },
      root_markers = { '.terraform', '.git' },
    },
  },
  marksman = {
    check = 'marksman',
    config = {
      cmd = { 'marksman', 'server' },
      filetypes = { 'markdown', 'markdown.mdx' },
      root_markers = { '.marksman.toml', '.git' },
    },
  },
  jdtls = {
    check = 'jdtls',
    config = {
      cmd = { 'jdtls' },
      filetypes = { 'java' },
      root_markers = { 'pom.xml', 'build.gradle', 'build.gradle.kts', '.git' },
    },
  },
  omnisharp = {
    check = { 'omnisharp', 'OmniSharp' },
    config = {
      cmd = { command_exists({ 'omnisharp', 'OmniSharp' }) or 'omnisharp', '--languageserver', '--hostPID', tostring(vim.fn.getpid()) },
      filetypes = { 'cs' },
      root_markers = { '*.sln', '*.csproj', '.git' },
    },
  },
}

local enabled, missing = {}, {}
if vim.lsp and vim.lsp.config and vim.lsp.enable then
  for name, spec in pairs(servers) do
    if command_exists(spec.check) then
      vim.lsp.config(name, with_capabilities(spec.config))
      vim.lsp.enable(name)
      table.insert(enabled, name)
    else
      table.insert(missing, name .. ' [' .. table.concat(type(spec.check) == 'table' and spec.check or { spec.check }, '|') .. ']')
    end
  end
else
  vim.notify('This config needs Neovim 0.11+ for native LSP auto-start.', vim.log.levels.WARN)
end

vim.g.lite_lsp_enabled = enabled
vim.g.lite_lsp_missing = missing

vim.api.nvim_create_user_command('LspEnabled', function()
  print(#enabled > 0 and table.concat(enabled, ', ') or 'No LSP servers enabled yet.')
end, {})

vim.api.nvim_create_user_command('LspMissing', function()
  if #missing == 0 then
    print('No missing LSP server commands from the configured list.')
    return
  end
  print('Missing LSP commands:\n' .. table.concat(missing, '\n'))
end, {})

if vim.fn.exists(':LspInfo') == 0 then
  vim.api.nvim_create_user_command('LspInfo', function()
    local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
    if #clients == 0 then
      print('No LSP clients attached to current buffer.')
      return
    end

    local lines = { 'LSP clients attached to current buffer:' }
    for _, client in ipairs(clients) do
      local root = client.config.root_dir or client.root_dir or '(no root)'
      local cmd = client.config.cmd and table.concat(client.config.cmd, ' ') or '(no cmd)'
      table.insert(lines, string.format('- %s (id=%s)', client.name, client.id))
      table.insert(lines, '  root: ' .. tostring(root))
      table.insert(lines, '  cmd: ' .. tostring(cmd))
    end
    print(table.concat(lines, '\n'))
  end, {})
end

vim.api.nvim_create_user_command('LiteLspInstallCore', function()
  if vim.fn.exists(':MasonInstall') ~= 2 then
    print('Mason is not available. Run :PlugInstall first, or install language servers with brew/npm.')
    return
  end
  vim.cmd('MasonInstall lua-language-server pyright typescript-language-server html-lsp css-lsp json-lsp gopls clangd bash-language-server')
end, {})

vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = '*' },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lite_lsp_attach', { clear = true }),
  callback = function(event)
    local opts = { buffer = event.buf, silent = true }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gD', function() vim.cmd('tab split'); vim.lsp.buf.definition() end, opts)
    vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<Leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<Leader>a', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<Leader>h', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<Leader>d', vim.diagnostic.setloclist, opts)
    vim.keymap.set('n', '<Leader>-', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', '<Leader>=', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', '<Leader>lf', function() vim.lsp.buf.format({ async = true }) end, opts)
  end,
})
EOF

" ---------------------------------------------------------------------------
" Optional Lua plugin setup, guarded with pcall
" ---------------------------------------------------------------------------
if g:lite_enable_lua_extras
lua << EOF
local function safe_require(name)
  local ok, mod = pcall(require, name)
  if ok then return mod end
end

local gitsigns = safe_require('gitsigns')
if gitsigns then gitsigns.setup() end

local hlslens = safe_require('hlslens')
if hlslens then hlslens.setup() end

local colorizer = safe_require('colorizer')
if colorizer then colorizer.setup({ filetypes = { '*' } }) end
EOF

  nnoremap <silent> <Leader>f <Cmd>lua require('spectre').open()<CR>
  vnoremap <silent> <Leader>f <Cmd>lua require('spectre').open_visual()<CR>
  nnoremap <silent> H :Gitsigns preview_hunk_inline<CR>
  nnoremap <silent> <Leader>gr :Gitsigns reset_hunk<CR>
  nnoremap <silent> <Leader>gb :Gitsigns blame_line<CR>
  nnoremap <silent> <Leader>g- :Gitsigns prev_hunk<CR>
  nnoremap <silent> <Leader>g= :Gitsigns next_hunk<CR>
endif

if g:lite_enable_treesitter
lua << EOF
local ok, configs = pcall(require, 'nvim-treesitter.configs')
if ok then
  configs.setup({
    highlight = { enable = true },
    indent = { enable = true },
  })
end
EOF
endif

if g:lite_enable_copilot
  let g:copilot_no_tab_map = v:true
  imap <silent><script><expr> <C-C> copilot#Accept("")
  inoremap <C-n> <Plug>(copilot-next)
  inoremap <C-l> <Plug>(copilot-previous)
endif

" Source your personal Colemak cursor and Markdown snippet files if present.
for s:local_file in ['_machine_specific.vim', 'cursor.vim', 'md-snippets.vim']
  let s:path = expand('~/.config/nvim/' . s:local_file)
  if filereadable(s:path)
    silent! execute 'source ' . fnameescape(s:path)
  endif
endfor

silent! nohlsearch
