<#
.Synopsis
    psql コマンドを実行します。
.DESCRIPTION
    psql コマンドを新しいプロセスで実行します。指定したパラメータは、そのまま psql コマンドに引き渡されます。
.EXAMPLE
    Invoke-Psql -h localhost -U postgres -d mydb -c 'select * from table;'
.EXAMPLE
    Invoke-Psql -h localhost -U postgres -d mydb -c "update table set col='value' where key=123;"
#>
function Invoke-Psql
{
    [CmdletBinding()]
    [OutputType([string[]])]
    Param
    (
        [Parameter(
            Mandatory = $false,
            HelpMessage = "サーバを実行しているマシンのホスト名を指定します。",
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias("h")]
        [string]
        $HostName = "localhost",

        [Parameter(
            Mandatory = $false,
            HelpMessage = "サーバが接続監視を行っているTCPポートを指定します。",
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias("p")]
        [int]
        $Port = 5432,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "接続するデータベースの名前を指定します。",
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias("d")]
        [string]
        $DbName,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "デフォルトのユーザではなくusernameユーザとしてデータベースに接続します。",
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias("U")]
        [string]
        $UserName = [Environment]::UserName,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "psqlに対し、commandという1つのコマンド文字列を実行し、終了するよう指示します。",
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias("c")]
        [string]
        $Command,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "利用可能な全てのデータベースを一覧表示し、終了します。 この他の接続に関連しないオプションは無視されます。 \listメタコマンドと似た効力を持ちます。"
        )]
        [switch]
        [Alias("l")]
        $List,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "列名と結果の行数フッタなどの表示を無効にします。 これは、\tコマンドとまったく同じ効力を持ちます。",
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [switch]
        [Alias("t")]
        $TuplesOnly,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "psqlのバージョンを表示し、終了します。"
        )]
        [switch]
        [Alias("V")]
        $Version
    )

    Begin
    {
    }
    Process
    {
        $psqlExe = $InvokePsql.psql.providerPath

        $exeArgsHash = @{
            "-h" = $HostName;
            "-p" = $Port;
            "-U" = $UserName;
        }
        if (-not ([string]::IsNullOrWhiteSpace($Command))) { $exeArgsHash.Add("-c", ('"{0}"' -f $Command)) }
        if (-not ([string]::IsNullOrWhiteSpace($DbName))) { $exeArgsHash.Add("-d", $DbName) }
        if ($List.IsPresent) { $exeArgsHash.Add("-l", "") }
        if ($TuplesOnly.IsPresent) { $exeArgsHash.Add("-t", "") }
        if ($Version.IsPresent) { $exeArgsHash.Add("-V", "") }

        $exeArgs = (($exeArgsHash.Keys | % { "{0} {1}" -f $_, $exeArgsHash[$_] }) -join " ")

        Write-Debug "psql command path:$psqlExe"
        Write-Debug "args:$exeArgs"

        return ((Invoke-NewProcess $psqlExe $exeArgs) -split "`r`n")
    }
    End
    {
    }
}