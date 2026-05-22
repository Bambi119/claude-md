현재 세션의 작업 내용을 핸드오프 파일로 저장하고 컨텍스트 초기화를 준비한다.

## 실행 순서

### 1. 01_handoff/ 폴더 확인
프로젝트 루트에 01_handoff/ 폴더가 없으면 생성한다.

### 2. 파일 저장 (4개)

**01_handoff/progress.md** — 상단 헤더 덮어쓰기 + `---` 이하 날짜별 append

**상단 헤더 (항상 덮어쓰기, 50줄 이하 유지):**
```
last_updated: YYYY-MM-DDTHH:MM
active_task: task_NNN (현재 진행 중인 task_id, 없으면 none)
last_commit: (git rev-parse --short HEAD 결과)
session_count: N  (dev.md에서 이미 +1 갱신됨 — 이 값 그대로 유지, 재증가 금지)

## Step Status
- sigma: pending | in_progress | passing
- pixel: pending | in_progress | passing
- monami: pending | in_progress | passing

## Next Action
[step_status 기준으로 passing이 아닌 첫 스텝을 명시.
 예: sigma pending → "시그마 — {goal}"
     sigma failed → "시그마 재실행 (이전 모나미 FAIL 결과 참고)"
     sigma passing, pixel pending → "픽셀 — {goal} 재개"
     전체 passing → "모나미 검수 결과 대기 중"]

## Blockers
[막힌 것 또는 "없음"]
```

**`---` 이하 세션 기록 (날짜별 append):**
오늘 날짜 헤더와 함께 아래를 추가한다:
- 완료된 기능 목록
- 수정된 문제 목록
- 완료된 검수 결과

**01_handoff/decisions.md** — 누적 기록 (날짜별 append)
오늘 날짜 헤더와 함께 아래를 추가한다:
- 어떤 결정을 했는지
- 왜 그 결정을 했는지 (# WHY: 포함)
- 고려했다가 버린 대안

**01_handoff/next-task.md** — 덮어쓰기
다음 세션에서 바로 시작할 작업 목록 (우선순위 순):
- 가장 먼저 할 작업
- 순서대로 이어질 작업들
- 해결 안 된 문제나 막힌 것

**01_handoff/context.md** — 덮어쓰기
반드시 기억해야 할 중요 맥락:
- 반복되는 문제 패턴
- 프로젝트 특이사항 및 주의점
- 사용 중인 외부 서비스·API 정보

### 3. 보고
저장한 내용을 한국어로 요약 보고한다.
함수명·변수명·에러 코드 없이, 기획자가 이해할 수 있는 말로.

### 4. 안내
다음 문장으로 마무리한다:
"핸드오프 완료. /clear 를 입력해서 컨텍스트를 초기화하세요. 재시작 시 /start → /dev 또는 /start → /manager 순서로 세션을 재개합니다."
