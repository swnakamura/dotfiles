function run-in-all-servers
    # 引数をそのままコマンド文字列として取得
    set -l cmd $argv

    # コマンドが指定されていなければ使い方を表示して終了
    if test -z "$cmd"
        echo "Usage: run-in-all-servers <command>"
        return 1
    end

    # サーバーリスト（コメントアウトした行はそのまま削除または # で無効化）
    set -l servers \
        humpback \
        #shark \
        orca \
        barracuda \
        clione \
        seal \
        walrus \
        rockhopper \
        stingray \
        #crayfish \
        starfish \
        #catfish

    # 各サーバーでコマンドを実行
    for server in $servers
        printf "\033[1;33m$server\033[0m: \033[34m$cmd\033[0m\n"
        ssh -t $server "$cmd" 2>/dev/null
        echo ""
    end
end
