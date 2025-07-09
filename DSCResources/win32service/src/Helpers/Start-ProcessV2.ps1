function Start-ProcessV2 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $true)]
        [string[]]$ArgumentList,

        [Parameter()]
        [switch]$NoNewWindow,

        [Parameter()]
        [switch]$Wait
    )

    Write-Log -Message "Starting process: $FilePath with arguments: $($ArgumentList -join ' ')" -Level 'Debug' -Target "Start-ProcessV2"

    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = $FilePath
    $processInfo.RedirectStandardError = $true
    $processInfo.RedirectStandardOutput = $true
    $processInfo.UseShellExecute = $false
    $processInfo.Arguments = $ArgumentList -join ' '
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $processInfo
    $process.Start() | Out-Null
    $process.WaitForExit()

    return $process
}