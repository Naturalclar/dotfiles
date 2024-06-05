usermodmap=$HOME/.Xmodmap

if [ -f $usermodmap ]; then
    xmodmap $usermodmap
fi

# set default screen resolution
xrandr -s 1920x1080

# if feh command exists, set background image
if command -v feh &> /dev/null; then
  feh --bg-fill /usr/share/backgrounds/default.png
fi

# Start i3 window manager 
exec i3

