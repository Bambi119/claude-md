개발 세션을 시작한다. 시그마(백엔드)·픽셀(프론트)·모나미(검수) 역할을 수행한다.

## 실행 순서

### 0. 진행 상태 확인 (세션 재시작 대비) — 항상 먼저 실행

`01_handoff/progress.md`가 있으면 읽는다:
- `active_task`가 현재 처리할 next-task의 task_id와 일치하면 → `Step Status` 확인
  - `sigma: passing` → 시그마 건너뜀
  - `pixel: passing` → 픽셀 건너뜀
- `active_task`가 다른 task_id이면 → Step Status 무시, 새 작업으로 처리

`01_handoff/_registry.md`가 있으면 읽는다:
- 해당 task_id의 status가 `completed`이면 → 작업 전체 건너뜀. "이미 완료된 작업입니다. 다음 next-task를 기다립니다." 출력 후 3단계로 이동

### 1. approvals/ 확인

`01_handoff/queue/approvals/`에 미처리 결정 파일(`approval_*.json`)이 있으면 **먼저 읽고 처리**
- approved → 다음 next-task 실행
- revise → instruction 내용으로 수정 재작업
- hold / cancel → 대기 또는 중단

### 2. next-task 실행

`01_handoff/queue/ready/`에 `next-task_*.json`이 있으면:

1. 읽는 즉시 `.claude/dev-active` 생성, `progress.md` 상단 갱신:
   ```
   active_task: {task_id}
   session_count: 이전값 + 1
   Next Action: {goal 첫 줄}
   ```
2. Step Status에 따라 건너뛸 스텝 결정 (0단계 확인 결과 적용)
3. 실행 방식 결정:
   - `"parallel": true` → 시그마·픽셀 Agent로 **동시 호출**
   - `"parallel": false` 또는 없음 → 시그마 → 픽셀 순차
4. 각 에이전트 완료 직후 `progress.md` Step Status 갱신:
   - 시그마 완료 → `sigma: passing`
   - 픽셀 완료 → `pixel: passing`
5. 모나미 검수 → report.json 투입 → `monami: passing` → `.claude/dev-active` 삭제

### 3. 아무 파일도 없으면

"대기 중. 관리 세션에서 next-task가 오면 시작합니다."
