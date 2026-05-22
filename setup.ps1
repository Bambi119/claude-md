# Claude Code 전역 설정 설치 스크립트 (Windows PowerShell)
# 사용법: 저장소 루트에서 실행
#   git clone <repo-url>
#   cd claude-md
#   .\setup.ps1

$ErrorActionPreference = "Stop"

$ClaudeDir   = "$env:USERPROFILE\.claude"
$AgentsDir   = "$ClaudeDir\agents"
$CommandsDir = "$ClaudeDir\commands"
$RepoRoot    = $PSScriptRoot

Write-Host ""
Write-Host "=== Claude Code 전역 설정 설치 ===" -ForegroundColor Cyan
Write-Host "설치 경로: $ClaudeDir"
Write-Host ""

# 1. 디렉터리 생성
if (-not (Test-Path $ClaudeDir))   { New-Item -ItemType Directory -Path $ClaudeDir   | Out-Null }
if (-not (Test-Path $AgentsDir))   { New-Item -ItemType Directory -Path $AgentsDir   | Out-Null }
if (-not (Test-Path $CommandsDir)) { New-Item -ItemType Directory -Path $CommandsDir | Out-Null }

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

# 4. 슬래시 명령어 설치
$CommandFiles = @("end.md", "start.md", "new.md", "manager.md", "dev.md")
foreach ($f in $CommandFiles) {
    $Src  = Join-Path $RepoRoot "commands\$f"
    $Dest = Join-Path $CommandsDir $f
    Copy-Item $Src $Dest -Force
    Write-Host "[설치] $f -> $CommandsDir" -ForegroundColor Green
}

Write-Host ""
Write-Host "설치 완료!" -ForegroundColor Cyan
Write-Host "Claude Code를 재시작하면 에이전트와 슬래시 명령어가 활성화됩니다."
Write-Host "  /new   — GitHub 최신 설정 업데이트 + 프로젝트 초기화"
Write-Host "  /start — 세션 시작 시 맥락 복원"
Write-Host "  /end   — 세션 종료 전 저장"
Write-Host ""
