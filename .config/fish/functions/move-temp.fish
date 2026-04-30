function move-temp
    set CACHE_ROOT /d/temp/snakamura/caches
    if not test -d $CACHE_ROOT
        echo (set_color red)"❌ エラー:"(set_color normal)" $CACHE_ROOT が存在しません。先に作成してください"
        return 1
    end
    set orig_path (string trim $argv[1] --right --chars=/) # Remove trailing slash as it breaks ln command
    if not test -e $orig_path
        echo (set_color red)"❌ エラー:"(set_color normal)" $orig_path は存在しません"
        return 1
    end
    if test -L $orig_path
        echo (set_color yellow)"⚠️ 警告:"(set_color normal)" $orig_path は既にシンボリックリンクです"
        return 1
    end
    set link_name (string replace -a "/" "_" (realpath $orig_path))
    set link_path "$CACHE_ROOT/$link_name"
    if test -e $link_path
        read -l -P (set_color yellow)"⚠️  $link_path は既に存在します。上書きしますか？ [y/N] "(set_color normal) REPLY
        if test "$REPLY" != "y"
            echo (set_color blue)"ℹ️ 中止されました"(set_color normal)
            return 1
        end
        set link_path_old "$link_path"_old_(date +%s)
        echo (set_color cyan)"🔄 古いファイルを動かし、消しています: $link_path_old"(set_color normal)
        mv $link_path $link_path_old
        rm -rf $link_path_old &
    end
    echo (set_color cyan)"🔄 $orig_path を移動しています..."(set_color normal)
    mv $orig_path $link_path
    if test $status -ne 0
        echo (set_color red)"❌ エラー:"(set_color normal)" 移動に失敗しました"
        echo "   手動で削除してから実行してください: ln -s $link_path $orig_path"
        return 1
    end
    ln -s $link_path $orig_path
    echo (set_color green)"✅ 成功:"(set_color normal)" $orig_path を $link_path に移動しました"
end
