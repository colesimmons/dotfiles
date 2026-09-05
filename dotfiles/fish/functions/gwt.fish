function gwt --description 'Create a dated branch and worktree under .worktrees'
    if test (count $argv) -ne 1; or test -z "$argv[1]"
        printf 'Choose a worktree name: gwt feature-name\n' >&2
        return 1
    end

    set -l root (git rev-parse --show-toplevel); or return
    set -l branch (date +%Y-%m-%d)-$argv[1]
    set -l destination "$root/.worktrees/$branch"
    git check-ref-format --branch "$branch" >/dev/null; or return

    if git show-ref --verify --quiet "refs/heads/$branch"
        printf 'That branch already exists: %s\n' "$branch" >&2
        return 1
    end
    if test -e "$destination"; or test -L "$destination"
        printf 'That worktree location is already in use: %s\n' "$destination" >&2
        return 1
    end

    git worktree add -b "$branch" -- "$destination"; or return
    printf 'Your worktree is ready: %s\n' "$destination"
end
