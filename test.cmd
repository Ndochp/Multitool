@chcp 65001
echo %time%
call UPdate.cmd
echo %time%
"D:\Soft\1Cv8\8.3.27.2074\bin\1cv8c.exe" /IBConnectionString "File=""D:\GIT_REPO\Multitool\build\ib"";" /C "RunUnitTests=D:\GIT_REPO\Multitool\tests\yaxUnit.json"
echo %time%
@REM call vrunner vanessa %*
