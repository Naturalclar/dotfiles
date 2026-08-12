# NOTE: mirrors the locale block at the top of .zshrc, which is the source of
# truth. Force a UTF-8 locale so multibyte (e.g. Japanese) renders over SSH
# clients like Termius, which don't forward the locale Terminal.app sets
# locally. Only export a locale that's actually generated -- stock WSL and
# container images ship C.UTF-8 only, and setting an unavailable value makes
# other tools warn on every start.
for l in en_US.UTF-8 C.UTF-8
    if locale -a 2>/dev/null | string match -qir '^'(string split -m1 . $l)[1]'\.utf-?8$'
        set -gx LANG $l
        set -gx LC_ALL $l
        break
    end
end
