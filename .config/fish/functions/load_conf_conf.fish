function load_conf_conf
    set -l conf_file $HOME/syncthing_config/secrets.fish
    if test -f $conf_file
        source $conf_file
        echo "Loaded confidential configurations from $conf_file"
    else
        echo "Confidential configuration file $conf_file not found."
    end
end
