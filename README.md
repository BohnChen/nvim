# Colemak Neovim Lite

一份面向 Apple Silicon Mac 的轻量 Neovim 配置。它从原本复杂的 Neovim 配置中保留了 Colemak 键位习惯、常用文本编辑增强和必要的代码补全能力，同时移除了容易在插件更新后导致启动报错的 `coc.nvim` 链路。

这份配置使用：

- `vim-plug` 管理插件
- Neovim 内置 LSP 提供语言服务
- `nvim-cmp` 提供补全菜单
- `mason.nvim` 安装常用 language server

配置文件目标路径：

```text
~/.config/nvim/init.vim
```

## 适用人群

- 使用 Colemak 键盘布局的人。
- 想从复杂 `coc.nvim` 配置迁移到更轻、更容易排错的 Neovim 配置的人。
- 希望保留代码补全、跳转定义、hover、重命名、诊断等基础 IDE 能力的人。
- 使用 M 系列芯片 Mac 作为主力开发机的人。
- 想把旧配置和新配置完全区分开，重新安装一套干净 Neovim 环境的人。

## 适用平台

主要适配：

- macOS
- Apple Silicon Mac
- Neovim 0.11+

理论上也可用于 Linux，但这份配置的路径、安装方式和测试目标主要按 macOS 主力开发机设计。

## 软件要求

必需：

- Neovim 0.11 或更新版本
- `git`
- `curl`

推荐：

- Homebrew
- Node.js / npm，用于安装 TypeScript、HTML、CSS、JSON、Bash、YAML、Prisma 等 language server
- Go，用于安装 `gopls`
- clangd，用于 C / C++ / Objective-C
- Python 3，用于 Python 开发环境

检查 Neovim 版本：

```sh
nvim --version
```

检查常用命令：

```sh
git --version
curl --version
node --version
npm --version
go version
clangd --version
```

## 安装方式

### 1. 备份旧配置

如果你已经有自己的 Neovim 配置，先备份：

```sh
mv ~/.config/nvim ~/.config/nvim.bak
```

也可以只备份旧的 `init.vim`：

```sh
cp ~/.config/nvim/init.vim ~/.config/nvim/init.vim.bak
```

### 2. 放入新配置

创建配置目录：

```sh
mkdir -p ~/.config/nvim
```

复制本配置：

```sh
cp init.vim ~/.config/nvim/init.vim
```

### 3. 第一次启动

打开 Neovim：

```sh
nvim
```

如果 `~/.config/nvim/autoload/plug.vim` 不存在，配置会自动下载 `vim-plug`，并在首次启动时自动执行：

```vim
:PlugInstall
```

如果自动安装没有触发，也可以手动执行：

```vim
:LiteInstallPlug
:source $MYVIMRC
:PlugInstall
```

插件安装完成后，重启 Neovim。

### 4. 安装核心 LSP

重启后执行：

```vim
:LiteLspInstallCore
```

这个命令会通过 Mason 安装核心 language server：

```text
lua-language-server
pyright
typescript-language-server
html-lsp
css-lsp
json-lsp
gopls
clangd
bash-language-server
```

安装进度可通过 Mason 查看：

```vim
:Mason
```

查看 Mason 日志：

```vim
:MasonLog
```

## 插件管理

本配置使用 `vim-plug` 管理插件。

安装插件：

```vim
:PlugInstall
```

更新插件：

```vim
:PlugUpdate
```

查看插件状态：

```vim
:PlugStatus
```

清理未声明插件：

```vim
:PlugClean
```

升级 `vim-plug` 自身：

```vim
:PlugUpgrade
```

插件默认安装目录：

```text
~/.config/nvim/plugged
```

`vim-plug` 本体路径：

```text
~/.config/nvim/autoload/plug.vim
```

## 功能亮点

- 保留 Colemak 风格方向键：`u/n/e/i` 对应上/左/下/右。
- 不加载 `coc.nvim`，避免 Coc 扩展更新导致启动报错。
- 使用 Neovim 内置 LSP，减少外部框架依赖。
- 使用 `nvim-cmp` 提供补全菜单。
- 使用 Mason 安装和管理 language server。
- 支持 C/C++、Go、Python、TypeScript/JavaScript、HTML、CSS、JSON、Lua、Bash 等核心语言。
- 提供 `:LspEnabled`、`:LspMissing`、`:LspInfo` 三个检查命令。
- 插件配置以轻量编辑体验为主，默认关闭 Copilot、Treesitter、gitsigns、文件管理器等较重功能。
- 支持 `~/.config/nvim/local.vim` 做本地开关和机器特定配置。
- 保留原配置中的窗口管理、tab 管理、Markdown、注释、surround、undotree、多光标等常用操作。

