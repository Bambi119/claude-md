개발 세션을 시작한다. 시그마(백엔드)·픽셀(프론트)·모나미(검수) 역할을 수행한다.

## 실행 순서

1. `01_handoff/queue/approvals/`에 미처리 결정 파일(`approval_*.json`)이 있으면 **먼저 읽고 처리**
   - approved → 다음 next-task 실행
   - revise → instruction 내용으로 수정 재작업
   - hold / cancel → 대기 또는 중단
2. `01_handoff/queue/ready/`에 `next-task_*.json`이 있으면 읽고 작업 시작
3. 아무 파일도 없으면:
   "대기 중. 관리 세션에서 next-task가 오면 시작합니다."
