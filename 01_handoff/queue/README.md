# 파일 큐 — 개발 ↔ 관리 세션 통신

> v2.0 | 세션 간 통신은 이 폴더의 JSON 파일로만 이뤄진다.
> 운영 흐름 전체는 루트의 `DUAL-SESSION-GUIDE.md`,
> 세션별 상세 규약은 `agents/ORCHESTRATOR.md`·`commands/dev.md` 참조.

---

## 디렉토리 역할

```
01_handoff/queue/
├── ready/        트리거 지점 — 보고서(report)·지시서(next-task) 투입
├── processing/   개발 세션이 픽업한 next-task 보관 (중복 픽업 방지)
├── approvals/    관리 → 개발 승인·결정 파일(approval)
└── done/         처리 완료 파일 보관
```

---

## 파일 명명 규칙

```
report_{ts}_{task_id}.json      개발 → 관리  완료 보고서
next-task_{ts}_{task_id}.json   관리 → 개발  작업 지시서
approval_{ts}_{task_id}.json    관리 → 개발  승인·결정
```

`ts` 형식: `YYYYMMDD_HHMMSS`

---

## 파일 이동 규칙

| 파일 | 투입 | 픽업·처리 | 완료 이동 |
|------|------|----------|----------|
| next-task | 관리 → `ready/` | 개발이 `ready/` → `processing/` | 개발이 `processing/` → `done/` |
| report | 개발 → `ready/` | 관리가 `ready/`에서 읽음 | 관리가 `ready/` → `done/` |
| approval | 관리 → `approvals/` | 개발이 `approvals/`에서 읽음 | 개발이 `approvals/` → `done/` |

> **핵심**: 파일을 집어든 세션이 이동 책임을 진다.
> `processing/`은 **next-task 전용** — 개발 세션 감시 루프의 중복 픽업을 막는 격리 공간이다.
> 보고서·승인 파일은 `processing/`을 거치지 않고 `ready/`(또는 `approvals/`)에서 `done/`으로 직행한다.

---

## 스키마 파일

| 파일 | 용도 |
|------|------|
| `report.schema.json` | 개발 세션 완료 보고서 |
| `approval.schema.json` | 관리 세션 승인·결정 |
| `next-task.schema.json` | 관리 세션 작업 지시서 |
| `EXAMPLE_report.json` | 보고서 작성 예시 |