## 默认插件分类

### 补全和 LSP

```text
hrsh7th/nvim-cmp
hrsh7th/cmp-nvim-lsp
hrsh7th/cmp-buffer
hrsh7th/cmp-path
hrsh7th/cmp-cmdline
mason-org/mason.nvim
```

### 视觉和基础增强

```text
theniceboy/nvim-deus
theniceboy/eleline.vim
itchyny/vim-cursorword
RRethy/vim-illuminate
airblade/vim-rooter
```

### 查找和导航

```text
junegunn/fzf
junegunn/fzf.vim
pechorin/any-jump.vim
```

### 文件类型支持

```text
elzr/vim-json
neoclide/jsonc.vim
othree/html5.vim
alvan/vim-closetag
pangloss/vim-javascript
MaxMEllon/vim-jsx-pretty
leafgarland/typescript-vim
peitalin/vim-jsx-typescript
styled-components/vim-styled-components
pantharshit00/vim-prisma
fatih/vim-go
Vimjas/vim-python-pep8-indent
tweekmonster/braceless.vim
dart-lang/dart-vim-plugin
keith/swift.vim
arzg/vim-swift
wlangstroth/vim-racket
hashivim/vim-terraform
```

### 文本编辑

```text
mbbill/undotree
jiangmiao/auto-pairs
mg979/vim-visual-multi
theniceboy/tcomment_vim
tpope/vim-surround
gcmt/wildfire.vim
junegunn/vim-after-object
godlygeek/tabular
tpope/vim-capslock
svermeulen/vim-subversive
theniceboy/argtextobj.vim
rhysd/clever-f.vim
AndrewRadev/splitjoin.vim
theniceboy/pair-maker.vim
theniceboy/vim-move
Yggdroot/indentLine
```

### Markdown 和写作

```text
dhruvasagar/vim-table-mode
mzlogin/vim-markdown-toc
dkarter/bullets.vim
junegunn/goyo.vim
reedes/vim-wordy
```

## LSP 支持

配置中内置了以下 language server 配置。只有当对应命令存在时才会启用。

| 语言 | LSP 名称 | 检测命令 |
| --- | --- | --- |
| Lua | `lua_ls` | `lua-language-server` |
| Python | `pyright` | `pyright-langserver` |
| TypeScript / JavaScript | `ts_ls` | `typescript-language-server` |
| HTML | `html` | `vscode-html-language-server` |
| CSS / SCSS / Less | `cssls` | `vscode-css-language-server` |
| JSON / JSONC | `jsonls` | `vscode-json-language-server` |
| Bash / Shell | `bashls` | `bash-language-server` |
| YAML | `yamlls` | `yaml-language-server` |
| Go | `gopls` | `gopls` |
| C / C++ / Objective-C | `clangd` | `clangd` |
| Rust | `rust_analyzer` | `rust-analyzer` |
| Dart | `dartls` | `dart` |
| Swift | `sourcekit` | `sourcekit-lsp` |
| Prisma | `prismals` | `prisma-language-server` |
| Terraform | `terraformls` | `terraform-ls` |
| Markdown | `marksman` | `marksman` |
| Java | `jdtls` | `jdtls` |
| C# | `omnisharp` | `omnisharp` 或 `OmniSharp` |

检查当前机器可启用的 LSP：

```vim
:LspEnabled
```

检查缺失的 LSP 命令：

```vim
:LspMissing
```

检查当前 buffer 已 attach 的 LSP：

```vim
:LspInfo
```

如果某个语言出现在 `:LspMissing` 中，只说明该语言服务器当前机器没有安装；不影响其他语言使用。

## 补全操作

插入模式下：

| 快捷键 | 功能 |
| --- | --- |
| `<Tab>` | 选择下一个补全项，或触发补全 |
| `<S-Tab>` | 选择上一个补全项 |
| `<CR>` | 确认补全 |
| `<C-Space>` | 手动触发补全 |
| `<C-e>` | 关闭补全菜单 |
| `<C-d>` | 补全文档向下滚动 |
| `<C-u>` | 补全文档向上滚动 |

补全来源包括：

- LSP
- 当前 buffer
- 文件路径
- 命令行

## LSP 快捷键

以下快捷键在 LSP attach 到当前 buffer 后生效。

