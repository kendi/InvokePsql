<#
.Synopsis
    psql �R�}���h�����s���܂��B
.DESCRIPTION
    psql �R�}���h��V�����v���Z�X�Ŏ��s���܂��B�w�肵���p�����[�^�́A���̂܂� psql �R�}���h�Ɉ����n����܂��B
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
            HelpMessage = "�T�[�o�����s���Ă���}�V���̃z�X�g�����w�肵�܂��B",
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias("h")]
        [string]
        $HostName = "localhost",

        [Parameter(
            Mandatory = $false,
            HelpMessage = "�T�[�o���ڑ��Ď����s���Ă���TCP�|�[�g���w�肵�܂��B",
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias("p")]
        [int]
        $Port = 5432,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "�ڑ�����f�[�^�x�[�X�̖��O���w�肵�܂��B",
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias("d")]
        [string]
        $DbName,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "�f�t�H���g�̃��[�U�ł͂Ȃ�username���[�U�Ƃ��ăf�[�^�x�[�X�ɐڑ����܂��B",
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias("U")]
        [string]
        $UserName = [Environment]::UserName,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "psql�ɑ΂��Acommand�Ƃ���1�̃R�}���h����������s���A�I������悤�w�����܂��B",
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias("c")]
        [string]
        $Command,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "���p�\�ȑS�Ẵf�[�^�x�[�X���ꗗ�\�����A�I�����܂��B ���̑��̐ڑ��Ɋ֘A���Ȃ��I�v�V�����͖�������܂��B \list���^�R�}���h�Ǝ������͂������܂��B"
        )]
        [switch]
        [Alias("l")]
        $List,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "�񖼂ƌ��ʂ̍s���t�b�^�Ȃǂ̕\���𖳌��ɂ��܂��B ����́A\t�R�}���h�Ƃ܂������������͂������܂��B",
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [switch]
        [Alias("t")]
        $TuplesOnly,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "psql�̃o�[�W������\�����A�I�����܂��B"
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