1>1/* :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: by bajins https://www.bajins.com

@echo off
md "%~dp0$testAdmin$" 2>nul
if not exist "%~dp0$testAdmin$" (
    echo bajins不具备所在目录的写入权限! >&2
    exit /b 1
) else rd "%~dp0$testAdmin$"

:: 开启延迟环境变量扩展
setlocal enabledelayedexpansion

:: 执行7z命令，但是不输出，这是为了判断
7za > nul
:: 如果7z压缩命令行不存在，则下载
if not "%errorlevel%" == "0" (
    :: cscript -nologo -e:jscript "%~f0" 这一段是执行命令，后面的是参数（组成方式：/key:value）
    :: %~f0 表示当前批处理的绝对路径,去掉引号的完整路径
    cscript -nologo -e:jscript "%~f0" https://github.com/woytu/woytu.github.io/releases/download/v1.0/7za.exe C:\Windows
)
:: 需要打包的文件或文件夹根目录
set root=%~dp0
:: 需要打包的文件或文件夹
set files=data

:: 仅将 %0 扩充到一个路径
set currentPath=%~p0
:: 替换\为,号，也可以替换为空格
set currentPath=%currentPath:\=,%
:: 顺序循环，设置最后一个为当前目录
for %%a in (%currentPath%) do set CurrentDirectoryName=%%a
:: 打包完成的文件命名前一部分
set project=%CurrentDirectoryName%
:: 打包完成的文件命名后一部分，与前一部分进行组合
set allList=_darwin_386,_darwin_amd64,_freebsd_386,_freebsd_amd64,_freebsd_arm,_netbsd_386,_netbsd_amd64,_netbsd_arm,
set allList=%allList%_openbsd_386,_openbsd_amd64,_windows_386.exe,_windows_amd64.exe,
set allList=%allList%_linux_386,_linux_amd64,_linux_arm,_linux_mips,_linux_mips64,_linux_mips64le,_linux_mipsle,_linux_s390x

:GETGOX
set GOPROXY=https://goproxy.io
go get github.com/mitchellh/gox

for %%i in (%allList%) do (
    :: 如果二进制文件不存在则重新打包
    if not exist "%project%%%i" (
        gox
        if not %errorlevel% == 0 (
            goto :GETGOX
        )
        :: 删除旧的压缩包文件
        del *.zip *.tar *.gz
    )
)


:: 使用7z压缩
for %%i in (%allList%) do (
    set runFile=%project%%%i
    :: !!和%%都是取变量的值，用这种方法的批处理文件前面一般有setlocal EnableDelayedExpansion（延迟环境变量扩展）语句
    if exist "!runFile!" (
        :: 判断变量字符串中是否包含字符串
        echo %%i | findstr linux >nul && (
            :: 用7z压缩成tar
            7za a -ttar %project%%%i.tar %files% !runFile!
            :: 用7z把tar压缩成gz
            7za a -tgzip %project%%%i.tar.gz %project%%%i.tar
            :: 删除tar文件和二进制文件
            del *.tar !runFile!
            
        ) || (
            :: 用7z压缩文件为zip
            7za a %project%%%i.zip %files% !runFile!
            :: 删除二进制文件
            del !runFile!
        )
    )
)



goto :EXIT

:EXIT
:: 结束延迟环境变量扩展和命令执行
endlocal&exit /b %errorlevel%
*/

// ****************************  JavaScript  *******************************


var iRemote = WScript.Arguments(0);
iRemote = iRemote.toLowerCase();
var iLocal = WScript.Arguments(1);
iLocal = iLocal.toLowerCase()+"\\"+ iRemote.substring(iRemote.lastIndexOf("/") + 1);
var xPost = new ActiveXObject("Microsoft.XMLHTTP");
xPost.Open("GET", iRemote, 0);
xPost.Send();
var sGet = new ActiveXObject("ADODB.Stream");
sGet.Mode = 3;
sGet.Type = 1;
sGet.Open();
sGet.Write(xPost.responseBody);
sGet.SaveToFile(iLocal, 2);
sGet.Close();