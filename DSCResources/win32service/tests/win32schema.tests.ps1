Describe 'win32service.schema' {
    BeforeAll {
        $schema = win32service schema | ConvertFrom-Json -ErrorAction Stop
    }

    It 'Should have the correct schema version' {
        $schema.'$schema' | Should -Be 'http://json-schema.org/draft-07/schema#'
    }

    It 'Should have the correct title' {
        $schema.title | Should -Be 'win32service'
    }

    It 'Should be of type object' {
        $schema.type | Should -Be 'object'
    }

    It 'Should require name property' {
        $schema.required | Should -Contain 'name'
    }

    Context 'Properties' {
        It 'Should have _exist property of correct type' {
            $schema.properties._exist.type | Should -Be @('boolean', 'null')
            $schema.properties._exist.description | Should -Not -BeNullOrEmpty
        }

        It 'Should have name property of type string' {
            $schema.properties.name.type | Should -Be 'string'
            $schema.properties.name.description | Should -Not -BeNullOrEmpty
        }

        It 'Should have path property of type string' {
            $schema.properties.path.type | Should -Be 'string'
            $schema.properties.path.description | Should -Not -BeNullOrEmpty
        }

        It 'Should have StartType property with valid enum values' {
            $schema.properties.StartType.type | Should -Be 'string'
            $schema.properties.StartType.enum | Should -Contain 'Automatic'
            $schema.properties.StartType.enum | Should -Contain 'Manual'
            $schema.properties.StartType.enum | Should -Contain 'Disabled'
            $schema.properties.StartType.description | Should -Not -BeNullOrEmpty
        }

        It 'Should have displayName property of correct type' {
            $schema.properties.displayName.type | Should -Be @('string', 'null')
            $schema.properties.displayName.description | Should -Not -BeNullOrEmpty
        }
    }
}