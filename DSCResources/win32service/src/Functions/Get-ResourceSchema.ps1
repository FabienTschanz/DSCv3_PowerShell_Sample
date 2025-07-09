function Get-ResourceSchema {
    [CmdletBinding()]
    [OutputType([System.String])]
    param ()

    $schema = [ordered]@{
        '$schema' = 'http://json-schema.org/draft-07/schema#'
        title = 'win32service'
        type = 'object'
        required = @('Name')
        properties = @{
            '_exist' = @{
                type = @('boolean', 'null')
                description = 'Indicates whether the service exists.'
            }
            Name = @{
                type = 'string'
                description = 'The name of the service.'
            }
            DisplayName = @{
                type = @('string', 'null')
                description = 'The display name of the service.'
            }
            Path = @{
                type = 'string'
                description = 'The path to the service executable.'
            }
            StartType = @{
                type = 'string'
                enum = @('Automatic', 'Manual', 'Disabled')
                description = 'The startup type of the service.'
            }
            Status = @{
                type = 'string'
                enum = @('Running', 'Stopped', 'Paused')
                description = 'The current status of the service.'
            }
        }
        additionalProperties = $false
    }

    return $schema | ConvertTo-Json -Depth 5 -Compress
}