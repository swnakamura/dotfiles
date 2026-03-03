#!/bin/bash

# Git helper functions

git_co() {
    local args="$@"
    if [ -z "$args" ]; then
        local branch=$(
            {
                git branch --all --format='%(refname:short)' | grep -v HEAD
                git tag
            } | fzf --preview 'echo {} | xargs git log --color=always'
        )
        if [ -n "$branch" ]; then
            git checkout $(echo $branch | sed 's#remotes/##')
        fi
    else
        git checkout $args
    fi
}

git_cot() {
    local args="$@"
    if [ -z "$args" ]; then
        local branch=$(git branch --remote --format='%(refname:short)' | grep -v HEAD | fzf --preview 'echo {} | xargs git log --color=always')
        if [ -n "$branch" ]; then
            git checkout -t $(echo $branch | sed 's#remotes/##')
        fi
    else
        git checkout -t $args
    fi
}

git_coh() {
    local args="$@"
    if [ -z "$args" ]; then
        local hash=$(git log --oneline | fzf --preview 'echo {} | cut -d" " -f1 | xargs git show --color=always')
        if [ -n "$hash" ]; then
            git checkout ${hash%% *}
        fi
    else
        git checkout $args
    fi
}

git_sw() {
    local args="$@"
    if [ -z "$args" ]; then
        local branch=$(git branch --all | grep -v HEAD | fzf --preview 'echo {} | cut -c 3- | xargs git log --color=always' | cut -c 3-)
        if [ -n "$branch" ]; then
            git switch $(echo $branch | sed 's#remotes/##')
        fi
    else
        git switch $args
    fi
}

git_swc() {
    local args="$@"
    if [ -z "$args" ]; then
        local branch=$(git branch --all | grep -v HEAD | fzf --preview 'echo {} | cut -c 3- | xargs git log --color=always' | cut -c 3-)
        if [ -n "$branch" ]; then
            git switch -c $(echo $branch | sed 's#remotes/##')
        fi
    else
        git switch -c $args
    fi
}

git_swC() {
    local args="$@"
    if [ -z "$args" ]; then
        local branch=$(git branch --all | grep -v HEAD | fzf --preview 'echo {} | cut -c 3- | xargs git log --color=always' | cut -c 3-)
        if [ -n "$branch" ]; then
            git switch -C $(echo $branch | sed 's#remotes/##')
        fi
    else
        git switch -C $args
    fi
}

git_brd() {
    local args="$@"
    if [ -z "$args" ]; then
        local branch=$(git branch --all | grep -v HEAD | fzf --preview 'echo {} | cut -c 3- | xargs git log --color=always' | cut -c 3-)
        if [ -n "$branch" ]; then
            git branch -d $(echo $branch | sed 's#remotes/##')
        fi
    else
        git branch -d $args
    fi
}

git_brD() {
    local args="$@"
    if [ -z "$args" ]; then
        local branch=$(git branch --all | grep -v HEAD | fzf --preview 'echo {} | cut -c 3- | xargs git log --color=always' | cut -c 3-)
        if [ -n "$branch" ]; then
            git branch -D $(echo $branch | sed 's#remotes/##')
        fi
    else
        git branch -D $args
    fi
}

git_diff_fzf() {
    local args="$@"
    [ -z "$args" ] && args=HEAD
    ([ "$args" = "HEAD" ] && git status --short || git diff --name-status $args | sed 's/\t/  /') | fzf --preview "echo {} | cut -c 4- | xargs git diff --color=always $args --" --multi --height 90% | cut -c 4-
}