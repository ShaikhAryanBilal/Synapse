# Synapse — Skill Installer (Windows / PowerShell)
# Skills live in ONE place: ./skills. This script points agents at that
# directory from OUTSIDE the repo — nothing is added to the repo itself.
#
#   Global  : link/copy the skills into your agent's global skills directory.
#   Project : link/copy the skills into a project's agent directories
#             (e.g. <project>\.agents\skills and <project>\.claude\skills).
#
# Usage:
#   .\scripts\install.ps1 -OpenCode                       # global, OpenCode (+Codex/Gemini via ~/.agents/skills)
#   .\scripts\install.ps1 -ClaudeCode                     # global, Claude Code
#   .\scripts\install.ps1 -AllAgents                      # global, all agents
#   .\scripts\install.ps1 -AllAgents -Copy                # copy instead of link
#   .\scripts\install.ps1 -ProjectDir "..\MyProject"      # point that project's agents at ./skills

param(
    [switch]$OpenCode,
    [switch]$ClaudeCode,
    [switch]$Codex,
    [switch]$Gemini,
    [switch]$AllAgents,
    [switch]$Copy,
    [string]$ProjectDir,
    [string]$SourceDir = (Split-Path -Parent $PSScriptRoot)
)

$skillsDir = Join-Path $SourceDir "skills"
if (-not (Test-Path -LiteralPath $skillsDir)) {
    Write-Error "Skills directory not found at $skillsDir"
    exit 1
}

# Ordered map of target path -> description (deduplicated by path)
$targets = [System.Collections.Specialized.OrderedDictionary]::new()

if ($ProjectDir) {
    if (-not (Test-Path -LiteralPath $ProjectDir)) {
        Write-Error "Project directory not found: $ProjectDir"
        exit 1
    }
    $targets[(Join-Path $ProjectDir ".agents\skills")] = "Project $ProjectDir - .agents/skills (OpenCode, Codex, Gemini)"
    $targets[(Join-Path $ProjectDir ".claude\skills")] = "Project $ProjectDir - .claude/skills (Claude Code)"
}
else {
    if ($OpenCode -or $AllAgents) {
        $targets["$env:USERPROFILE\.agents\skills"] = "OpenCode (global ~/.agents/skills)"
    }
    if ($ClaudeCode -or $AllAgents) {
        $targets["$env:USERPROFILE\.claude\skills"] = "Claude Code (global ~/.claude/skills)"
    }
    if ($Codex -or $AllAgents) {
        $targets["$env:USERPROFILE\.agents\skills"] = "Codex CLI (global ~/.agents/skills)"
    }
    if ($Gemini -or $AllAgents) {
        $targets["$env:USERPROFILE\.agents\skills"] = "Gemini CLI (global ~/.agents/skills)"
    }
}

if ($targets.Count -eq 0) {
    Write-Host "Usage: .\scripts\install.ps1 [-OpenCode] [-ClaudeCode] [-Codex] [-Gemini] [-AllAgents] [-Copy] [-ProjectDir <path>]"
    Write-Host "  -OpenCode      Point OpenCode's global skills dir at ./skills"
    Write-Host "  -ClaudeCode    Point Claude Code's global skills dir at ./skills"
    Write-Host "  -Codex         Point Codex CLI's global skills dir at ./skills"
    Write-Host "  -Gemini        Point Gemini CLI's global skills dir at ./skills"
    Write-Host "  -AllAgents     All of the above"
    Write-Host "  -Copy          Copy skills instead of linking (self-contained install)"
    Write-Host "  -ProjectDir    Point a specific project's agent dirs at ./skills (ignores the agent flags)"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\scripts\install.ps1 -AllAgents"
    Write-Host "  .\scripts\install.ps1 -AllAgents -Copy"
    Write-Host "  .\scripts\install.ps1 -ProjectDir ..\MyProject"
    exit 0
}

foreach ($entry in $targets.GetEnumerator()) {
    $targetPath = $entry.Key
    $label = $entry.Value
    Write-Host "Installing for $label ... " -NoNewline

    if ($Copy) {
        if (-not (Test-Path -LiteralPath $targetPath)) {
            New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
        }
        Get-ChildItem -Path $skillsDir -Directory | ForEach-Object {
            $dest = Join-Path $targetPath $_.Name
            if (Test-Path -LiteralPath $dest) {
                Remove-Item -LiteralPath $dest -Recurse -Force
            }
            Copy-Item -Path $_.FullName -Destination $dest -Recurse -Force
        }
        Write-Host "OK - copied $(@(Get-ChildItem -Path $skillsDir -Directory).Count) skills"
        continue
    }

    # Link mode
    if (Test-Path -LiteralPath $targetPath) {
        $item = Get-Item -LiteralPath $targetPath -Force
        if ($item.LinkType) {
            if ($item.Target -eq $skillsDir) {
                Write-Host "already linked. Skipped."
                continue
            }
            $item.Delete()
            Write-Host "replacing stale link ..."
        }
        else {
            Write-Host ""
            Write-Host "  WARNING: $targetPath already exists and is not a link." -ForegroundColor Yellow
            Write-Host "  It may contain your own skills. Use -Copy to merge, or back it up first." -ForegroundColor Yellow
            Write-Host "  Skipped." -ForegroundColor Yellow
            continue
        }
    }
    else {
        New-Item -ItemType Directory -Path (Split-Path -Parent $targetPath) -Force | Out-Null
    }

    New-Item -ItemType Junction -Path $targetPath -Target $skillsDir | Out-Null
    Write-Host "linked -> $skillsDir"
}

Write-Host ""
Write-Host "Done. Skills are served from the single source: $skillsDir"
if ($Copy) {
    Write-Host "A copy was placed in each target directory (independent of the repo)."
}
else {
    Write-Host "Links stay in sync with the repo but break if the repo is moved or deleted."
}
Write-Host "Restart your agent to discover the skills."
