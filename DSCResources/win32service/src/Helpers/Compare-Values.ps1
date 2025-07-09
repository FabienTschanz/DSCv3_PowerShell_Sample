function Compare-Values {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$CurrentValues,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$DesiredValues,

        [Parameter(Mandatory = $true)]
        [System.Array]$KeysToCheck
    )

    Write-Log -Message "Comparing current values with desired values." -Level 'Information' -Target "Compare-Values"
    $differences = @{}

    foreach ($key in $KeysToCheck) {
        if (-not $CurrentValues.ContainsKey($key)) {
            Write-Log -Message "Current value for '$key' does not exist." -Level 'Debug' -Target "Compare-Values"
            $differences[$key] = @{
                CurrentValue = $null
                DesiredValue = $DesiredValues[$key]
            }
        } elseif ($CurrentValues[$key] -ne $DesiredValues[$key]) {
            Write-Log -Message "Value for '$key' differs: Current='$($CurrentValues[$key])', Desired='$($DesiredValues[$key])'" -Level 'Debug' -Target "Compare-Values"
            $differences[$key] = @{
                CurrentValue = $CurrentValues[$key]
                DesiredValue = $DesiredValues[$key]
            }
        }
    }

    if ($differences.Count -eq 0) {
        Write-Log -Message "No differences found between current and desired values." -Level 'Debug' -Target "Compare-Values"
    } else {
        Write-Log -Message "Differences found: $($differences | ConvertTo-Json -Depth 5 -Compress)" -Level 'Debug' -Target "Compare-Values"
    }

    $differences
}