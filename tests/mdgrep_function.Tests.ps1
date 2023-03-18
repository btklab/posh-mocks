BeforeAll {
    . $PSScriptRoot/../src/mdgrep_function.ps1
    $stdin = @(
        "# My favorite links",
        "abstract",
        "## HACCP",
        "hoge1",
        "### Books",
        "fuga1",
        "### Articles",
        "piyo1",
        "## Computer",
        "hoge2",
        "### Books",
        "fuga2",
        "### Articles",
        "piyo2"
    )
}

Describe "mdgrep" {
    Context "when value from pipeline received" {
        It "mdgrep ." {
            [string[]] $stdout = @(
                "## HACCP",
                "### Books",
                "### Articles",
                "## Computer",
                "### Books",
                "### Articles"
            )
            $stdin | mdgrep . | Should -Be $stdout
        }
        It "mdgrep . -e" {
            [string[]] $stdout = @(
                "## HACCP",
                "hoge1",
                "### Books",
                "fuga1",
                "### Articles",
                "piyo1",
                "## Computer",
                "hoge2",
                "### Books",
                "fuga2",
                "### Articles",
                "piyo2"
            )
            $stdin | mdgrep . -e | Should -Be $stdout
        }
        It "mdgrep hoge1 -e" {
            [string[]] $stdout = @(
                "## HACCP",
                "hoge1",
                "### Books",
                "fuga1",
                "### Articles",
                "piyo1"
            )
            $stdin | mdgrep hoge1 -e | Should -Be $stdout
        }
        It "mdgrep hoge1 -NotMatch -e" {
            [string[]] $stdout = @(
                "## Computer",
                "hoge2",
                "### Books",
                "fuga2",
                "### Articles",
                "piyo2"
            )
            $stdin | mdgrep hoge1 -NotMatch -e | Should -Be $stdout
        }
        It "mdgrep haccp -MatchOnlyTitle -e" {
            [string[]] $stdout = @(
                "## HACCP",
                "hoge1",
                "### Books",
                "fuga1",
                "### Articles",
                "piyo1"
            )
            $stdin | mdgrep haccp -MatchOnlyTitle -e | Should -Be $stdout
        }
    }
    Context "invert match" {
        It "mdgrep haccp -MatchOnlyTitle -NotMatch -e" {
            [string[]] $stdout = @(
                "## Computer",
                "hoge2",
                "### Books",
                "fuga2",
                "### Articles",
                "piyo2"
            )
            $stdin | mdgrep haccp -MatchOnlyTitle -NotMatch -e | Should -Be $stdout
        }
        It "mdgrep Books -MatchOnlyTitle" {
            $stdout = $Null
            $stdin | mdgrep Books -MatchOnlyTitle | Should -Be $stdout
        }
    }
    Context "change section level to grep" {
        It "mdgrep fuga -Level 3 -e" {
            [string[]] $stdout = @(
                "### Books",
                "fuga1",
                "### Books",
                "fuga2"
            )
            $stdin | mdgrep fuga -Level 3 -e | Should -Be $stdout
        }
    }
    Context "Output parent sections" {
        It "mdgrep fuga -Level 3 -OutputParentSection -e" {
            [string[]] $stdout = @(
                "# My favorite links",
                "## HACCP",
                "### Books",
                "fuga1",
                "## Computer",
                "### Books",
                "fuga2"
            )
            $stdin | mdgrep fuga -Level 3 -OutputParentSection -e | Should -Be $stdout
        }
        It "mdgrep fuga2 -Level 3 -p -e" {
            [string[]] $stdout = @(
                "# My favorite links",
                "## HACCP",
                "## Computer",
                "### Books",
                "fuga2"
            )
            $stdin | mdgrep fuga2 -Level 3 -p -e | Should -Be $stdout
        }
    }
}
