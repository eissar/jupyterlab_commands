param($Port = 8888)

$process = Start-Process -FilePath "micromamba.exe" `
    -ArgumentList "run", "-n", "jl", "jupyter", "server", "--NotebookApp.ip='localhost'", "--NotebookApp.token=''", "--NotebookApp.password=''", "--NotebookApp.port=$Port" `
    -NoNewWindow -PassThru

$timeout = 120
$startTime = Get-Date
$serverAvailable = $false

Write-Host "Waiting for Jupyter server to start (timeout: ${timeout}s)..."

while (((Get-Date) - $startTime).TotalSeconds -lt $timeout) {
    $elapsed = [math]::Round(((Get-Date) - $startTime).TotalSeconds)
    $percentComplete = ($elapsed / $timeout) * 100

    Write-Progress -Activity "Starting Jupyter Server" -Status "Polling server... (${elapsed}s elapsed)" -PercentComplete $percentComplete -SecondsRemaining ($timeout - $elapsed)

    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$Port" -Method Get -TimeoutSec 1 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            $serverAvailable = $true
            break
        }
    }
    catch {}
    Start-Sleep -Seconds 1
}

Write-Progress -Activity "Starting Jupyter Server on port $Port" -Completed

if (-not $serverAvailable) {
    $process | Stop-Process -Force -ErrorAction SilentlyContinue
    throw "Jupyter server unavailable after $timeout seconds"
}

# Add success logging with timestamp
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Host "[$timestamp] Jupyter server is running on http://localhost:$Port" -ForegroundColor Green
Write-Host "Jupyter server process ID: $($process.Id)"
