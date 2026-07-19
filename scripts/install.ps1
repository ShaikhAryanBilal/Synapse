# Synapse — Multi-Agent Skill Installer (Windows / PowerShell)
# Installs skills for OpenCode, Claude Code, and compatible agents

param(
    [switch]$OpenCode,
    [switch]$ClaudeCode,
    [switch]$AllAgents,
    [switch]$ProjectLocal,
    [string]$SourceDir = (Split-Path -Parent $PSScriptRoot)
)

$skillsDir = Join-Path $SourceDir "skills"
if (-not (Test-Path $skillsDir)) {
    Write-Error "Skills directory not found at $skillsDir"
    exit 1
}

$installTargets = @()

if ($OpenCode -or $AllAgents) {
    $installTargets += @{
        Name = "OpenCode (global)"
        Path = "$env:USERPROFILE\.config\opencode\skills"
    }
    $installTargets += @{
        Name = "OpenCode (agents global)"
        Path = "$env:USERPROFILE\.agents\skills"
    }
}

if ($ClaudeCode -or $AllAgents) {
    $installTargets += @{
        Name = "Claude Code (global)"
        Path = "$env:USERPROFILE\.claude\skills"
    }
}

if ($ProjectLocal) {
    $installTargets += @{
        Name = "Project-local (.opencode)"
        Path = (Join-Path $SourceDir ".opencode\skills")
    }
    $installTargets += @{
        Name = "Project-local (.claude)"
        Path = (Join-Path $SourceDir ".claude\skills")
    }
    $installTargets += @{
        Name = "Project-local (.agents)"
        Path = (Join-Path $SourceDir ".agents\skills")
    }
}

if ($installTargets.Count -eq 0) {
    Write-Host "Usage: .\scripts\install.ps1 [-OpenCode] [-ClaudeCode] [-AllAgents] [-ProjectLocal]"
    Write-Host "  -OpenCode      Install to OpenCode global skill directories"
    Write-Host "  -ClaudeCode    Install to Claude Code global skill directories"
    Write-Host "  -AllAgents     Install to all global agent directories"
    Write-Host "  -ProjectLocal  Install project-local copies"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\scripts\install.ps1 -AllAgents"
    Write-Host "  .\scripts\install.ps1 -OpenCode -ProjectLocal"
    exit 0
}

foreach ($target in $installTargets) {
    $targetPath = $target.Path
    Write-Host "Installing to $($target.Name)... " -NoNewline

    if (-not (Test-Path $targetPath)) {
        New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
    }

    # Copy each skill directory
    Get-ChildItem -Path $skillsDir -Directory | ForEach-Object {
        $skillName = $_.Name
        $dest = Join-Path $targetPath $skillName

        if (Test-Path $dest) {
            Remove-Item -Path $dest -Recurse -Force
        }

        Copy-Item -Path $_.FullName -Destination $dest -Recurse -Force
    }

    Write-Host "OK ($(@(Get-ChildItem -Path $skillsDir -Directory).Count) skills)"
}

Write-Host ""
Write-Host "Synapse skills installed. Restart your agent to discover them."
