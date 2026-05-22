#!/usr/bin/env bash
# queue-watcher.sh — 파일 큐 감시 → tmux 창 자동 깨우기
#
# 개발/관리 세션(Claude Code 창)은 한 번 잠들면 스스로 깨어나지 못한다.
# 폴더에 파일이 생겨도 누가 입력을 넣어줘야 움직인다.
# 이 스크립트는 상주하며 큐 폴더를 감시하다가, 새 파일이 오면
# 해당 tmux 창에 슬래시 명령을 입력해 깨운다.
#
# ── 사용법 (psmux/tmux 세션 안의 아무 pane에서) ────────────
#   bash queue-watcher.sh                   ← 인자 없이: 열린 창들에서 자동 탐지
#   bash queue-watcher.sh <폴더> [<폴더2>]   ← 또는 폴더를 직접 지정
#
#   감시 주기 변경: WATCH_INTERVAL=3 bash queue-watcher.sh
#
# ── 동작 전제 ──────────────────────────────────────────────
#   각 세션은 시작 시 자기 tmux pane을 아래 파일에 기록한다:
#     <프로젝트>/01_handoff/.manager-pane  ← manager.md가 기록
#     <프로젝트>/01_handoff/.dev-pane      ← dev.md가 기록
#   watcher는 이 파일을 읽어 깨울 창을 찾는다.
#   (세션을 /manager · /dev 로 시작하지 않으면 pane 파일이 없어 깨우지 못한다)

set -u
INTERVAL="${WATCH_INTERVAL:-5}"

# 감시할 프로젝트 폴더 결정 — 인자로 받거나, 없으면 열린 pane에서 자동 탐지
if [ "$#" -gt 0 ]; then
    PROJECTS=("$@")
else
    mapfile -t PROJECTS < <(tmux list-panes -a -F '#{pane_current_path}' 2>/dev/null | sort -u)
    if [ "${#PROJECTS[@]}" -eq 0 ]; then
        echo "감시할 폴더를 찾지 못했습니다."
        echo "사용법: bash queue-watcher.sh [<폴더> ...]"
        echo "(psmux/tmux 세션 안에서 실행하면 인자 없이 자동 탐지합니다)"
        exit 1
    fi
    echo "열린 창에서 ${#PROJECTS[@]}개 폴더를 탐지했습니다 (01_handoff 없는 폴더는 자동 제외)."
fi

declare -A LAST   # 중복 깨움 방지: 키별 마지막으로 알린 파일

echo "큐 감시 시작 — 프로젝트 ${#PROJECTS[@]}개, ${INTERVAL}초 주기. (Ctrl+C 로 중단)"

# 창을 깨운다. 성공 시 0, 실패 시 1 반환.
wake() {
    local pane_file="$1" cmd="$2" pane
    [ -f "$pane_file" ] || return 1
    # 파일에서 pane ID를 읽되 CR/LF/공백을 모두 제거 (줄바꿈 혼입 방지)
    pane=$(tr -d '\r\n\t ' < "$pane_file" 2>/dev/null)
    [ -n "$pane" ] || return 1
    tmux send-keys -t "$pane" "$cmd" Enter
}

while true; do
    for i in "${!PROJECTS[@]}"; do
        proj="${PROJECTS[$i]}"
        ready="$proj/01_handoff/queue/ready"
        [ -d "$ready" ] || continue

        # 데브 깨우기 — next-task 도착 (가장 오래된 것 기준, FIFO)
        nt=$(ls -tr "$ready"/next-task_*.json 2>/dev/null | head -1)
        if [ -n "$nt" ]; then
            if [ "${LAST[dev_$i]:-}" != "$nt" ]; then
                if wake "$proj/01_handoff/.dev-pane" "/dev"; then
                    echo "[$(date +%H:%M:%S)] 데브 깨움 ← $(basename "$nt")"
                else
                    echo "[$(date +%H:%M:%S)] 데브 깨움 실패 — .dev-pane 확인 필요 ($proj)"
                fi
                LAST[dev_$i]="$nt"
            fi
        else
            LAST[dev_$i]=""
        fi

        # 매니저 깨우기 — report 도착
        rp=$(ls -tr "$ready"/report_*.json 2>/dev/null | head -1)
        if [ -n "$rp" ]; then
            if [ "${LAST[mgr_$i]:-}" != "$rp" ]; then
                if wake "$proj/01_handoff/.manager-pane" "/manager"; then
                    echo "[$(date +%H:%M:%S)] 매니저 깨움 ← $(basename "$rp")"
                else
                    echo "[$(date +%H:%M:%S)] 매니저 깨움 실패 — .manager-pane 확인 필요 ($proj)"
                fi
                LAST[mgr_$i]="$rp"
            fi
        else
            LAST[mgr_$i]=""
        fi
    done
    sleep "$INTERVAL"
done
