param(
  [int]$DebounceSeconds = 5
)

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$ignoredPattern = '\\(?:\.git|node_modules|dist)(?:\\|$)'
$pending = $false
$lastChange = Get-Date

function Mark-Changed {
  param([string]$Path)
  if ($Path -notmatch $ignoredPattern) {
    $script:pending = $true
    $script:lastChange = Get-Date
  }
}

function Sync-Repository {
  $changes = git -C $repo status --porcelain
  if (-not $changes) { return }

  git -C $repo add -A
  $message = "auto: sync $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
  git -C $repo commit -m $message
  git -C $repo push
  Write-Host "[$(Get-Date -Format 'HH:mm:ss')] pushed changes to GitHub."
}

$watcher = [System.IO.FileSystemWatcher]::new($repo)
$watcher.IncludeSubdirectories = $true
$watcher.NotifyFilter = [System.IO.NotifyFilters]::FileName -bor [System.IO.NotifyFilters]::LastWrite -bor [System.IO.NotifyFilters]::DirectoryName
$watcher.EnableRaisingEvents = $true

$registrations = @(
  Register-ObjectEvent -InputObject $watcher -EventName Changed -Action { Mark-Changed $Event.SourceEventArgs.FullPath }
  Register-ObjectEvent -InputObject $watcher -EventName Created -Action { Mark-Changed $Event.SourceEventArgs.FullPath }
  Register-ObjectEvent -InputObject $watcher -EventName Deleted -Action { Mark-Changed $Event.SourceEventArgs.FullPath }
  Register-ObjectEvent -InputObject $watcher -EventName Renamed -Action { Mark-Changed $Event.SourceEventArgs.FullPath }
)

Write-Host "Watching $repo"
Write-Host "Changes are pushed after $DebounceSeconds seconds without another file event. Press Ctrl+C to stop."

try {
  while ($true) {
    Start-Sleep -Seconds 2
    if ($pending -and ((Get-Date) - $lastChange).TotalSeconds -ge $DebounceSeconds) {
      $pending = $false
      try { Sync-Repository } catch { Write-Warning "Automatic push failed: $($_.Exception.Message)" }
    }
  }
} finally {
  $registrations | ForEach-Object { Unregister-Event -SubscriptionId $_.Id -ErrorAction SilentlyContinue }
  $watcher.Dispose()
}
