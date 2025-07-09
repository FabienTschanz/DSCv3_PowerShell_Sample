function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [hashtable]$PlaceHolder,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Debug', 'Trace', 'Information', 'Warning', 'Error')]
        [string]$Level = 'Information',

        [Parameter(Mandatory = $false)]
        [string]$Target
    )

    foreach ($key in $PlaceHolder.Keys) {
        $Message = $Message.Replace("{{$key}}", $PlaceHolder[$key])
    }

    # time in iso format z
    $timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    $lineNumber = (Get-PSCallStack)[0].ScriptLineNumber
    $record = @{
        Timestamp  = $timestamp
        Level      = $Level
        Fields     = @{
            Message = $Message
        }
        Target     = $Target
        LineNumber = $lineNumber
    } | ConvertTo-Json -Depth 5 -Compress

    [System.Console]::Error.WriteLine($record)
}