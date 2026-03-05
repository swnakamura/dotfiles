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
    LAST_FLAG="󰕌 "
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
STATUS_BG="colour235"
CURRENT_FG="#cdd6f4"
CURRENT_BG2="#385f9d"
CURRENT_BG1="#42435c"
ALTRNAT_BG="#42435c"
ALTRNAT_FG="#cdd6f4"

if [ $IS_CURRENT = 1 ]; then
    echo "#[fg=$CURRENT_BG2,bg=$STATUS_BG]#[fg=$CURRENT_FG,bg=$CURRENT_BG2]${LAST_FLAG}${WINDOW_INDEX} ${ICON} #[fg=$CURRENT_FG,bg=$CURRENT_BG1,bold] ${WINDOW_NAME}${PANE_INFO}#[fg=$CURRENT_BG1,bg=$STATUS_BG]"
else
    echo "#[fg=$ALTRNAT_BG ,bg=$STATUS_BG]#[fg=$ALTRNAT_FG,bg=$ALTRNAT_BG ]${LAST_FLAG}${WINDOW_INDEX} ${ICON} #[fg=$ALTRNAT_FG,bg=$ALTRNAT_BG      ] ${WINDOW_NAME}${PANE_INFO}#[fg=$ALTRNAT_BG,bg=$STATUS_BG ]"
fi
