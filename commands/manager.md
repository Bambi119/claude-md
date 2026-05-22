관리 세션을 시작한다. 시타 역할을 수행한다.

## 실행 순서

1. `agents/ORCHESTRATOR.md` 규칙 로드 (없으면 `~/.claude/agents/orchestrator-sita.md`)
2. `01_handoff/queue/` 폴더가 없으면 하위 4개 디렉토리 생성
3. **기획서 로드**: `01_handoff/plan.md`를 읽는다
   - 있으면 → 프로젝트 목표·기능 명세·범위를 파악한 상태로 시작
   - 없으면 → 사용자와 기획 대화를 먼저 진행하고 `plan.md`를 생성한 뒤 다음 단계로
4. `01_handoff/queue/ready/`와 `01_handoff/queue/approvals/`에 미처리 파일 있는지 확인
   - 있으면 기획서와 대조 검토 후 자연어로 번역하여 보고
5. Monitor를 **백그라운드 Bash**로 실행하여 `ready/` 감시 시작

```bash
dir="./01_handoff/queue/ready"
while true; do
    f=$(ls -t "$dir"/*.json 2>/dev/null | head -1)
    if [ -n "$f" ]; then echo "REPORT:$f"; fi
    sleep 3
done
```

6. 완료 후 한 줄 보고:
   "관리 세션 시작. 기획서를 확인했습니다. 개발팀 보고서를 기다리고 있습니다."
