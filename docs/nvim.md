# Nvim setup memo

## Additional setup recommended for neovim

### Bob Version Manager

[Bob]() is a version manager for neovim.
Requires `rust` to install.

#### Install rustup

For Linux and MacOS:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

For Windows:
Install rustup from [here](https://rustup.rs/)

#### Install Bob

```bash
cargo install --git https://github.com/MordechaiHadad/bob.git
```

```bash
bob install latest
```

```bash
bob use latest
```

### Nerd Fonts

Fonts needs to be installed and set in the terminal for icons to be displayed correctly.

[Nerd Fonts](https://www.nerdfonts.com/)
Using `CaskaydiaMono Nerd Font`
