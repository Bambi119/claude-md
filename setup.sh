#!/usr/bin/env bash
# Claude Code 전역 설정 설치 스크립트 (Mac / Linux)
# 사용법: 저장소 루트에서 실행
#   git clone <repo-url>
#   cd claude-md
#   bash setup.sh

set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
AGENTS_DIR="$CLAUDE_DIR/agents"
COMMANDS_DIR="$CLAUDE_DIR/commands"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "=== Claude Code 전역 설정 설치 ==="
echo "설치 경로: $CLAUDE_DIR"
echo ""

# 1. 디렉터리 생성
mkdir -p "$CLAUDE_DIR"
mkdir -p "$AGENTS_DIR"
mkdir -p "$COMMANDS_DIR"

# 2. CLAUDE.md 설치 (기존 파일 백업)
TARGET="$CLAUDE_DIR/CLAUDE.md"
if [ -f "$TARGET" ]; then
    cp "$TARGET" "$CLAUDE_DIR/CLAUDE.md.bak"
    echo "[백업] 기존 CLAUDE.md -> CLAUDE.md.bak"
fi
cp "$REPO_ROOT/CLAUDE.md" "$TARGET"
echo "[설치] CLAUDE.md -> $TARGET"

# 3. Agent MD 설치
install_agent() {
    local src="$1"
    local dest_name="$2"
    cp "$REPO_ROOT/$src" "$AGENTS_DIR/$dest_name"
    echo "[설치] $dest_name -> $AGENTS_DIR"
}

install_agent "agents/ORCHESTRATOR.md" "orchestrator-sita.md"
install_agent "agents/BACKEND.md"       "backend-sigma.md"
install_agent "agents/FRONTEND.md"      "frontend-pixel.md"
install_agent "agents/VALIDATOR.md"     "validator-monami.md"

# 4. 슬래시 명령어 설치
# ※ 명령어 목록 변경 시 install-remote.sh · setup.ps1 · commands/new.md 도 함께 수정
for f in new.md start.md end.md manager.md dev.md; do
    cp "$REPO_ROOT/commands/$f" "$COMMANDS_DIR/$f"
    echo "[설치] $f -> $COMMANDS_DIR"
done

# 5. 큐 감시기 설치
cp "$REPO_ROOT/queue-watcher.sh" "$CLAUDE_DIR/queue-watcher.sh"
echo "[설치] queue-watcher.sh -> $CLAUDE_DIR"

echo ""
echo "설치 완료!"
echo "Claude Code를 재시작하면 에이전트와 슬래시 명령어가 활성화됩니다."
echo "  /new     — GitHub 최신 설정 업데이트 + 프로젝트 초기화"
echo "  /manager — 관리 세션 시작 (시타)"
echo "  /dev     — 개발 세션 시작 (시그마·픽셀·모나미)"
echo "  /start   — 재시작 시 맥락 복원"
echo "  /end     — 컨텍스트 저장 후 세션 종료"
echo ""
