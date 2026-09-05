# Preserve these integrations when their tools exist; this does not install them.
status is-interactive; or return

if type -q fnm
    fnm env --use-on-cd --shell fish | source
end
if test -f "$HOME/.cargo/env.fish"
    source "$HOME/.cargo/env.fish"
end
