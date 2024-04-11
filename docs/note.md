### Basic Commands

`dw` - copy word
`dd` - delete line
`yy` - yank line
`gg` - move cursor to start of file
`G` - move cursor to end of file
`/` - search
`u` - undo
`i` - enter instert mode
`o` - insert line
`p` - paste line
`$` - move cursor to end of line
`0` - move cursor to start of line
`yyp` - copy current line to below line
`:s/foo/bar/` - replace the first `foo` in current line to `bar`
`:s/foo/bar/g` - replace all instances of `foo` in current line to `bar`
`:%s/foo/bar/g` - replace all instances of `foo` in current file to `bar`
`:m-2` - move current line to 2 lines above
`:vs` - create vertical split
`:sp` - create horitontal split
`yi"` - yank inside `""`
`yi(` - yank inside `()`

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
