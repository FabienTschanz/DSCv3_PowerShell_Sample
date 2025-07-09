function Confirm-Input {
    param (
        [Parameter(Mandatory = $true)]
        [System.String[]]
        $ListOfArguments
    )

    Write-Log -Message "Confirming input arguments: $($ListOfArguments -join ', ')" -Level 'Debug' -Target "Confirm-Input"

    if ($ListOfArguments[0] -notin @('config', 'schema')) {
        Write-Log -Message "Invalid type specified. Allowed values are 'config' or 'schema'." -Level 'Error' -Target "Confirm-Input"
        [System.Environment]::Exit(1)
    }

    if ($ListOfArguments[0] -eq 'config') {
        if ($ListOfArguments[1] -notin @('get', 'set', 'test', 'delete', 'export')) {
            Write-Log -Message "Invalid action specified. Allowed values are 'get', 'set', 'test', 'remove' or 'export'." -Level 'Error' -Target "Confirm-Input"
            [System.Environment]::Exit(1)
        }

        if ($ListOfArguments[1] -in @('get', 'set', 'test', 'delete')) {
            if ($ListOfArguments.Count -lt 4) {
                Write-Log -Message "Insufficient arguments provided. Please specify at least 'config <action> --input <json>' with a valid input." -Level 'Error' -Target "Confirm-Input"
                [System.Environment]::Exit(1)
            }

            if ($ListOfArguments -notcontains '--input' -and $ListOfArguments -notcontains '-input') {
                Write-Log -Message "Required argument '--input' was not provided." -Level 'Error' -Target "Confirm-Input"
                [System.Environment]::Exit(1)
            }
        }
    }
}