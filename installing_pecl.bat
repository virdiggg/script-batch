@echo off

:: BatchGotAdmin
:: Check for administrator privileges
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
:: If error, request admin privileges
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else (
    goto gotAdmin
)

:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
exit /B

:gotAdmin
if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
pushd "%CD%"
CD /D "%~dp0"
:: Your commands here
echo Running with administrator privileges...

@REM :: Delete installing_pecl.bat if it exists
@REM if exist "installing_pecl.bat" (
@REM     echo Deleting old installing_pecl.bat...
@REM     del "installing_pecl.bat"
@REM )

:: Prompt for PHP installation path
SET /p phpPath=Copy your PHP installation path (C:\php...): 

:: Check if phpPath is empty
if "%phpPath%"=="" (
    echo PHP Path is empty.
    echo Cancelling installation.
    goto end
)

:: Validate PHP path
echo PHP Path: %phpPath%
cd /d "%phpPath%" 2>nul
if %errorlevel% NEQ 0 (
    echo Invalid PHP path: %phpPath%
    echo Cancelling installation.
    goto end
)

:: Add PHP to PATH if not already present
echo %PATH% | find /i "%phpPath%" >nul 2>&1
if %errorlevel% NEQ 0 (
    echo Adding PHP to PATH...
    setx PATH "%PATH%;%phpPath%"
)

:: Test PHP installation
echo Testing PHP installation...
php -v >nul 2>&1
if %errorlevel% NEQ 0 (
    echo PHP is not working in the provided path: %phpPath%
    echo Cancelling installation.
    goto end
)

:: Check if peclcmd.php exists, if not, download it
if not exist "peclcmd.php" (
    echo Downloading peclcmd.php...
    powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/pear/pear-core/refs/heads/master/scripts/peclcmd.php' -OutFile 'peclcmd.php'"
    if %errorlevel% NEQ 0 (
        echo Failed to download peclcmd.php.
        goto end
    )
)

:: Check if pearcmd.php exists, if not, download it
if not exist "pearcmd.php" (
    echo Downloading pearcmd.php...
    powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/pear/pear-core/refs/heads/master/scripts/pearcmd.php' -OutFile 'pearcmd.php'"
    if %errorlevel% NEQ 0 (
        echo Failed to download pearcmd.php.
        goto end
    )
)

:: Check if pecl.bat exists, if not, create it
if not exist "pecl.bat" (
    echo Creating pecl.bat...
    echo @echo off > pecl.bat
    echo set PHP_PEAR_PHP_BIN=php.exe >> pecl.bat
    echo set PHP_PEAR_INSTALL_DIR=%phpPath% >> pecl.bat
    echo php "%%PHP_PEAR_INSTALL_DIR%%peclcmd.php" %%* >> pecl.bat
    if %errorlevel% NEQ 0 (
        echo Failed to create pecl.bat.
        goto end
    )
)

:: Check if go-pear.phar exists, if not, download it
if not exist "go-pear.phar" (
    echo Downloading go-pear.phar...
    powershell -Command "Invoke-WebRequest -Uri 'https://pear.php.net/go-pear.phar' -OutFile 'go-pear.phar'"
    if %errorlevel% NEQ 0 (
        echo Failed to download go-pear.phar.
        goto end
    )
)

:: Run go-pear.phar
echo Running go-pear.phar...
php go-pear.phar
if %errorlevel% NEQ 0 (
    echo Failed to run go-pear.phar.
    goto end
)

@REM :: Update PECL channels (commented out)
@REM echo Updating PECL channels...
@REM pecl channel-update pecl.php.net
@REM if %errorlevel% NEQ 0 (
@REM     echo Failed to update PECL channels.
@REM     goto end
@REM )

:end
echo Finish

@REM :: Delete installing_pecl.bat if it exists
@REM if exist "installing_pecl.bat" (
@REM     echo Deleting installing_pecl.bat...
@REM     del "installing_pecl.bat"
@REM )

pause
exit /b