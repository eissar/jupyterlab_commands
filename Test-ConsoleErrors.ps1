[CmdletBinding()]
param()

$output = Test-HtmlBrowser  -Url http://localhost:8888/lab


remove-item *jlq_test.json

$t = Get-Date -Format FileDateTime
$output | Select-Object -ExpandProperty ConsoleEntries | ConvertTo-Json -Depth 7 | Out-File -FilePath "$t-jlq_test.json"
Write-Host "=== Console Entries ===" -ForegroundColor Blue
$output | Select-Object -ExpandProperty ConsoleEntries | Where-Object { $_.Text -Match 'commands|\[jlq\]' }
