function fcopy --description "フルパスを引数に取り、そのファイルをクリップボードにコピーする"
    if test (count $argv) -ne 1
        echo "使用法: fcopy <ファイルのフルパス>"
        return 1
    end

    # 渡された引数をフルパスとして使用
    set file_path $argv[1]

    # AppleScriptを実行して、ファイルオブジェクトをクリップボードに設定
    osascript -e "set the clipboard to (POSIX file \"$file_path\")"

    if test $status -eq 0
        echo "✅ '$file_path' をクリップボードにコピーしました。"
    else
        echo "❌ ファイルのコピーに失敗しました。"
        return 1
    end
end
