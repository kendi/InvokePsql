function test
{
    [CmdletBinding()]
    param()
    
    try
    {
        Write-Host -ForegroundColor Magenta "�e�X�g���J�n���܂��B`r`n"

        $Script:TestContext = create-context
        
        # test run
        test-load-module
        test-invoke-psql

        # teardown
        Write-Host -ForegroundColor Magenta "�e�X�g�̌㏈�����J�n���܂��B"
        Remove-Module $TestContext.ModuleName
        Write-Host -ForegroundColor Magenta "�S�Ẵe�X�g���������܂����B`r`n"
    }
    catch
    {
        Write-Error "�G���[�������������߁A�e�X�g���s���ɏI�����܂���"
        Write-Error $_
        Write-Error $error[0]
    }
}

function create-context
{
    $testContext = [pscustomobject] @{
        ModuleName = "InvokePsql";
        ModuleRootPath = Split-Path (Split-Path $script:MyInvocation.MyCommand.Path -Parent) -Parent;
    }

    $testConfig = Get-Content (Join-Path $testContext.ModuleRootPath 'test\test.config.json') -Encoding UTF8 -Raw | ConvertFrom-Json
    $configConn = $testConfig.TestDbConnection
    $connection = [pscustomobject] @{
        Host = $configConn.Host;
        User = $configConn.User;
        Db = $configConn.DbName;
        Sql = ('select * from {0}' -f $configConn.TableName);
    }
    Add-Member -InputObject $testContext -MemberType NoteProperty -Name Connection -Value $connection

    Write-Host -ForegroundColor Yellow $testContext.Connection

    return $testContext
}

function test-load-module
{
    Write-Host -ForegroundColor Magenta "���W���[���ǂݍ��� �e�X�g�J�n"
    Write-Host -ForegroundColor Magenta "======================================="
    Import-Module (Join-Path $TestContext.ModuleRootPath "InvokePsql.psm1") -Verbose -Force
    Write-Host -ForegroundColor Magenta "���W���[���ǂݍ��� �e�X�g����`r`n"
}

function test-invoke-psql
{
    function test-select-table
    {   
        Invoke-Psql -Verbose -ErrorAction Stop `
            -h $TestContext.Connection.Host -d $TestContext.Connection.Db -U $TestContext.Connection.User -c $TestContext.Connection.Sql
        Invoke-Psql -Verbose -ErrorAction Stop `
            -h $TestContext.Connection.Host -d $TestContext.Connection.Db -U $TestContext.Connection.User -c $TestContext.Connection.Sql -t
    }

    function test-special-command
    {
        Invoke-Psql -Verbose -ErrorAction Stop -V
        Invoke-Psql -Verbose -ErrorAction Stop -l `
            -h $TestContext.Connection.Host -d $TestContext.Connection.Db -U $TestContext.Connection.User
    }

    function test-select-from-pipeline
    {
        @(
            'select id from invoke_psql_test;',
            'select register_timestamp from invoke_psql_test;',
            'select value from invoke_psql_test'
        ) |
            Invoke-Psql -Verbose -ErrorAction Stop `
                -h $TestContext.Connection.Host -d $TestContext.Connection.Db -U $TestContext.Connection.User

        @(
            [pscustomobject] @{Command = 'select id from invoke_psql_test;';},
            [pscustomobject] @{Command = 'select register_timestamp from invoke_psql_test;';},
            [pscustomobject] @{Command = 'select value from invoke_psql_test;';}
        ) |
            Invoke-Psql -Verbose -ErrorAction Stop `
            -h $TestContext.Connection.Host -d $TestContext.Connection.Db -U $TestContext.Connection.User
    }

    function test-select-to-pipeline
    {
        $result = Invoke-Psql -Verbose -ErrorAction Stop `
            -h $TestContext.Connection.Host -d $TestContext.Connection.Db -U $TestContext.Connection.User -c $TestContext.Connection.Sql
        
        Write-Host ('Invoke-Psql result type => {0}' -f $result.GetType()) # expected array
    }

    # test-invoke-psql start
    Write-Host -ForegroundColor Magenta "Invoke-Psql �e�X�g�J�n"
    Write-Host -ForegroundColor Magenta "======================================="
    
    Write-Host -ForegroundColor Magenta "    test-select-table �J�n"
    test-select-table
    
    Write-Host -ForegroundColor Magenta "    test-select-special-command �J�n"
    test-special-command
    
    Write-Host -ForegroundColor Magenta "    test-select-from-pipeline �J�n"
    test-select-from-pipeline

    Write-Host -ForegroundColor Magenta "    test-select-to-pipeline �J�n"
    test-select-to-pipeline

    Write-Host -ForegroundColor Magenta "Invoke-Psql �e�X�g����`r`n"
}

# main
cls
test -Verbose