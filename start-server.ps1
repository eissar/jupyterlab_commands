$job = Start-Job -ScriptBlock {
    Start-Process wt -ArgumentList "wsl", "micromamba.exe", "run", "-n", "jl", "jupyter", "server", "--NotebookApp.ip='localhost'", "--NotebookApp.token=''", "--NotebookApp.password=''", "--NotebookApp.port=8888"
}

$timeout = 120
$startTime = Get-Date
$serverAvailable = $false

Write-Host "Waiting for Jupyter server to start (timeout: ${timeout}s)..."

while (((Get-Date) - $startTime).TotalSeconds -lt $timeout) {
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

if (-not $serverAvailable) {
    Stop-Job $job -ErrorAction SilentlyContinue
    Remove-Job $job -ErrorAction SilentlyContinue
    throw "Jupyter server unavailable after $timeout seconds"
}

Write-Host "Jupyter server is running on http://localhost:8888"
