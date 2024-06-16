# Configuring Custom Keymap

`personal.map.gz` contains custom keymap for archlinux.
In order to use this, it must be set in `/etc/vconsole.conf`

Create required directory

```bash
sudo mkdir -p /usr/local/share/kbd/keymaps/
```

Create symbolic link

```bash
sudo cp personal.map /usr/local/share/kbd/keymaps/personal.map
```

Edit `/etc/vconsole.conf`

```
KEYMAP=/usr/local/share/kbd/keymaps/personal.map
```
