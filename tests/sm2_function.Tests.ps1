BeforeAll {
    . $PSScriptRoot/../src/sm2_function.ps1
}

Describe "sm2" {
    Context "when value from pipeline received" {
        It "sum up" {
            [string[]] $stdin  = @(
                "A 1 10",
                "B 1 10",
                "A 1 10",
                "C 1 10"
            )
            [string[]] $stdout = @(
                "A 1 20",
                "B 1 10",
                "C 1 10"
            )
            $stdin | Sort-Object | sm2 1 2 3 3 | Should -Be $stdout
        }
        It "sum up and +count" {
            [string[]] $stdin  = @(
                "A 1 10",
                "B 1 10",
                "A 1 10",
                "C 1 10"
            )
            [string[]] $stdout = @(
                "2 A 1 20",
                "1 B 1 10",
                "1 C 1 10"
            )
            $stdin | Sort-Object | sm2 +count 1 2 3 3 | Should -Be $stdout
        }
        It "calculate mode" {
            [string[]] $stdin  = @(
                "A 1 10",
                "B 1 10",
                "A 1 10",
                "C 1 10"
            )
            [int] $stdout = 4
            $stdin | sm2 0 0 2 2 | Should -Be $stdout
        }
    }
}

