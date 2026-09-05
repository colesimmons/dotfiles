function gwtr --description 'Remove a worktree while keeping its branch'
    if test (count $argv) -ne 1
        printf 'Choose a worktree path: gwtr .worktrees/name\n' >&2
        return 1
    end
    git worktree remove -- "$argv[1]"; or return
    printf 'Worktree removed. Its branch is still available.\n'
end
