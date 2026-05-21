#!/usr/bin/env bash
# Claude Code 원격 설치 스크립트 (SSH 환경용)
# Private 저장소에서 직접 받아 설치합니다
#
# 사용법:
#   bash install-remote.sh
#   → PAT 입력 프롬프트가 뜨면 GitHub PAT 붙여넣기 (화면에 표시 안 됨)
#
# 또는 PAT를 환경변수로 전달:
#   GITHUB_PAT=your_token bash install-remote.sh

set -euo pipefail

REPO="Bambi119/claude-md"
BRANCH="main"
TMPDIR_INSTALL="$(mktemp -d)"
CLAUDE_DIR="$HOME/.claude"
AGENTS_DIR="$CLAUDE_DIR/agents"
COMMANDS_DIR="$CLAUDE_DIR/commands"

# ── PAT 수신 (선택) ───────────────────────────────────────
# Public 저장소는 PAT 없이도 동작합니다.
# 터미널에서 직접 실행할 때만 프롬프트가 표시됩니다.
if [ -z "${GITHUB_PAT:-}" ] && [ -t 0 ]; then
    echo ""
    read -r -s -p "GitHub PAT (없으면 Enter 그냥 누르기): " GITHUB_PAT
    echo ""
fi

# ── 저장소 클론 ───────────────────────────────────────────
echo ""
echo "=== Claude Code 원격 설치 ==="
echo "저장소 다운로드 중..."

if [ -n "${GITHUB_PAT:-}" ]; then
    CLONE_URL="https://${GITHUB_PAT}@github.com/${REPO}.git"
else
    CLONE_URL="https://github.com/${REPO}.git"
fi

git clone --quiet --depth 1 --branch "$BRANCH" \
    "$CLONE_URL" \
    "$TMPDIR_INSTALL/repo"

# ── 디렉터리 생성 ─────────────────────────────────────────
mkdir -p "$CLAUDE_DIR"
mkdir -p "$AGENTS_DIR"
mkdir -p "$COMMANDS_DIR"

# ── CLAUDE.md 설치 ────────────────────────────────────────
TARGET="$CLAUDE_DIR/CLAUDE.md"
if [ -f "$TARGET" ]; then
    cp "$TARGET" "$CLAUDE_DIR/CLAUDE.md.bak"
    echo "[백업] 기존 CLAUDE.md → CLAUDE.md.bak"
fi
cp "$TMPDIR_INSTALL/repo/CLAUDE.md" "$TARGET"
echo "[설치] CLAUDE.md → $TARGET"

# ── Agent MD 설치 ─────────────────────────────────────────
install_agent() {
    local src="$1"
    local dest_name="$2"
    cp "$TMPDIR_INSTALL/repo/$src" "$AGENTS_DIR/$dest_name"
    echo "[설치] $dest_name → $AGENTS_DIR"
}

install_agent "agents/ORCHESTRATOR.md" "orchestrator-sita.md"
install_agent "agents/BACKEND.md"       "backend-sigma.md"
install_agent "agents/FRONTEND.md"      "frontend-pixel.md"
install_agent "agents/VALIDATOR.md"     "validator-monami.md"

# ── 슬래시 명령어 설치 ────────────────────────────────────
for f in end.md start.md new.md; do
    cp "$TMPDIR_INSTALL/repo/commands/$f" "$COMMANDS_DIR/$f"
    echo "[설치] $f → $COMMANDS_DIR"
done

# ── 정리 ──────────────────────────────────────────────────
rm -rf "$TMPDIR_INSTALL"
unset GITHUB_PAT

echo ""
echo "설치 완료!"
echo "Claude Code를 재시작하면 에이전트와 슬래시 명령어가 활성화됩니다."
echo "  /new   — GitHub 최신 설정 업데이트 + 프로젝트 초기화"
echo "  /start — 세션 시작 시 맥락 복원"
echo "  /end   — 세션 종료 전 저장"
echo ""
