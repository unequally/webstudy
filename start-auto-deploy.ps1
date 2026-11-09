$scriptPath = Join-Path $PSScriptRoot 'scripts\watch-and-push.ps1'
Start-Process -FilePath 'powershell.exe' -WindowStyle Hidden -ArgumentList @(
  '-NoProfile',
  '-ExecutionPolicy', 'Bypass',
  '-File', $scriptPath
)
Write-Host 'Auto deploy watcher started in the background.'
