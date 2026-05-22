관리 세션을 시작한다. 시타 역할을 수행한다.

## 실행 순서

1. `agents/ORCHESTRATOR.md` 규칙 로드 (없으면 `~/.claude/agents/orchestrator-sita.md`)
2. `01_handoff/queue/` 폴더가 없으면 하위 4개 디렉토리 생성
3. **이 세션의 tmux pane 기록** — 큐 감시기(queue-watcher)가 이 창을 깨울 수 있도록:
   ```bash
   [ -n "$TMUX_PANE" ] && echo "$TMUX_PANE" > 01_handoff/.manager-pane
   ```
4. **기획서 로드**: `01_handoff/plan.md`를 읽는다
   - 있으면 → 프로젝트 목표·기능 명세·범위를 파악한 상태로 시작
   - 없으면 → 사용자와 기획 대화를 먼저 진행하고 `plan.md`를 생성한 뒤 다음 단계로
5. `01_handoff/queue/ready/`와 `01_handoff/queue/approvals/`에 미처리 파일 있는지 확인
   - `report_*.json`이 있으면 → 기획서와 대조 검토 후 자연어로 번역하여 보고 (ORCHESTRATOR.md 2단계)
   - 없으면 → 대기
6. 완료 후 한 줄 보고:
   "관리 세션 시작. 기획서를 확인했습니다. 개발팀 보고서를 기다리고 있습니다."

## 보고서 자동 수신

별도 Monitor를 띄우지 않는다. 개발 세션이 보고서를 투입하면
**큐 감시기(`queue-watcher.sh`)가 이 창에 `/manager`를 입력해 자동으로 깨운다.**
깨어나면 위 5단계부터 다시 실행되어 보고서를 처리한다.

> 큐 감시기가 실행 중이어야 자동 수신이 동작한다. (저장소 루트의 `queue-watcher.sh` 참조)
