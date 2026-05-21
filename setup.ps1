# Claude Code 전역 설정 설치 스크립트 (Windows PowerShell)
# 사용법: 저장소 루트에서 실행
#   git clone <repo-url>
#   cd claude-md
#   .\setup.ps1

$ErrorActionPreference = "Stop"

$ClaudeDir  = "$env:USERPROFILE\.claude"
$AgentsDir  = "$ClaudeDir\agents"
$RepoRoot   = $PSScriptRoot

Write-Host ""
Write-Host "=== Claude Code 전역 설정 설치 ===" -ForegroundColor Cyan
Write-Host "설치 경로: $ClaudeDir"
Write-Host ""

# 1. 디렉터리 생성
if (-not (Test-Path $ClaudeDir))  { New-Item -ItemType Directory -Path $ClaudeDir  | Out-Null }
if (-not (Test-Path $AgentsDir))  { New-Item -ItemType Directory -Path $AgentsDir  | Out-Null }

# 2. CLAUDE.md 설치 (기존 파일 백업)
$Target = "$ClaudeDir\CLAUDE.md"
if (Test-Path $Target) {
    $Bak = "$ClaudeDir\CLAUDE.md.bak"
    Copy-Item $Target $Bak -Force
    Write-Host "[백업] 기존 CLAUDE.md -> CLAUDE.md.bak" -ForegroundColor Yellow
}
Copy-Item "$RepoRoot\CLAUDE.md" $Target -Force
Write-Host "[설치] CLAUDE.md -> $Target" -ForegroundColor Green

# 3. Agent MD 설치
$AgentFiles = @(
    @{ src = "agents\ORCHESTRATOR.md"; dest = "orchestrator-sita.md" },
    @{ src = "agents\BACKEND.md";       dest = "backend-sigma.md"     },
    @{ src = "agents\FRONTEND.md";      dest = "frontend-pixel.md"    },
    @{ src = "agents\VALIDATOR.md";     dest = "validator-monami.md"  }
)

foreach ($f in $AgentFiles) {
    $Src  = Join-Path $RepoRoot $f.src
    $Dest = Join-Path $AgentsDir $f.dest
    Copy-Item $Src $Dest -Force
    Write-Host "[설치] $($f.dest) -> $AgentsDir" -ForegroundColor Green
}

Write-Host ""
Write-Host "설치 완료!" -ForegroundColor Cyan
Write-Host "Claude Code를 재시작하면 에이전트가 활성화됩니다."
Write-Host ""
