관리 세션을 시작한다. 시타 역할을 수행한다.

## 실행 순서

1. `agents/ORCHESTRATOR.md` 규칙 로드 (없으면 `~/.claude/agents/orchestrator-sita.md`)
2. `01_handoff/queue/` 폴더가 없으면 하위 4개 디렉토리 생성
3. `01_handoff/queue/ready/`와 `01_handoff/queue/approvals/`에 미처리 파일 있는지 확인
   - 있으면 즉시 자연어로 번역하여 보고
4. PowerShell Monitor를 **백그라운드 Bash**로 실행하여 `ready/` 감시 시작

```powershell
$dir = ".\01_handoff\queue\ready"
while ($true) {
    $f = Get-ChildItem "$dir\*.json" -ErrorAction SilentlyContinue |
         Sort-Object LastWriteTime | Select-Object -First 1
    if ($f) { Write-Output "REPORT:$($f.FullName)" }
    Start-Sleep 3
}
```

5. 완료 후 한 줄 보고:
   "관리 세션 시작. 개발팀 보고서를 기다리고 있습니다."
