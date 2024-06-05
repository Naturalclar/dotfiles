usermodmap = [$HOME/.Xmodmap]

if [ -f $usermodmap ]; then
    xmodmap $usermodmap
fi

# Start i3 window manager 
exec i3

