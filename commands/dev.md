개발 세션을 시작한다. 시그마(백엔드)·픽셀(프론트)·모나미(검수) 역할을 수행한다.

## 실행 순서

### 0. 진행 상태 확인 (세션 재시작 대비) — 항상 먼저 실행

`01_handoff/progress.md`가 있으면 읽는다:
- `active_task`가 현재 처리할 next-task의 task_id와 일치하면 → `Step Status` 확인
  - **`passing`인 스텝만 건너뜀.** `pending` · `in_progress` · `failed` 상태는 모두 실행한다
  - 예: `sigma: passing` → 시그마 건너뜀 / `sigma: failed` → 시그마 재실행 (이전 모나미 FAIL 결과 참고)
- `active_task`가 다른 task_id이면 → Step Status 무시, 새 작업으로 처리

**세션 재시작 복원**: `active_task`가 있고 Step Status에 미완료 스텝(`pending`·`in_progress`·`failed`)이 남아 있으면
→ 진행 중이던 작업이다. 그 next-task 파일은 `01_handoff/queue/processing/`에 있다.
→ `processing/next-task_*.json`을 읽어 **2단계의 3~8번을 이어서 실행**한다
   (1번 파일 이동은 이미 끝남 — 건너뜀 / `.claude/dev-active`가 없으면 재생성).

`01_handoff/_registry.md`가 있으면 읽는다:
- 해당 task_id의 status가 `completed`이면 → 작업 전체 건너뜀. "이미 완료된 작업입니다. 다음 next-task를 기다립니다." 출력 후 3단계로 이동

### 1. approvals/ 확인

`01_handoff/queue/approvals/`에 미처리 결정 파일(`approval_*.json`)이 있으면 **먼저 읽고 처리**
- approved → 다음 next-task 실행
- revise → instruction 내용으로 수정 재작업
- hold / cancel → 대기 또는 중단

### 2. next-task 실행

`01_handoff/queue/ready/`에 `next-task_*.json`이 있으면:

1. 가장 오래된 next-task 하나를 골라 `01_handoff/queue/processing/`으로 이동
   (`ready/`에서 제거 — 감시 루프 중복 픽업 방지 + 여러 작업이 쌓였을 때 FIFO 순서 보장):
   ```bash
   f=$(ls -tr 01_handoff/queue/ready/next-task_*.json 2>/dev/null | head -1)
   [ -n "$f" ] && mv "$f" 01_handoff/queue/processing/
   ```
   이후 단계는 `processing/`으로 옮긴 이 파일을 대상으로 진행한다.
2. `.claude/dev-active` 생성, `progress.md` 상단 갱신:
   ```
   active_task: {task_id}
   session_count: 이전값 + 1
   Next Action: {goal 첫 줄}
   ```
3. Step Status에 따라 건너뛸 스텝 결정 (0단계 확인 결과 적용)
4. 실행 방식 결정:
   - `"parallel": true` → 시그마·픽셀 Agent로 **동시 호출**
   - `"parallel": false` 또는 없음 → 시그마 → 픽셀 순차
5. 각 에이전트 완료 직후 `progress.md` Step Status 갱신:
   - 시그마 완료 → `sigma: passing`
   - 픽셀 완료 → `pixel: passing`
6. 모나미 검수 → report.json 투입 → `monami: passing` → `.claude/dev-active` 삭제
7. 처리한 next-task 파일을 `processing/` → `01_handoff/queue/done/`으로 이동
8. **작업 완료 후 멈추지 말고 곧바로 3단계(감시 대기)로 이동**

### 3. next-task가 없으면 — 감시 대기

`ready/`에 처리할 `next-task_*.json`이 없으면 (세션 시작 시점이든, 2단계 작업을 막 끝낸 직후든):

1. 출력: "대기 중. 관리 세션에서 다음 작업이 오면 자동으로 시작합니다."
2. 아래 스크립트를 **백그라운드 Bash**로 실행한다 (`run_in_background: true` — 세션이 잠들지 않도록):

```bash
dir="./01_handoff/queue/ready"
while true; do
    f=$(ls -tr "$dir"/next-task_*.json 2>/dev/null | head -1)
    if [ -n "$f" ]; then echo "TASK:$f"; fi
    sleep 3
done
```

3. Monitor 도구로 위 백그라운드 프로세스의 출력을 감시한다
4. `TASK:경로`가 출력되면 → **2단계를 즉시 실행** (새 next-task 자동 픽업)
5. 픽업 후 작업이 끝나면 다시 이 3단계로 돌아와 감시를 계속한다

> 이 감시 루프 덕분에 사용자가 데브 창을 직접 깨울 필요가 없다.
> 매니저가 작업을 발행하는 즉시 데브 세션이 스스로 픽업한다.
