function Invoke-WhatIfSet {
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]$Name,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$Configuration
    )

    Write-Log -Message "Invoking WhatIf for setting service '$Name'." -Level 'Information' -Target "Invoke-WhatIfSet"

    $Configuration.Remove('WhatIf') | Out-Null
    $configString = $Configuration | ConvertTo-Json -Depth 1 -Compress
    $configString = $configString -replace '"', '\"'  # Escape quotes for command line
    $configString = $configString -replace '\\', '\'
    Write-Log -Message "Configuration for service '$Name': $configString" -Level 'Debug' -Target "Invoke-WhatIfSet"
    $process = Start-ProcessV2 -FilePath $Global:ScriptFilePath -ArgumentList "config get --input ""$configString""" -NoNewWindow -Wait
    if ($process.ExitCode -ne 0) {
        return @{
            name = $Name
            "_metadata" = @{
                "whatIf" = @(
                    "Error executing operation for service '$Name'. Exit code: $($process.ExitCode)"
                )
            }
        } | ConvertTo-Json -Compress
    }

    Write-Log -Message "WhatIf operation completed successfully for service '$Name'." -Level 'Debug' -Target "Invoke-WhatIfSet"

    [hashtable]$serviceInfo = $process.StandardOutput.ReadToEnd() | ConvertFrom-Json | ConvertTo-Hashtable
    if ($serviceInfo._exist -eq $false) {
        return @{
            name = $Name
            "_metadata" = @{
                "whatIf" = @(
                    "Service '$Name' does not exist, would create service."
                )
            }
        } | ConvertTo-Json -Compress
    }

    $currentValues = $serviceInfo.Clone()
    $currentValues.Remove('_exist') | Out-Null

    $desiredValues = $Configuration.Clone()
    $desiredValues.Remove('_exist') | Out-Null

    $keysToCheck = $Configuration.Keys
    [hashtable]$differences = Compare-Values -CurrentValues $currentValues -DesiredValues $desiredValues -KeysToCheck $keysToCheck
    if ($differences.Count -eq 0) {
        return $currentValues | ConvertTo-Json -Compress
    } else {
        $changes = @{}
        foreach ($item in $differences.GetEnumerator()) {
            $changes[$item.Key] = $item.Value.DesiredValue
        }
    }

    $result = @{
        Name = $Name
        Path = $serviceInfo.Path
    }
    if ($changes.Count -gt 0) {
        foreach ($key in $changes.Keys) {
            $result[$key] = $changes[$key]
        }
    }

    return $result | ConvertTo-Json -Compress
}