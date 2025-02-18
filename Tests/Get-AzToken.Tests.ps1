param(
    [Parameter()]
    [ValidateScript({ $_ -match '\.psd1$' }, ErrorMessage = 'Please input a .psd1 file')]
    $Manifest
)

BeforeDiscovery {
    . "$PSScriptRoot\CommonTestLogic.ps1"
    Invoke-ModuleReload -Manifest $Manifest
    
    $ParameterTestCases += @(
        @{
            Name          = 'Resource'
            Type          = 'string'
            ParameterSets = @(
                @{ Name = 'NonInteractive'; Mandatory = $false }
                @{ Name = 'Interactive'; Mandatory = $false }
                @{ Name = 'ManagedIdentity'; Mandatory = $false }
            )
        }
        @{
            Name          = 'Scope'
            Type          = 'string[]'
            ParameterSets = @(
                @{ Name = 'NonInteractive'; Mandatory = $false }
                @{ Name = 'Interactive'; Mandatory = $false }
                @{ Name = 'ManagedIdentity'; Mandatory = $false }
            )
        }
        @{
            Name          = 'TenantId'
            Type          = 'string'
            ParameterSets = @(
                @{ Name = 'NonInteractive'; Mandatory = $false }
                @{ Name = 'Interactive'; Mandatory = $false }
                @{ Name = 'ManagedIdentity'; Mandatory = $false }
            )
        }
        @{
            Name          = 'Claim'
            Type          = 'string'
            ParameterSets = @(
                @{ Name = 'NonInteractive'; Mandatory = $false }
                @{ Name = 'Interactive'; Mandatory = $false }
                @{ Name = 'ManagedIdentity'; Mandatory = $false }
            )
        }
        @{
            Name          = 'ClientId'
            Type          = 'string'
            ParameterSets = @(
                @{ Name = 'Interactive'; Mandatory = $false }
                @{ Name = 'ManagedIdentity'; Mandatory = $false }
            )
        }
        @{
            Name          = 'Interactive'
            Type          = 'System.Management.Automation.SwitchParameter'
            ParameterSets = @(
                @{ Name = 'Interactive'; Mandatory = $true }
            )
        }
        @{
            Name          = 'ManagedIdentity'
            Type          = 'System.Management.Automation.SwitchParameter'
            ParameterSets = @(
                @{ Name = 'ManagedIdentity'; Mandatory = $true }
            )
        }
    )
}

Describe 'Get-AzToken' {
    BeforeAll {        
        # Get command from current test file name
        $Command = Get-Command ((Split-Path $PSCommandPath -Leaf) -replace '.Tests.ps1')
    }

    Context 'parameters' {
        It 'only has expected parameters' -TestCases @{ Parameters = $ParameterTestCases.Name } {
            $Command.Parameters.GetEnumerator() | Where-Object {
                $_.Key -notin [System.Management.Automation.Cmdlet]::CommonParameters -and
                $_.Key -notin $Parameters
            } | Should -BeNullOrEmpty
        }

        It 'has parameter <Name> of type <Type>' -TestCases $ParameterTestCases {
            $Command | Should -HaveParameter $Name -Type $Type
        }

        It 'has correct parameter sets for parameter <Name>' -TestCases $ParameterTestCases {
            $Parameter = $Command.Parameters[$Name]
            $Parameter.ParameterSets.Keys | Should -BeExactly $ParameterSets.Name
        }

        foreach ($ParameterTestCase in $ParameterTestCases) {
            foreach ($ParameterSet in $ParameterTestCase.ParameterSets) {
                It 'has parameter <ParameterName> set to mandatory <Mandatory> for parameter set <Name>' -TestCases @{
                    ParameterName = $ParameterTestCase['Name']
                    Name          = $ParameterSet['Name']
                    Mandatory     = $ParameterSet['Mandatory']
                } {
                    $Parameter = $Command.Parameters[$ParameterName]
                    $Parameter.ParameterSets[$Name].IsMandatory | Should -Be $Mandatory
                }
            }
        }
    }
}