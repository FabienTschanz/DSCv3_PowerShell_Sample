<#
.SYNOPSIS
    Retrieves the status of a Windows service by its name.

.DESCRIPTION
    This function retrieves the status of a Windows service specified by its name.
    It checks if the service exists and returns its status, or an error if the service is not found.

.PARAMETER Name
    The name of the Windows service to retrieve the status for. This parameter is mandatory.

.EXAMPLE
    Get-Service -Name "wuauserv"

    Retrieves the status of the Windows Update service.

.OUTPUTS
    System.String
    Returns a JSON string containing the service's name, display name, status, and startup type
#>
function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    Write-Log -Message "Retrieving status for service: $Name" -Level 'Information' -Target "Get-TargetResource"
    try {
        $service = Get-CimInstance -ClassName Win32_Service -Filter "Name = '$Name'" -ErrorAction SilentlyContinue
    } catch {
        Write-Log -Message "Error retrieving service '$Name': $_" -Level 'Error' -Target "Get-TargetResource"
        [System.Environment]::Exit(3)
    }

    if ($null -ne $service) {
        @{
            Name        = $Name
            DisplayName = $service.DisplayName
            Path        = $service.PathName
            Status      = $service.State.ToString()
            StartType   = $service.StartMode.ToString()
        } | ConvertTo-Json -Compress
    } else {
        Write-Log -Message $Global:LocalizedData["ServiceNotFound"] -PlaceHolder @{serviceName = $Name} -Level 'Error' -Target "Get-TargetResource"
        @{
            Name = $Name
            _exist = $false
        } | ConvertTo-Json -Compress
    }
}