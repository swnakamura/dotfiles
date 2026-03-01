#!/bin/bash

# 引数として tmux からの情報を受け取る
PANE_CMD=$1
WINDOW_INDEX=$2
WINDOW_NAME=$3
WINDOW_PANES=$4
WINDOW_BELL=$5
WINDOW_ACTIVITY=$6
WINDOW_LAST=$7
WINDOW_ZOOMED=$8
IS_CURRENT=$9

# 1. アイコンの判定
if [ "$WINDOW_BELL" = "1" ]; then
    ICON="🔔"
elif [[ "$PANE_CMD" =~ ^(gh|claude)$ ]]; then
    ICON="🤖"
elif [ "$PANE_CMD" = "nvim" ]; then
    ICON=""
elif [ "$WINDOW_ACTIVITY" = "1" ]; then
    # アクティビティ（他ウィンドウでの更新）を優先
    ICON="🟡"
elif [[ ! "$PANE_CMD" =~ ^(sh|bash|zsh|fish|man)$ ]]; then
    # shell以外の何かが実行中なら緑
    ICON="🟢"
else
    # 何もしていない待機状態
    ICON="⚫"
fi

# 2. 直近ウィンドウフラグ
LAST_FLAG=""
if [ "$WINDOW_LAST" = "1" ]; then
    LAST_FLAG=" 󰕌 "
fi

# 3. ペイン数・ズーム状態
PANE_INFO=""
if [ "$WINDOW_PANES" -gt 1 ]; then
    if [ "$WINDOW_ZOOMED" = "1" ]; then
        PANE_INFO=" 🔍"
    else
        PANE_INFO="($WINDOW_PANES)"
    fi
fi

# 最終的な出力を組み立て
# ここで #[fg=...] などの装飾もまとめて出力できます
if [ $IS_CURRENT = 0 ]; then
    echo "#[fg=colour237,bg=default]#[fg=colour244,bg=colour237]${ICON}${LAST_FLAG} ${WINDOW_INDEX}:${WINDOW_NAME}${PANE_INFO}#[fg=colour237,bg=default]"
else
    echo "#[fg=colour24,bg=colour235]#[fg=colour255,bg=colour24,bold]${ICON}${LAST_FLAG} ${WINDOW_INDEX}:${WINDOW_NAME}${PANE_INFO}#[fg=colour24,bg=colour235]"
fi
