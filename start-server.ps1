param($Port = 8888)

$job = Start-Job -Name "JupyterServer_$Port" -ScriptBlock {
    micromamba.exe run -n jl jupyter server --NotebookApp.ip='localhost' --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.port=8888
}

$timeout = 120
$startTime = Get-Date
$serverAvailable = $false

Write-Host "Waiting for Jupyter server to start (timeout: ${timeout}s)..."

while (((Get-Date) - $startTime).TotalSeconds -lt $timeout) {
    $elapsed = [math]::Round(((Get-Date) - $startTime).TotalSeconds)
    $percentComplete = ($elapsed / $timeout) * 100

    Write-Progress -Activity "Starting Jupyter Server" -Status "Polling server... (${elapsed}s elapsed)" -PercentComplete $percentComplete -SecondsRemaining ($timeout - $elapsed)

    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8888" -Method Get -TimeoutSec 1 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            $serverAvailable = $true
            break
        }
    }
    catch {
        # Server not ready yet, continue polling
    }

    Start-Sleep -Seconds 1
}

Write-Progress -Activity "Starting Jupyter Server on port $Port" -Completed

if (-not $serverAvailable) {
    Stop-Job $job -ErrorAction SilentlyContinue
    Remove-Job $job -ErrorAction SilentlyContinue
    throw "Jupyter server unavailable after $timeout seconds"
}

Write-Host "Jupyter server is running on http://localhost:$Port"
# Add logging for job status
Write-Host "Started Jupyter server job with ID: $($job.Id)"

# Add success logging with timestamp
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Host "[$timestamp] Jupyter server is running on http://localhost:$Port" -ForegroundColor Green
