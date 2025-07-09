function Set-TargetResource {
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [string]$DisplayName,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Automatic', 'Manual', 'Disabled')]
        [string]$StartType,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Running', 'Stopped', 'Paused')]
        [string]$State,

        [switch]$WhatIf
    )

    if ($WhatIf) {
        return Invoke-WhatIfSet -Name $Name -Configuration $PSBoundParameters
    }

    $service = Get-TargetResource -Name $Name -ErrorAction SilentlyContinue
    if (-not $service) {
        Write-Log -Message "Service '$Name' does not exist. Creating new service." -Level 'Information' -Target "Set-TargetResource"

        $createParameters = @{
            Name           = $Name
            DisplayName    = $DisplayName
            BinaryPathName = $Path
            StartType      = $StartType
        }
        New-Service @createParameters -ErrorAction Stop
        return
    }

    $setParameters = @{}
    if ($DisplayName) {
        $setParameters['DisplayName'] = $DisplayName
    }
    if ($StartType) {
        $setParameters['StartupType'] = $StartType
    }

    Write-Log -Message "Updating service parameters for '$Name'" -Level 'Information' -Target "Set-TargetResource"
    Write-Log -Message "Setting service parameters for '$Name': $($setParameters | ConvertTo-Json -Depth 5)" -Level 'Debug' -Target "Set-TargetResource"
    Set-Service @setParameters -Name $Name -ErrorAction Stop

    Write-Log -Message "Checking service state for '$Name': $State" -Level 'Debug' -Target "Set-TargetResource"
    if ($State) {
        switch ($State) {
            'Running' { Start-Service -Name $Name -ErrorAction Stop }
            'Stopped' { Stop-Service -Name $Name -ErrorAction Stop }
            'Paused' { Suspend-Service -Name $Name -ErrorAction Stop }
        }
    }
}