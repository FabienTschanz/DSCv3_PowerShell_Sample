function Test-JsonData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $JsonString,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $RequiredProperties
    )

    try {
        if ($PSVersionTable.PSEdition -eq 'Core') {
            # For PowerShell Core, use ConvertFrom-Json with -AsHashtable
            $jsonData = $JsonString | ConvertFrom-Json -AsHashtable
        } else {
            # For Windows PowerShell, use ConvertFrom-Json without -AsHashtable and convert manually
            $jsonData = $JsonString | ConvertFrom-Json | ConvertTo-Hashtable
        }

        foreach ($property in $RequiredProperties) {
            if (-not $jsonData.ContainsKey($property)) {
                Write-Log -Message "Missing required property: $property" -Level 'Error' -Target "Test-JsonData"
                [System.Environment]::Exit(2)
            }
        }
        return $jsonData
    } catch {
        Write-Log -Message "Invalid JSON data: $_" -Level 'Error' -Target "Test-JsonData"
        [System.Environment]::Exit(4)
    }
}