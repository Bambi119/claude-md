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

### 2. 01_handoff/ 폴더 확인
프로젝트 루트에 01_handoff/ 폴더가 없으면 생성한다.

### 3. 완료 보고
아래 내용을 한국어로 간략히 보고한다:
- 업데이트 성공 여부
- 설치된 에이전트: 시타·시그마·픽셀·모나미
- 사용 가능한 명령어: /new /start /end
