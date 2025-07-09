param (
    [Parameter(
        Mandatory = $true,
        ValueFromRemainingArguments = $true,
        Position = 0
    )]
    [System.String[]]
    $ListOfArguments
)

New-Variable -Name "LocalizedData" -Scope Global -Force

$global:ScriptFilePath = [Environment]::GetCommandLineArgs()[0]
$global:ScriptPath = Split-Path -Path $global:ScriptFilePath -Parent

Import-LocalizedData -BindingVariable 'LocalizedData' -BaseDirectory $global:ScriptPath -FileName 'main.psd1' -ErrorAction Stop

Confirm-Input -ListOfArguments $ListOfArguments
$jsonPosition = $ListOfArguments.IndexOf('-input') + 1

if ($ListOfArguments[0] -eq 'config') {
    switch ($ListOfArguments[1]) {
        'get' {
            $inputObject = Test-JsonData -JsonString $ListOfArguments[$jsonPosition] -RequiredProperties @('Name')
            Write-Log -Message "Retrieving service configuration for: $($inputObject.Name)" -Level 'Information' -Target "win32Service"
            Get-TargetResource -Name $inputObject.Name
            break
        }
        'set' {
            $whatIf = $false
            if ($ListOfArguments -contains '-what-if' -or $ListOfArguments -contains 'w') {
                Write-Log -Message "WhatIf mode is enabled. No changes will be made." -Level 'Information' -Target "win32Service"
                $whatIf = $true
            }
            $inputObject = Test-JsonData -JsonString $ListOfArguments[$jsonPosition] -RequiredProperties @('Name', 'Path')
            Write-Log -Message "Setting service configuration for: $($inputObject.Name)" -Level 'Information' -Target "win32Service"
            Set-TargetResource @inputObject -WhatIf:$whatIf
            break
        }
        'test' {
            $inputObject = Test-JsonData -JsonString $ListOfArguments[$jsonPosition] -RequiredProperties @('Name')
            Write-Log -Message "Testing service configuration for: $($inputObject.Name)" -Level 'Information' -Target "win32Service"
            Test-TargetResource @inputObject
            break
        }
        'delete' {
            $inputObject = Test-JsonData -JsonString $ListOfArguments[$jsonPosition] -RequiredProperties @('Name')
            Write-Log -Message "Remove service: $($inputObject.Name)" -Level 'Information' -Target "win32Service"
            Remove-TargetResource -Name $inputObject.Name
            break
        }
        'export' {
            Write-Log -Message "Exporting service configuration." -Level 'Information' -Target "win32Service"
            Export-TargetResource
            break
        }
        default {
            Write-Log -Message "Invalid action specified. Allowed values are 'get', 'set', 'test', 'remove' or 'export'." -Level 'Error' -Target "win32Service"
            [System.Environment]::Exit(1)
        }
    }
} elseif ($ListOfArguments[0] -eq 'schema') {
    Write-Log -Message "Retrieving schema for win32service resource." -Level 'Information' -Target "win32Service"
    Get-ResourceSchema
} else {
    Write-Log -Message "Invalid type specified. Allowed values are 'config' or 'schema'." -Level 'Error' -Target "win32Service"
    [System.Environment]::Exit(1)
}