| 快捷键 | 功能 |
| --- | --- |
| `gd` | 跳转到定义 |
| `gD` | 新 tab 中跳转到定义 |
| `gy` | 跳转到类型定义 |
| `gr` | 查找引用 |
| `<Leader>rn` | 重命名 |
| `<Leader>a` | Code action |
| `<Leader>h` | Hover 文档 |
| `<Leader>d` | 将诊断放入 location list |
| `<Leader>-` | 上一个诊断 |
| `<Leader>=` | 下一个诊断 |
| `<Leader>lf` | 格式化当前 buffer |

`<Leader>` 是空格键。

## Colemak 快捷键

### 基础操作

| 快捷键 | 功能 |
| --- | --- |
| `;` | 进入命令行模式，相当于 `:` |
| `S` | 保存 |
| `Q` | 退出 |
| `<Leader>rc` | 编辑当前 Neovim 配置 |
| `<Leader>rv` | 编辑当前目录下 `.nvimrc` |
| `k` | 插入，相当于原生 `i` |
| `K` | 行首插入，相当于原生 `I` |
| `l` | 撤销，相当于原生 `u` |
| `Y` | 可视模式复制到系统剪贴板 |
| `,.` | 匹配括号跳转 |
| `<Leader><CR>` | 取消搜索高亮 |
| `<Leader>dw` | 查找相邻重复单词 |
| `<Leader>tt` | 将 4 个空格替换为 tab |
| `<Leader>o` | 打开或关闭当前折叠 |
| `<C-y>` | 插入 `{}` 并进入中间新行 |

### 光标移动

| 快捷键 | 功能 |
| --- | --- |
| `u` | 上 |
| `n` | 左 |
| `e` | 下 |
| `i` | 右 |
| `U` | 上移 5 行 |
| `E` | 下移 5 行 |
| `N` | 行首 |
| `I` | 行尾 |
| `gu` | 按屏幕行上移 |
| `ge` | 按屏幕行下移 |
| `W` | 后移 5 个 word |
| `B` | 前移 5 个 word |
| `h` | 到 word 结尾 |
| `<C-U>` | 视窗向上滚动 |
| `<C-E>` | 视窗向下滚动 |

### 命令行模式

| 快捷键 | 功能 |
| --- | --- |
| `<C-a>` | 到命令行开头 |
| `<C-e>` | 到命令行结尾 |
| `<C-p>` | 上一条命令 |
| `<C-n>` | 下一条命令 |
| `<C-b>` | 左移 |
| `<C-f>` | 右移 |
| `<M-b>` | 向左跳一个词 |
| `<M-w>` | 向右跳一个词 |

## 窗口和 Tab 管理

### 窗口

| 快捷键 | 功能 |
| --- | --- |
| `<Leader>w` | 切换窗口 |
| `<Leader>u` | 切到上方窗口 |
| `<Leader>e` | 切到下方窗口 |
| `<Leader>n` | 切到左侧窗口 |
| `<Leader>i` | 切到右侧窗口 |
| `qf` | 只保留当前窗口 |
| `su` | 向上创建水平分屏 |
| `se` | 向下创建水平分屏 |
| `sn` | 向左创建垂直分屏 |
| `si` | 向右创建垂直分屏 |
| `<Up>` | 增加窗口高度 |
| `<Down>` | 减少窗口高度 |
| `<Left>` | 减少窗口宽度 |
| `<Right>` | 增加窗口宽度 |
| `sh` | 改为上下布局 |
| `sv` | 改为左右布局 |
| `srh` | 旋转为上下布局 |
| `srv` | 旋转为左右布局 |
| `<Leader>q` | 关闭当前窗口下方窗口 |

### Tab

| 快捷键 | 功能 |
| --- | --- |
| `tu` | 新建 tab |
| `tU` | 当前窗口复制到新 tab |
| `tn` | 上一个 tab |
| `ti` | 下一个 tab |
| `tmn` | 当前 tab 左移 |
| `tmi` | 当前 tab 右移 |

## 文本和 Markdown 快捷键

