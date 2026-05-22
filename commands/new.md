GitHub에서 Claude MD 설정을 최신 버전으로 업데이트하고, 현재 프로젝트의 기본 구조를 준비한다.

## 업데이트 소스
https://github.com/Bambi119/claude-md

## 실행 순서

### 1. GitHub에서 최신 설정 다운로드
아래 명령어를 실행한다:

```bash
bash <(curl -s https://raw.githubusercontent.com/Bambi119/claude-md/main/install-remote.sh)
```

오류가 발생하면 내용을 보고하고 중단한다.

### 2. 프로젝트 폴더 구조 초기화
프로젝트 루트에 아래 구조가 없으면 생성한다:

```
01_handoff/
├── queue/
│   ├── ready/        ← 보고서·지시서 투입 지점
│   ├── processing/   ← 처리 중 임시 보관
│   ├── approvals/    ← 사용자 결정 파일
│   └── done/         ← 완료 보관
├── context.md        (없으면 생략)
├── decisions.md      (없으면 생략)
├── progress.md       (없으면 생략)
└── next-task.md      (없으면 생략)
```

생성 명령:
```bash
mkdir -p 01_handoff/queue/ready 01_handoff/queue/processing 01_handoff/queue/approvals 01_handoff/queue/done
```

`01_handoff/progress.md`가 없으면 초기 파일 생성:
```bash
cat > 01_handoff/progress.md << 'EOF'
last_updated: (오늘 날짜)
active_task: none
last_commit: none
session_count: 0  # 초기값. 첫 /dev 실행 시 1로 갱신됨

## Step Status
- sigma: pending
- pixel: pending
- monami: pending

## Next Action
관리 세션에서 첫 next-task를 발행하세요.

## Blockers
없음

---
EOF
```

`01_handoff/_registry.md`가 없으면 초기 파일 생성:
```bash
cat > 01_handoff/_registry.md << 'EOF'
# Task Registry

| task_id | task | status | date |
|---------|------|--------|------|
EOF
```

### 3. 슬래시 명령어 전역 등록

아래 명령어를 실행하여 모든 슬래시 명령어를 `~/.claude/commands/`에 설치한다:

```bash
for cmd in new start end manager dev; do
  cp "C:/09_백업/03_claudeMD/commands/${cmd}.md" "$HOME/.claude/commands/${cmd}.md" 2>/dev/null || \
  curl -s "https://raw.githubusercontent.com/Bambi119/claude-md/main/commands/${cmd}.md" \
       -o "$HOME/.claude/commands/${cmd}.md"
done
```

> 로컬 백업 경로가 있으면 복사, 없으면 GitHub에서 직접 다운로드한다.

설치 확인:
```bash
ls ~/.claude/commands/ | grep -E "new|start|end|manager|dev"
```

5개 파일이 모두 확인되면 계속 진행한다.

### 4. 권한 설정 + 구버전 Stop 훅 제거

`.claude/settings.json`이 없으면 아래 내용으로 생성한다:

```bash
mkdir -p .claude
cat > .claude/settings.json << 'EOF'
{
  "permissions": {
    "allow": [
      "Bash(bash *)",
      "Bash(curl *)",
      "Bash(pwsh *)",
      "Bash(powershell *)",
      "Bash(mkdir *)",
      "Bash(cp *)",
      "Bash(mv *)",
      "Bash(rm -f *)",
      "Bash(cat *)",
      "Bash(ls *)",
      "Bash(git *)"
    ]
  }
}
EOF
```

`.claude/settings.json`이 **이미 있으면** 아래를 처리한다:

1. 파일을 Read한다.
2. `hooks` 항목에 `Stop` 훅이 있으면 (특히 `dev-active`를 감지하는 명령) → **`hooks` 항목 전체를 제거**한다.
   > 구버전 잔재다. 데브 세션을 무한 루프에 빠뜨린다. `permissions` 등 나머지 설정은 그대로 보존한다.
3. `permissions.allow`에 위 11개 권한이 빠져 있으면 추가한다.

### 5. 완료 보고
아래 내용을 한국어로 간략히 보고한다:
- 업데이트 성공 여부
- 설치된 에이전트: 시타·시그마·픽셀·모나미
- 사용 가능한 명령어: /new /start /end /manager /dev
- 폴더 구조: 01_handoff/queue/ 하위 4개 디렉토리 준비 완료
