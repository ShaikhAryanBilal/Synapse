param(
    [string]$ProjectRoot = (Split-Path -Parent $PSScriptRoot)
)

$skillsDir = Join-Path $ProjectRoot "skills"

$platforms = @()
$platforms += @{ Path = Join-Path $ProjectRoot ".opencode\skills"; Label = ".opencode/skills" }
$platforms += @{ Path = Join-Path $ProjectRoot ".claude\skills";   Label = ".claude/skills" }
$platforms += @{ Path = Join-Path $ProjectRoot ".agents\skills";   Label = ".agents/skills" }

$skillDirs = Get-ChildItem -Path $skillsDir -Directory

foreach ($platform in $platforms) {
    $target = $platform.Path
    if (-not (Test-Path $target)) {
        New-Item -ItemType Directory -Path $target -Force | Out-Null
    }

    foreach ($skill in $skillDirs) {
        $dest = Join-Path $target $skill.Name
        if (Test-Path $dest) {
            Remove-Item -Path $dest -Recurse -Force
        }
        Copy-Item -Path $skill.FullName -Destination $dest -Recurse -Force
    }

    $msg = "Synced " + $platform.Label + " - " + $skillDirs.Count + " skills"
    Write-Host $msg
}

Write-Host "All platforms have identical skill sets."
