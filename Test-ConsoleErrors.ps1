<#
.SYNOPSIS
    Test mindmap viewer HTML file for console errors in headless browser

.DESCRIPTION
    This script loads a mindmap viewer HTML file in a headless browser and returns any console errors found during page load.

.PARAMETER FilePath
    The path to the HTML file to test

.EXAMPLE
    Test-MindmapViewer -FilePath "C:\mindmap.html"

.OUTPUTS
    Returns any console errors found during page load
#>

[CmdletBinding()]
param()

# Get-ChildItem mindmap-viewer-direct.html |
#     Select-Object -ExpandProperty FullName |
#     ForEach-Object {
#         Test-HtmlBrowser -Headless -Path $_
#     } |
#     Select-Object -ExpandProperty ConsoleErrors
#
Test-HtmlBrowser -Headless -Url http://localhost:8888/lab | Select-Object -ExpandProperty ConsoleErrors
