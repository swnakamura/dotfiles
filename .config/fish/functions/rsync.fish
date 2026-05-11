# ~/.config/fish/functions/rsync.fish
function rsync --description 'rsync with default excludes'
    command rsync $argv --exclude-from=$HOME/.rsyncignore
end
