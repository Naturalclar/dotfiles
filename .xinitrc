usermodmap = [$HOME/.Xmodmap]

if [ -f $usermodmap ]; then
    xmodmap $usermodmap
fi

# set default screen resolution
xrandr --output eDP1 --mode 1920x1080

# Start i3 window manager 
exec i3

