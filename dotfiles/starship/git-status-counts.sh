#!/bin/sh

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

status_output=$(git status --short --branch 2>/dev/null) || exit 0

printf '%s\n' "$status_output" | awk '
BEGIN {
    modified = 0
    untracked = 0
    staged = 0
    renamed = 0
    deleted = 0
    conflicted = 0
    ahead = 0
    behind = 0
}

NR == 1 {
    if (match($0, /\[ahead [0-9]+\]/)) {
        ahead = substr($0, RSTART + 7, RLENGTH - 8) + 0
    }
    if (match($0, /\[behind [0-9]+\]/)) {
        behind = substr($0, RSTART + 8, RLENGTH - 9) + 0
    }
    if (match($0, /\[ahead [0-9]+, behind [0-9]+\]/)) {
        split(substr($0, RSTART + 1, RLENGTH - 2), parts, /, /)
        sub(/^ahead /, "", parts[1])
        sub(/^behind /, "", parts[2])
        ahead = parts[1] + 0
        behind = parts[2] + 0
    }
    next
}

{
    x = substr($0, 1, 1)
    y = substr($0, 2, 1)

    if (x == "?" && y == "?") {
        untracked++
        next
    }

    if ((x == "U") || (y == "U") || (x == "A" && y == "A") || (x == "D" && y == "D")) {
        conflicted++
    }

    if (x == "R") {
        renamed++
    }

    if (x == "D") {
        deleted++
    }

    if (x != " " && x != "?" && x != "U" && x != "D" && x != "R") {
        staged++
    }

    if (y != " " && y != "?") {
        modified++
    }
}

END {
    out = ""

    if (conflicted > 0) {
        out = out sep "=" conflicted
        sep = "|"
    }
    if (deleted > 0) {
        out = out sep "✘" deleted
        sep = "|"
    }
    if (renamed > 0) {
        out = out sep "»" renamed
        sep = "|"
    }
    if (modified > 0) {
        out = out sep "!" modified
        sep = "|"
    }
    if (staged > 0) {
        out = out sep "+" staged
        sep = "|"
    }
    if (untracked > 0) {
        out = out sep "?" untracked
        sep = "|"
    }

    if (ahead > 0 && behind > 0) {
        out = out sep "⇕⇡" ahead "⇣" behind
        sep = "|"
    } else if (ahead > 0) {
        out = out sep "⇡" ahead
        sep = "|"
    } else if (behind > 0) {
        out = out sep "⇣" behind
        sep = "|"
    }

    if (out != "") {
        printf "%s", out
    }
}
'
