function gc --description 'Commit with a message'
    if test (count $argv) -eq 0
        printf 'Give your commit a message: gc "What changed"\n' >&2
        return 1
    end
    git commit -m (string join ' ' -- $argv)
end
