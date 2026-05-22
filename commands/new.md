GitHub에서 Claude MD 설정을 최신 버전으로 업데이트하고, 현재 프로젝트의 기본 구조를 준비한다.

## 업데이트 소스
https://github.com/Bambi119/claude-md

## 실행 순서

### 1. GitHub에서 최신 설정 다운로드
아래 명령어를 실행한다:

```bash
bash <(curl -s https://raw.githubusercontent.com/Bambi119/claude-md/main/install-remote.sh)
```

오류가 발생하면 내용을 보고하고 중단한다.

### 2. 프로젝트 폴더 구조 초기화
프로젝트 루트에 아래 구조가 없으면 생성한다:

```
01_handoff/
├── queue/
│   ├── ready/        ← 보고서·지시서 투입 지점
│   ├── processing/   ← 처리 중 임시 보관
│   ├── approvals/    ← 사용자 결정 파일
│   └── done/         ← 완료 보관
├── context.md        (없으면 생략)
├── decisions.md      (없으면 생략)
├── progress.md       (없으면 생략)
└── next-task.md      (없으면 생략)
```

생성 명령:
```bash
mkdir -p 01_handoff/queue/ready 01_handoff/queue/processing 01_handoff/queue/approvals 01_handoff/queue/done
```

### 3. 완료 보고
아래 내용을 한국어로 간략히 보고한다:
- 업데이트 성공 여부
- 설치된 에이전트: 시타·시그마·픽셀·모나미
- 사용 가능한 명령어: /new /start /end
- 폴더 구조: 01_handoff/queue/ 하위 4개 디렉토리 준비 완료
