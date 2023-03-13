BeforeAll {
    . $PSScriptRoot/../src/rev_function.ps1
}

Describe "rev" {
    Context "when value from pipeline received" {
        It "reverse strings" {
            [string] $stdin  = 'aiueo'
            [string] $stdout = 'oeuia'
            $stdin | rev | Should -Be $stdout
        }
    }
}

