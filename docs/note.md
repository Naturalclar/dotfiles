### Basic Commands

`dw` - copy word
`dd` - delete line
`yy` - yank line
`gg` - move cursor to start of file
`G` - move cursor to end of file
`/` - search for text. `n` to go to the next search result
`u` - undo
`i` - enter instert mode
`o` - insert line
`p` - paste line
`$` - move cursor to end of line
`0` - move cursor to start of line
`_` - move curtor to beggining of line
`yyp` - copy current line to below line
`:s/foo/bar/` - replace the first `foo` in current line to `bar`
`:s/foo/bar/g` - replace all instances of `foo` in current line to `bar`
`:%s/foo/bar/g` - replace all instances of `foo` in current file to `bar`
`:.,+2s/foo/bar/g` - replace all instances of `foo` in current and following 2 lines to `bar`
`:m-2` - move current line to 2 lines above
`:vs` - create vertical split
`:sp` - create horitontal split
`yi"` - yank inside `""`
`yi(` - yank inside `()`
`2yi(` - yank inside `()` including `()`
`K` - show signature help. similar to hovering code in vscode
`dt:` - delete up till the next `:` excluding `:`
`df:` - delete up till the next `:` including `:`
`%` - move to matching bracket/parenthesis

### Select multiple lines

`Ctrl + V` to enter visual block mode
Select lines you want to edit
`Shidt + I` to enter insert mode
Enter text you want to insert in the first line
Press `esc` to apply changes to all lines

### Vim Visible Multi

`<C-n>` - select multiple cursors

### Code actions on nvim

You can enter `<leader>ca` to apply code actions.

### Find files on lazy vim

You can enter `<leader>space` to find files on lazy vim

### Grep files on lazy vim

You can enter `<leader>/` to grep fiels on lazy vim

### Repeat previous sed command

You can enter `:&` to repeat previous sed command

### LazyVim Commands

`]d` - move to next diagnostic
`<leader>bb` - switch tabs

### Open terminal on vim

`<C-/>` - opens terminal inside vim session

### Oil.nvim

`-` - open oil.nvim

#### Inside Oil.nvim

`<CR>` - open selected file or directory
`-` - go up to previous directory
`g.` - show hidden files