| 快捷键 | 功能 |
| --- | --- |
| `<Leader><Leader>` | 跳到下一个 `<++>` 占位符并编辑 |
| `<Leader>sc` | 开关拼写检查 |
| `` ` `` | 切换大小写 |
| `<C-c>` | 当前行居中 |
| `\s` | 快速进入全文替换 |
| `<Leader>sw` | 开关自动换行 |
| `\p` | 显示当前文件完整路径 |
| `<Leader>tm` | Table Mode 开关 |
| `ga` | 可视模式下 Tabular 对齐 |
| `<Leader>cn` | 注释 |
| `<Leader>cu` | 取消注释 |
| `L` | 打开撤销树 |
| `<C-b>` | wildfire 快速选择 |

## 常用检查命令

确认配置路径：

```vim
:echo $MYVIMRC
```

查看启动消息：

```vim
:messages
```

查看插件状态：

```vim
:PlugStatus
```

查看 Mason：

```vim
:Mason
```

查看启用的 LSP：

```vim
:LspEnabled
```

查看缺失的 LSP 命令：

```vim
:LspMissing
```

查看当前 buffer 的 LSP：

```vim
:LspInfo
```

检查 `nvim-cmp`：

```vim
:lua print(require("cmp") and "cmp ok")
```

检查当前 buffer 的 LSP client：

```vim
:lua for _, c in ipairs(vim.lsp.get_clients({bufnr=0})) do print(c.name) end
```

检查快捷键来源：

```vim
:verbose nmap u
:verbose nmap n
:verbose nmap e
:verbose nmap i
:verbose nmap k
:verbose nmap l
```

## 本地覆盖配置

你可以创建：

```text
~/.config/nvim/local.vim
```

这个文件会在插件声明前被读取，适合放机器本地开关。

启用 Copilot：

```vim
let g:lite_enable_copilot = 1
```

启用 Treesitter：

```vim
let g:lite_enable_treesitter = 1
```

启用 gitsigns、hlslens、colorizer、spectre：

```vim
let g:lite_enable_lua_extras = 1
```

启用 lazygit、joshuto、rnvimr：

```vim
let g:lite_enable_file_managers = 1
```

关闭 Mason 插件声明：

```vim
let g:lite_enable_mason = 0
```

关闭首次启动自动安装 `vim-plug`：

```vim
let g:lite_auto_install_plug = 0
```

## 常见问题

### 1. `:PlugInstall` 不存在

说明 `vim-plug` 还没有安装。执行：

```vim
:LiteInstallPlug
:source $MYVIMRC
:PlugInstall
```

### 2. `:LspMissing` 里有很多语言

这只是表示这些 language server 当前机器没装。不写对应语言可以忽略。

例如：

```text
rust_analyzer [rust-analyzer]
yamlls [yaml-language-server]
omnisharp [omnisharp|OmniSharp]
```

不会影响 C++、Go、Python、TypeScript 等已经安装好的 LSP。

### 3. `gopls` 安装失败，提示 Go 版本过低

新版 `gopls` 可能要求更新的 Go 工具链。如果看到类似：

```text
requires go >= 1.26.0
GOTOOLCHAIN=local
```

可以执行：

```sh
go env -w GOTOOLCHAIN=auto
```

然后回到 Neovim：

```vim
:MasonUninstall gopls
:MasonInstall gopls
```

### 4. `:LspInfo` 之前不存在

这份配置已经提供了自定义 `:LspInfo`。如果你的本机还提示不存在，说明还没有替换到最新 `init.vim`，或 Neovim 没有读取当前配置。

检查：

```vim
:echo $MYVIMRC
```

### 5. C++ 有补全和跳转，但 `:LspMissing` 还有内容

这是正常的。C++ 使用 `clangd`，只要当前 C++ buffer 中：

```vim
:LspInfo
```

能看到 `clangd`，并且 `gd` 能跳转定义，就说明 C++ LSP 正常。

## 设计取舍

这份配置刻意没有默认启用：

- `coc.nvim`
- Copilot
- Treesitter
- gitsigns
- nvim-spectre
- lazygit
- rnvimr
- joshuto

原因是它们都更容易受到 Node、Lua、外部二进制、插件更新或系统 PATH 的影响。默认配置优先保证启动稳定、补全可用、编辑顺手；需要更强功能时再通过 `local.vim` 打开。

## 总结

这是一份轻量但可写代码的 Neovim 配置。它不是完整 IDE 大而全方案，而是一套稳定、易排错、保留 Colemak 手感的主力开发配置。

推荐安装路径：

```text
~/.config/nvim/init.vim
```

推荐首次安装流程：

```sh
mkdir -p ~/.config/nvim
cp init.vim ~/.config/nvim/init.vim
nvim
```

进入 Neovim 后：

```vim
:PlugInstall
:LiteLspInstallCore
```

最终验收：

```vim
:PlugStatus
:LspEnabled
:LspMissing
:LspInfo
```
