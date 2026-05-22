# 파일 큐 시스템 — 개발 ↔ 관리 세션 자동 통신

> v1.0 | 2026-05-22

---

## 디렉토리 역할

```
01_handoff/queue/
├── ready/        ← 개발 세션이 완료 보고서 투입 / 관리 세션이 next-task 투입 (트리거 지점)
├── processing/   ← 관리 세션이 처리 시작 시 이동 (중복 처리 방지)
├── approvals/    ← 관리 세션이 사용자 결정 기록 (※ 01_handoff/decisions.md 히스토리 파일과 별개)
└── done/         ← 처리 완료된 파일 보관
```

---

## 파일 명명 규칙

```
report_{ts}_{task_id}.json       예) report_20260522_143012_task_001.json
approval_{ts}_{task_id}.json     예) approval_20260522_143025_task_001.json
next-task_{ts}_{task_id}.json    예) next-task_20260522_143030_task_002.json
```

---

## 자동화 흐름

```
[개발 세션]                           [관리 세션]
    │                                      │
    │ 1. 작업 완료                         │ ← Monitor 실행 중
    │                                      │   (ready/ 폴더 감시)
    │ 2. report_{ts}.json                  │
    │    → ready/ 에 작성      ──감지──→  │
    │                                      │ 3. processing/ 으로 이동
    │                                      │ 4. impact 필드 읽어 자연어 번역
    │                                      │ 5. 사용자에게 제시 (선택지 3개)
    │                                      │ 6. approval_{ts}.json → approvals/
    │                                      │ 7. next-task_{ts}.json 작성 → ready/
    │                                      │ 8. 보고서 → done/ 이동
    │                                      │
    │ ← approvals/ 확인 (작업 시작 전)    │
    │   결정에 따라 다음 작업 실행         │
```

---

## 개발 세션 규약

### 보고서 작성 시 필수 규칙
1. `impact.user_visible` — **기술 용어 금지**, 사용자가 체감하는 변화만
2. `impact.irreversible` — 되돌릴 수 없는 것이 없으면 반드시 `null`
3. `tech_detail` — 있는 그대로 기술 (관리 세션에서 숨김 처리)
4. 파일명: `report_{YYYYMMDD_HHMMSS}_{task_id}.json`
5. 저장 위치: `01_handoff/queue/ready/`

### 작업 시작 전 결정 파일 확인
```
01_handoff/queue/approvals/ 에 미처리 파일이 있으면:
  → 읽고 decision 값에 따라 분기
  → approved: 다음 next-task 실행
  → revise: instruction 내용으로 수정 후 재실행
  → hold / cancel: 대기 또는 중단
```

---

## 관리 세션 규약

### Monitor 스크립트 (세션 시작 시 실행)
```powershell
$dir = ".\01_handoff\queue\ready"
while ($true) {
    $f = Get-ChildItem "$dir\*.json" -ErrorAction SilentlyContinue |
         Sort-Object LastWriteTime | Select-Object -First 1
    if ($f) { Write-Output "REPORT:$($f.FullName)" }
    Start-Sleep 3
}
```

### 자연어 번역 규칙 (사용자 브리핑 형식)
```
이번 작업: {task}
상태: {status → 한국어}

사용자에게 미치는 영향:
  → {impact.user_visible}

주의: {impact.irreversible — 있으면 ⚠️ 표시, 없으면 "되돌릴 수 없는 변경 없음"}

부수 영향: {impact.side_effects — 없으면 생략}

---
어떻게 할까요?
[✅ 승인] [✏️ 수정 요청] [🔍 더 알아보기]
```

### 결정 처리 후 정리
- 보고서 → `processing/` → 처리 후 `done/`
- 결정 파일 → `approvals/` (개발 세션이 가져간 후 `done/`으로 이동)

---

## 스키마 파일

| 파일 | 용도 |
|------|------|
| `report.schema.json` | 개발 세션 완료 보고서 스키마 |
| `approval.schema.json` | 관리 세션 결정 파일 스키마 |
| `next-task.schema.json` | 관리 세션 작업 지시서 스키마 |
| `EXAMPLE_report.json` | 보고서 예시 |
