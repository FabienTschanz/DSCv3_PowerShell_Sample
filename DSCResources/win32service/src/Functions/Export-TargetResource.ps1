function Export-TargetResource {
    [CmdletBinding()]
    [OutputType([System.String])]
    param ()

    Write-Log -Message "Retrieving information for all services" -Level "Debug" -Target "Export-TargetResource"

    try {
        $convertedServices = @{
            Services = @()
        }
        $services = Get-CimInstance -ClassName Win32_Service -ErrorAction Stop
        foreach ($service in $services) {
            $convertedServices.Services += @{
                Name        = $service.Name
                DisplayName = $service.DisplayName
                Path        = $service.PathName
                Status      = $service.State.ToString()
                StartType   = $service.StartMode.ToString()
            }
        }

        Write-Log -Message "Successfully retrieved all services" -Level "Debug" -Target "Export-TargetResource"
        $convertedServices | ConvertTo-Json -Compress
    } catch {
        Write-Log -Message "Error retrieving services: $_" -Level "Error" -Target "Export-TargetResource"
        [System.Environment]::Exit(3)
    }
}