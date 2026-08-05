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

" Put personal overrides here; it is sourced before plugins so switches work.
let s:local_vim = expand('~/.config/nvim/local.vim')
if filereadable(s:local_vim)
  execute 'source ' . fnameescape(s:local_vim)
endif

" ---------------------------------------------------------------------------
" Plugins (managed by lazy.nvim)
" ---------------------------------------------------------------------------
lua << EOF
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
  -- Completion and LSP. No Coc.
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "hrsh7th/cmp-cmdline" },
  { "mason-org/mason.nvim", enabled = vim.g.lite_enable_mason ~= 0 },

  -- Snippet 引擎（代码片段展开）
  { "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    dependencies = { "saadparwaiz1/cmp_luasnip" },
    config = function()
      -- 加载已有的 vim-snippets 中的预定义代码片段
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_snipmate").lazy_load()

      -- 加载自定义片段（~/.config/nvim/snippets/ 下的 .snippets / .json / .lua）
      local custom_dir = vim.fn.expand("~/.config/nvim/snippets")
      vim.fn.mkdir(custom_dir, "p")
      local snipmate_collection = require("luasnip.loaders.from_snipmate").load({ paths = custom_dir })
      require("luasnip.loaders.from_vscode").load({ paths = custom_dir })

      -- 保存 snippets 文件后自动重载，立即生效
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = custom_dir .. "/*",
        group = vim.api.nvim_create_augroup("luasnip_reload", { clear = true }),
        callback = function(args)
          if snipmate_collection then
            snipmate_collection:reload(args.file)
          end
          require("luasnip").clean_invalidated()
          vim.notify("[snippets] 已重载: " .. vim.fn.fnamemodify(args.file, ":t"), vim.log.levels.INFO)
        end,
      })
    end,
  },

  -- Stable editing and navigation.
  { "theniceboy/nvim-deus" },
  { "theniceboy/eleline.vim", branch = "no-scrollbar" },
  { "itchyny/vim-cursorword" },
  { "RRethy/vim-illuminate" },
  { "airblade/vim-rooter" },
  { "junegunn/fzf" },
  { "junegunn/fzf.vim" },
  { "pechorin/any-jump.vim" },
  { "wellle/tmux-complete.vim" },
  { "theniceboy/vim-snippets" },

  -- Git.
  { "theniceboy/vim-gitignore", ft = { "gitignore" } },
  { "cohama/agit.vim" },

  -- Filetype support.
  { "elzr/vim-json" },
  { "neoclide/jsonc.vim" },
  { "othree/html5.vim" },
  { "alvan/vim-closetag" },
  { "pangloss/vim-javascript" },
  { "MaxMEllon/vim-jsx-pretty" },
  { "leafgarland/typescript-vim" },
  { "peitalin/vim-jsx-typescript" },
  { "styled-components/vim-styled-components", branch = "main" },
  { "pantharshit00/vim-prisma" },
  { "fatih/vim-go", ft = { "go" } },
  { "Vimjas/vim-python-pep8-indent", ft = { "python" } },
  { "tweekmonster/braceless.vim", ft = { "python" } },
  { "dart-lang/dart-vim-plugin", ft = { "dart" } },
  { "keith/swift.vim" },
  { "arzg/vim-swift" },
  { "wlangstroth/vim-racket" },
  { "hashivim/vim-terraform" },

  -- Text / Markdown.
  { "dhruvasagar/vim-table-mode", cmd = "TableModeToggle", ft = { "text", "markdown" } },
  { "mzlogin/vim-markdown-toc", ft = { "markdown" } },
  { "dkarter/bullets.vim" },
  { "junegunn/goyo.vim" },
  { "reedes/vim-wordy" },

  -- Markdown 实时预览
  { "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    ft = { "markdown" },
    build = function()
      -- 下载预编译二进制（注意：这是 lazy.nvim 的 build hook，
      -- 只在 :Lazy install / :Lazy update 时执行，不在每次打开 nvim 时执行）
      --
      -- 本插件需要 app/bin/ 下的预编译二进制才能启动预览服务。
      -- install.sh 从 GitHub Releases 下载对应平台的二进制（macOS ARM64 ~17MB）。
      -- 这比在本地用 yarn + node_modules 构建更快更可靠，且不依赖 Node.js 生态。
      local ok, err = pcall(function()
        local app_dir = vim.fn.getcwd() .. "/app"
        local script = app_dir .. "/install.sh"

        -- 1) 下载预编译二进制
        local ret = vim.fn.system({"bash", script})
        if vim.v.shell_error ~= 0 then
          error("install.sh 失败:\n" .. ret)
        end

        -- 2) macOS Gatekeeper：从 GitHub 下载的 unsigned 二进制会被隔离，
        --    移除 quarantine 标记使其可通过 macOS 安全检查执行。
        if vim.fn.has("mac") == 1 then
          local bin_dir = app_dir .. "/bin"
          local dir = vim.uv or vim.loop
          local handle = dir.fs_scandir(bin_dir)
          if handle then
            while true do
              local name = dir.fs_scandir_next(handle)
              if not name then break end
              vim.fn.system({"xattr", "-d", "com.apple.quarantine", bin_dir .. "/" .. name})
            end
          end
        end
      end)
      if not ok then
        vim.notify("[markdown-preview.nvim] 构建失败: " .. tostring(err)
          .. "\n打开 md 文件后无预览，可手动执行: cd ~/.local/share/nvim/lazy/markdown-preview.nvim/app && bash install.sh",
          vim.log.levels.WARN)
      end
    end,
    init = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_refresh_slow = 0
      vim.g.mkdp_browser = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
      vim.g.mkdp_echo_preview_url = 1
    end,
  },

  -- Editing operators and text objects.
  { "mbbill/undotree" },
  { "jiangmiao/auto-pairs" },
  { "mg979/vim-visual-multi" },
  { "theniceboy/tcomment_vim" },
  { "theniceboy/antovim" },
  { "tpope/vim-surround" },
  { "gcmt/wildfire.vim" },
  { "junegunn/vim-after-object" },
  { "godlygeek/tabular" },
  { "tpope/vim-capslock" },
  { "svermeulen/vim-subversive" },
  { "theniceboy/argtextobj.vim" },
  { "rhysd/clever-f.vim" },
  { "AndrewRadev/splitjoin.vim" },
  { "theniceboy/pair-maker.vim" },
  { "theniceboy/vim-move" },
  { "Yggdroot/indentLine" },

  -- Utilities.
  { "skywind3000/asynctasks.vim" },
  { "skywind3000/asyncrun.vim" },
  { "luochen1990/rainbow" },
  { "mg979/vim-xtabline" },
  { "wincent/terminus" },
  { "lambdalisue/suda.vim" },

  -- 翻译插件（光标在单词上按 st 显示含义）
  { "voldikss/vim-translator",
    config = function()
      -- 使用 Google 翻译源（无需 API Key）
      vim.g.translator_target_lang = "zh"
      vim.g.translator_source_lang = "auto"
      -- 注意：这里必须是 Vim 列表，不是字符串
      vim.g.translator_default_engines = { "google" }
    end,
  },

  -- Optional: Copilot
  { "github/copilot.vim", enabled = vim.g.lite_enable_copilot ~= 0 },

  -- Optional: Treesitter
  { "nvim-treesitter/nvim-treesitter",
    enabled = vim.g.lite_enable_treesitter ~= 0,
    build = ":TSUpdate",
  },

  -- Optional: Lua extras (gitsigns, hlslens, colorizer, spectre)
  { "lewis6991/gitsigns.nvim", enabled = vim.g.lite_enable_lua_extras ~= 0 },
  { "kevinhwang91/nvim-hlslens", enabled = vim.g.lite_enable_lua_extras ~= 0 },
  { "NvChad/nvim-colorizer.lua", enabled = vim.g.lite_enable_lua_extras ~= 0 },
  { "nvim-pack/nvim-spectre", enabled = vim.g.lite_enable_lua_extras ~= 0 },

  -- Optional: File managers
  { "kdheepak/lazygit.nvim", cmd = "LazyGit", enabled = vim.g.lite_enable_file_managers ~= 0 },
  { "theniceboy/joshuto.nvim", enabled = vim.g.lite_enable_file_managers ~= 0 },
  { "kevinhwang91/rnvimr", enabled = vim.g.lite_enable_file_managers ~= 0 },

  -- 工具库（yazi.nvim、spectre 等依赖）
  { "nvim-lua/plenary.nvim" },

  -- Yazi 文件管理器（终端内浮动窗口，ranger 风格）
  -- 依赖 plenary.nvim
  { "mikavilpas/yazi.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Yazi",
    keys = {
      { "<Leader>y", "<cmd>Yazi<CR>", desc = "打开 Yazi 文件管理器" },
    },
    config = function()
      require("yazi").setup({
        floating_window_scaling_factor = 0.9,
      })
    end,
  },
}

