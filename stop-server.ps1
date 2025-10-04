param($Port)

Write-Host "[LOG] Cleaning up processes and jobs for port $Port..."

# Clean up PowerShell jobs that might be running the server
$jobs = Get-Job | Where-Object { $_.Name -like "JupyterServer_*" }
if ($jobs) {
    foreach ($job in $jobs) {
        try {
            Stop-Job $job -ErrorAction Stop
            Remove-Job $job -ErrorAction Stop
            Write-Host "Removed job: $($job.Name)"
        } catch {
            Write-Warning "Failed to remove job $($job.Name): $_"
        }
    }
}

$processes = Get-NetTCPConnection | Where-Object { $_.LocalPort -eq $Port } | Select-Object -ExpandProperty OwningProcess -Unique

if ($processes) {
    foreach ($_pid in $processes) {
        try {
            Stop-Process -Id $_pid -Force -ErrorAction Stop
            Write-Host "Stopped process $_pid"
        } catch {
            Write-Warning "Failed to stop process $_"
        }
    }
} else {
    Write-Host "No processes found on port $Port"
}
