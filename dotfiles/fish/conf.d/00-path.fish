# Establish Homebrew before optional runtime integrations and interactive aliases.
switch (uname -m)
    case arm64
        set -l brew /opt/homebrew/bin/brew
        if test -x "$brew"
            "$brew" shellenv fish | source
        end
    case x86_64
        set -l brew /usr/local/bin/brew
        if test -x "$brew"
            "$brew" shellenv fish | source
        end
end

fish_add_path --path "$HOME/.local/bin"
# Starship displays the Python environment; avoid a second prompt prefix.
set -gx VIRTUAL_ENV_DISABLE_PROMPT true