require("lazy").setup(plugins, {
  install = {
    colorscheme = { "deus" },
  },
  ui = {
    border = "none",
  },
  performance = {
    cache = { enabled = true },
    rtp = {
      disabled_plugins = {
        "gzip",
        "netrwPlugin",
        "tarPlugin",
        "zipPlugin",
      },
    },
  },
})
EOF

" ---------------------------------------------------------------------------
" FZF: 优先使用 fd 加速搜索（自动安装）
" ---------------------------------------------------------------------------
lua << EOF
-- fd 比 find 快 10x，自动跳过 .gitignore 中的目录（node_modules 等）
do
  local has_fd = vim.fn.executable("fd") == 1

  -- 如果没装 fd，自动通过 brew 安装（仅在 macOS 上）
  if not has_fd and vim.fn.has("mac") == 1 then
    vim.notify("[fzf] fd 未安装，正在通过 brew 安装…", vim.log.levels.INFO)
    local ok = pcall(function()
      vim.fn.system({"brew", "install", "fd"})
    end)
    if ok and vim.v.shell_error == 0 then
      has_fd = true
      vim.notify("[fzf] fd 安装成功", vim.log.levels.INFO)
    else
      vim.notify("[fzf] fd 安装失败，回退到 find。可手动执行: brew install fd", vim.log.levels.WARN)
    end
  end

  if has_fd then
    -- fd 配置：仅文件、隐藏文件、符号链接、排除 .git
    vim.env.FZF_DEFAULT_COMMAND = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git"
    -- Ctrl-T / Ctrl-P 使用同样的搜索命令
    vim.env.FZF_CTRL_T_COMMAND = vim.env.FZF_DEFAULT_COMMAND
    -- 搜索 ALT-C 目录树用同样配置
    vim.env.FZF_ALT_C_COMMAND = "fd --type d --strip-cwd-prefix --hidden --follow --exclude .git"
  end

  -- 隐藏 FZF 底部进度条和数字（\"xxx/xxxx\"），
  -- 只保留输入行。FZF 本身就是边扫边搜，无需等扫描完成。
  -- 想恢复的话删掉这行即可。
  local fzf_opts = vim.env.FZF_DEFAULT_OPTS or ""
  if not fzf_opts:find("--info=") then
    fzf_opts = fzf_opts .. " --info=hidden"
  end
  vim.env.FZF_DEFAULT_OPTS = fzf_opts
