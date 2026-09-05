# Startup snippets live in conf.d; autoloaded commands live in functions.
# Private server shortcuts and credentials belong in the ignored local.fish file.
if test -f "$__fish_config_dir/local.fish"
    source "$__fish_config_dir/local.fish"
end

if status is-interactive; and type -q starship
    starship init fish | source
end
