function Remove-TargetResource {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    # Check if the service exists
    $service = Get-Service -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $service) {
        Write-Log -Message "Service '$Name' does not exist. No action taken." -Level 'Information' -Target "Remove-TargetResource"
        return
    }

    # Stop the service if it is running
    if ($service.Status -eq 'Running') {
        Write-Log -Message "Stopping service '$Name' before removal." -Level 'Debug' -Target "Remove-TargetResource"
        Stop-Service -Name $Name -Force
    }

    # Remove the service
    Write-Log -Message "Removing service '$Name'." -Level 'Information' -Target "Remove-TargetResource"
    Remove-Service -Name $Name -ErrorAction Stop
}