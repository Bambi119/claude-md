# Claude MD

Claude Code 전역 설정 · 에이전트 · 슬래시 명령어 관리 저장소

---

## 새 머신에 설치할 때

### Claude Code 채팅창에 붙여넣기

```
bash <(curl -s https://raw.githubusercontent.com/Bambi119/claude-md/main/install-remote.sh) 실행해줘
```

> 이후 업데이트는 `/new` 명령어로 자동 처리됩니다.

---

## 로컬 직접 설치

```powershell
# Windows
git clone https://github.com/Bambi119/claude-md.git
cd claude-md
.\setup.ps1
```

```bash
# Mac / Linux
git clone https://github.com/Bambi119/claude-md.git
cd claude-md
bash setup.sh
```

---

## 슬래시 명령어

| 명령어 | 기능 |
|--------|------|
| `/new` | GitHub 최신 설정 자동 업데이트 + 프로젝트 초기화 |
| `/manager` | 관리 세션 시작 — 작업 지시 · 보고서 검토 · 승인 |
| `/dev` | 개발 세션 시작 — 백엔드 · 프론트 · 검수 실행 |
| `/start` | 이전 세션 맥락 복원 · 오늘 작업 계획 수립 |
| `/end` | 현재 세션 저장 · 컨텍스트 초기화 준비 |

---

## 에이전트 팀

| 이름 | 역할 |
|------|------|
| 시타 (orchestrator) | 기획서 관리 · 작업 지시 · 보고서 대조 검토 |
| 시그마 (backend) | API · DB · 서비스 구현 |
| 픽셀 (frontend) | UI 구현 |
| 모나미 (validator) | 코드 검수 · 보안 점검 · 보고서 작성 |

> 이중 세션 운영 방식은 [`DUAL-SESSION-GUIDE.md`](DUAL-SESSION-GUIDE.md) 참조.