end
EOF

" ---------------------------------------------------------------------------
" Core editor behavior
" ---------------------------------------------------------------------------
filetype plugin indent on
syntax enable
silent! runtime macros/matchit.vim

let &t_ut = ''
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
set updatetime=1000
set autoread
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
  autocmd BufWritePost init.vim,.nvimrc nested source $MYVIMRC
  autocmd TermOpen term://* startinsert
  autocmd BufRead,BufNewFile *.md,*.markdown setlocal spell
  autocmd FileType markdown ++nested lua vim.fn.timer_start(400, function() pcall(vim.cmd, "MarkdownPreview") end)
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
inoremap <C-l> <Esc>ia
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

" 翻译：光标在单词上按 ts 弹出浮动窗口显示含义
nmap ts <Plug>TranslateW

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
" <Leader>sn 根据当前文件类型自动打开对应的 snippets 文件编辑
nnoremap <Leader>sn :lua _G.edit_current_snippets()<CR>
nnoremap \p :echo expand('%:p')<CR>

" ---------------------------------------------------------------------------
" 注释切换（Ctrl+/）
" ---------------------------------------------------------------------------
" 普通模式注释/取消注释当前行，可视模式注释选中行
nmap <C-/> gcc
xmap <C-/> gc
" 兼容终端按键编码
nmap <C-_> gcc
xmap <C-_> gc

" ---------------------------------------------------------------------------
" Markdown preview (markdown-preview.nvim)
" ---------------------------------------------------------------------------
" F7 打开浏览器预览, F8 关闭预览
nnoremap <F7> :MarkdownPreview<CR>
nnoremap <F8> :MarkdownPreviewStop<CR>

