개발 세션을 시작한다. 시그마(백엔드)·픽셀(프론트)·모나미(검수) 역할을 수행한다.

## 실행 순서

### 0. 진행 상태 확인 (세션 재시작 대비) — 항상 먼저 실행

**이 세션의 tmux pane 기록** — 큐 감시기(queue-watcher)가 이 창을 깨울 수 있도록:
```bash
[ -n "$TMUX_PANE" ] && echo "$TMUX_PANE" > 01_handoff/.dev-pane
```

`01_handoff/progress.md`가 있으면 읽는다:
- `active_task`가 현재 처리할 next-task의 task_id와 일치하면 → `Step Status` 확인
  - **`passing`인 스텝만 건너뜀.** `pending` · `in_progress` · `failed` 상태는 모두 실행한다
  - 예: `sigma: passing` → 시그마 건너뜀 / `sigma: failed` → 시그마 재실행 (이전 모나미 FAIL 결과 참고)
- `active_task`가 다른 task_id이면 → Step Status 무시, 새 작업으로 처리

**세션 재시작 복원**: `active_task`가 있고 Step Status에 미완료 스텝(`pending`·`in_progress`·`failed`)이 남아 있으면
→ 진행 중이던 작업이다. 그 next-task 파일은 `01_handoff/queue/processing/`에 있다.
→ `processing/next-task_*.json`을 읽어 **2단계의 3~8번을 이어서 실행**한다
   (1번 파일 이동은 이미 끝남 — 건너뜀).

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
2. `progress.md` 상단 갱신:
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
6. 모나미 검수 → report.json 투입 → `monami: passing`
7. 처리한 next-task 파일을 `processing/` → `01_handoff/queue/done/`으로 이동
8. `ready/`에 또 다른 `next-task_*.json`이 남아 있으면 → 2단계를 처음부터 다시 실행
   (FIFO로 다음 작업 처리). 없으면 → 3단계로 이동

### 3. next-task가 없으면 — 대기

`ready/`에 처리할 `next-task_*.json`이 없으면 (세션 시작 시점이든, 2단계 작업을 막 끝낸 직후든):

- 출력: "대기 중. 큐 감시기(queue-watcher)가 새 작업이 오면 이 창을 깨웁니다."
- 별도 감시 루프를 띄우지 않는다. 여기서 세션 응답을 마친다.

## 작업 자동 수신

데브 세션은 잠들어도 된다. 관리 세션이 next-task를 발행하면
**큐 감시기(`queue-watcher.sh`)가 이 창에 `/dev`를 입력해 자동으로 깨운다.**
깨어나면 0단계부터 다시 실행되어 새 작업을 픽업한다.

> 큐 감시기가 실행 중이어야 자동 수신이 동작한다.
> 프로젝트 폴더에서 `bash 01_handoff/queue-watcher.sh` 로 띄워 둔다.
