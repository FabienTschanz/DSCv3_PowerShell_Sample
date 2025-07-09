function ConvertTo-Hashtable {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [PSCustomObject]
        $JsonObject
    )

    process {
        if (-not $JsonObject) {
            Write-Log -Message "No JSON object provided." -Level 'Error' -Target "ConvertTo-Hashtable"
            return @{}
        }

        $hashtable = @{}
        foreach ($property in $JsonObject.PSObject.Properties) {
            $hashtable[$property.Name] = $property.Value
        }

        Write-Log -Message "Converted JSON object to hashtable: $($hashtable | ConvertTo-Json -Depth 5)" -Level 'Debug' -Target "ConvertTo-Hashtable"
        return $hashtable
    }
}