" Yazi 文件管理器（<Leader>y）
nnoremap <Leader>y :Yazi<CR>

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
" 表格单元格跳转（不用按 Shift 的 [|）
let g:table_mode_motion_left_map = "[\<Bslash>"
let g:table_mode_motion_right_map = "]\<Bslash>"
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
    " 搜索整个家目录（不限于当前项目）
    nnoremap <silent> <Leader>fh :Files ~/<CR>
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
  local has_luasnip = pcall(require, "luasnip")
  local luasnip = has_luasnip and require("luasnip") or nil

  cmp.setup({
    completion = { completeopt = 'menu,menuone,noselect' },
    view = {
      docs = {
        auto_open = true,
      },
    },
    window = {
      completion = {
        border = "rounded",
        winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None",
      },
      documentation = {
        max_width = 72,
        max_height = 40,
        border = "rounded",
        zindex = 999,
      },
    },
    snippet = {
      expand = function(args)
        if luasnip then
          luasnip.lsp_expand(args.body)
        elseif vim.snippet and vim.snippet.expand then
          vim.snippet.expand(args.body)
        end
      end,
    },
    mapping = cmp.mapping.preset.insert({
      -- Ctrl+n 补全菜单向下选择
      ['<C-n>'] = cmp.mapping.select_next_item(),
      -- Ctrl+p 补全菜单向上选择；无菜单时跳转上一个片段占位符
      ['<C-p>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip and luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { 'i', 's' }),
      -- Ctrl+e 专用于代码片段展开 / 跳转下一个占位符
      ['<C-e>'] = cmp.mapping(function(fallback)
        if luasnip and luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { 'i', 's' }),
      -- 回车确认补全
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
      -- Tab 触发补全 / 向下选择
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<C-d>'] = cmp.mapping.scroll_docs(4),
      ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
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

-- Monkey-patch nvim-cmp 文档窗口
-- 1. 解除菜单位置对宽度的限制（列数不再受菜单左右空间约束）
-- 2. 文档窗口放在补全菜单正上方，不重叠
pcall(function()
  local docs_view = require("cmp.view.docs_view")
  local window_util = require("cmp.utils.window")
  local cmp_config = require("cmp.config")
  local orig_open = docs_view.open
  docs_view.open = function(self, e, view, bottom_up)
    -- 补丁 A：让宽度计算不受菜单位置限制
    -- 把菜单位置伪装成 col=0, width=1
    -- 这样内部计算的 right_space = 80-0-1-1 = 78 列直接用满 max_width
    local patched_view = vim.tbl_extend("force", view, {
      col = 0,
      width = 1,
    })
    orig_open(self, e, patched_view, bottom_up)

    -- 补丁 B：重新定位到补全菜单正上方
    if self.window and self.window.win then
      local win_info = vim.fn.getwininfo(self.window.win)[1]
      if win_info then
        local doc_win = self.window.win
        local doc_w = win_info.width or 40
        local doc_h = win_info.height or 10

        -- 计算边框占用
        local doc_config = cmp_config.get().window.documentation
        local border_info = window_util.get_border_info({ style = doc_config })
        local border_v = border_info.vert or 0

        -- 新行：菜单行 - 文档高 - 边框，至少在第 1 行
        local new_row = view.row - doc_h - border_v - 1
        if new_row < 1 then new_row = 1 end

        -- 新列：与菜单左对齐，但不超过屏幕右边
        local new_col = math.min(view.col, vim.o.columns - doc_w - 1)
        new_col = math.max(0, new_col)

        vim.api.nvim_win_set_config(doc_win, {
          relative = "editor",
          row = new_row,
          col = new_col,
        })
      end
    end
  end
end)

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
    print('Mason is not available. Install language servers with brew/npm, or enable mason in local.vim.')
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
" Snippet 编辑工具：按文件类型自动打开对应的 snippets 文件
" ---------------------------------------------------------------------------
lua << EOF
function _G.edit_current_snippets()
  local ft = vim.bo.filetype
  -- 文件类型 → snippets 文件名映射
  local snippet_files = {
    cpp = "cpp.snippets",
    c = "c.snippets",
    python = "python.snippets",
    go = "go.snippets",
    lua = "lua.snippets",
    rust = "rust.snippets",
    javascript = "javascript.snippets",
    typescript = "typescript.snippets",
    markdown = "markdown.snippets",
    sh = "sh.snippets",
    bash = "sh.snippets",
    zsh = "sh.snippets",
    json = "json.snippets",
    yaml = "yaml.snippets",
    dart = "dart.snippets",
    swift = "swift.snippets",
    terraform = "terraform.snippets",
    java = "java.snippets",
    cs = "csharp.snippets",
  }
  local filename = snippet_files[ft] or ft .. ".snippets"
  local dir = vim.fn.expand("~/.config/nvim/snippets")
  local path = dir .. "/" .. filename

  vim.fn.mkdir(dir, "p")

  -- 文件不存在则创建模板
  if not vim.uv.fs_stat(path) then
    local template = "snippet 触发词\n\t${1}\n"
    vim.fn.writefile(vim.split(template, "\n"), path)
  end

  -- 打开文件
  vim.cmd("e " .. path)

  -- 定位"触发词"并进入覆盖编辑模式
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  for i, line in ipairs(lines) do
    local col = line:find("触发词")
    if col then
      vim.api.nvim_win_set_cursor(0, { i - 1, col - 1 })
      vim.cmd("normal! ciw")
      vim.cmd("startinsert")
      return
    end
  end
end
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

" 以下映射必须在外部文件之后，确保优先级最高
" Select 模式（LuaSnip 占位符选中状态）：恢复按键为字母输入而非方向键，
" 解决 Colemak 映射导致 n/e/u/i 被解释成方向键、无法覆盖占位符默认文本的问题
snoremap <silent> u u
snoremap <silent> n n
snoremap <silent> e e
snoremap <silent> i i
snoremap <silent> h h
snoremap <silent> U U
snoremap <silent> E E
snoremap <silent> N N
snoremap <silent> I I

silent! nohlsearch
