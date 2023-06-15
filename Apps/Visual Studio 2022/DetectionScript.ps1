$appExists = Test-Path "%ProgramFiles%\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe" -ErrorAction SilentlyContinue
if (-not $appExists) {
    Write-Output "Microsoft Visual Studio 2022 found."
    Exit 1
}

Write-Output "Microsoft Visual Studio 2022 NOT found."
Exit 0