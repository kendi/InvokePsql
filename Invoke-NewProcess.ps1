<#
.Synopsis
    指定された実行ファイルを新しいプロセスで同期的に実行します。
.DESCRIPTION
    指定された実行ファイルを新しいプロセスで同期的に実行します。
.EXAMPLE
    Invoke-NewProccess C:\Windows\system32\notepad.exe
.EXAMPLE
    Invoke-NewProccess C:\Windows\system32\notepad.exe C:\readme.txt
.EXAMPLE
    $result = Invoke-NewProccess C:\yourApp.exe arg1 arg2 arg3
    Write-Output ("Result is {0}" -f $result)
#>
function Invoke-NewProcess
{
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = "実行ファイルのフルパスを指定します。",
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateScript({Test-Path -Path $_})]
        [string]
        $FilePath,

        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = "実行ファイルに渡すパラメータを指定します。",
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]
        $Parameters
    )

    Begin
    {
    }
    Process
    {
        $joinedParams = [string]::Join(" ", $Parameters)

        $pInfo = New-Object System.Diagnostics.ProcessStartInfo 
        $pInfo.FileName = $FilePath
        $pInfo.RedirectStandardError = $true 
        $pInfo.RedirectStandardOutput = $true
        $pInfo.UseShellExecute = $false 
        $pInfo.Arguments = $joinedParams

        Write-Verbose ('Execute Command:{{$filePath:{0}, $parameters:{1}}}' -f $FilePath, $joinedParams)

        $process = New-Object System.Diagnostics.Process 
        $process.StartInfo = $pInfo 
        $process.Start() | Out-Null

        $output = $process.StandardOutput.ReadToEnd();
        $outputError = $process.StandardError.ReadToEnd();
        $Process.WaitForExit()

        Write-Debug "Result(stdout) => `r`n$output"
        Write-Debug "Result(errout) => `r`n$outputError"

        return ($output + $outputError)
    }
    End
    {
    }
}