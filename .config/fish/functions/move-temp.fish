function move-temp
    set CACHE_ROOT /d/temp/snakamura/caches
    if not test -d $CACHE_ROOT
        echo "$CACHE_ROOT does not exist; create it first"
        return 1
    end
    set orig_path (string trim $argv[1] --right --chars=/) # Remove trailing slash as it breaks ln command
    if not test -e $orig_path
        echo "$orig_path does not exist in the first place; Not doing anything"
        return 1
    end
    if test -L $orig_path
        echo "$orig_path is already a symlink; Not doing anything"
        return 1
    end
    set link_name (string replace -a "/" "_" (realpath $orig_path))
    set link_path "$CACHE_ROOT/$link_name"
    if test -e $link_path
        read -l -P "$link_path already exists; delete it manually. Do you want to overwrite it? [y/N] " REPLY
        if test "$REPLY" != "y"
            return 1
        end
        set link_path_old "$link_path"_old_(date +%s)
        mv $link_path $link_path_old
        rm -rf $link_path_old &
    end
    mv $orig_path $link_path
    if test $status -ne 0
        echo "Failed to move $orig_path to $link_path. Delete the directory manually and run ln -s $link_path $orig_path"
        return 1
    end
    ln -s $link_path $orig_path
    echo "Moved $orig_path to $link_path"
end
