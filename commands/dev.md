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
7. 처리한 **next-task 파일만** `processing/` → `01_handoff/queue/done/`으로 이동한다.
   ⚠️ **report.json은 절대 옮기지 않는다 — `ready/`에 그대로 둔다.**
   매니저가 `ready/`에서 보고서를 읽고 `done/`으로 옮기는 것이 규칙이다.
   데브가 보고서를 미리 치우면 매니저(와 큐 감시기)가 보고서를 영영 못 본다.
8. `ready/`에 또 다른 `next-task_*.json`이 남아 있으면 → 2단계를 처음부터 다시 실행
   (FIFO로 다음 작업 처리). 없으면 → 3단계로 이동
   (※ `ready/`에 report.json이 남아 있는 것은 정상이다 — 데브는 next-task만 신경 쓴다)

### 3. next-task가 없으면 — 대기

`ready/`에 처리할 `next-task_*.json`이 없으면 (세션 시작 시점이든, 2단계 작업을 막 끝낸 직후든):

- 출력: "대기 중 — 다음 회차에 큐를 다시 확인합니다."
- 여기서 이번 회차를 마친다. `/loop` 모드면 다음 주기에 0단계부터 자동 재실행된다.

## 자동 반복 — `/loop`

데브 세션을 자동화하려면 데브 창에서 **한 번만** 입력한다:

```
/loop 5m /dev
```

→ 5분마다 `/dev` 절차(0~3단계)가 자동 실행된다.
→ 관리 세션이 `ready/`에 next-task를 발행하면, 다음 주기에 데브가 스스로 픽업·처리한다.
→ 사용자가 데브 창을 직접 깨울 필요가 없다.

> `/loop`는 이 세션 안에서 도는 자체 반복이라 tmux·psmux 같은 멀티플렉서와 무관하다.
> 세션 창을 닫으면 멈춘다. 루프는 7일 후 만료되므로 장기 운영 시 다시 걸어 준다.
