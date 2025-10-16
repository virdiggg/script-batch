@ECHO off

setlocal enableDelayedExpansion

echo Loading...

SET currentPath=%~dp0
SET "fileName=output.txt"
SET fullPath="%currentPath%%fileName%"
SET "url=http://192.168.0.200/popoyan/api/dumped"
SET "token=Secret-Key: eyJpdiI6ImpTT2ZmSXdVeHhWWWwyVXciLCJ2YWx1ZSI6IjBBSzJhY3hzdFZVQmlkNWRweG0wTXJtRElnPT0iLCJtYWMiOiIiLCJ0YWciOiJGNStwa1R5R3AxWElFbVhqeWRZeDNRPT0ifQ=="
SET "headers=Content-Type: application/json"

cls

echo ***************************************************************************************************************
echo * PC Dumper v1.0.0.0                                                                                          *
echo *                                                                                                             *
echo *                                                                                                             *
echo *                                                                                               Virdi Gunawan *
echo ***************************************************************************************************************

echo Enter your name:
SET /p USERNAME=

echo Enter your NIK:
SET /p NIK=

cls

SET "BOOTDEVICE="
SET "BUILDNUMBER="
SET "BUILDTYPE="
SET "CAPTION="
SET "CODESET="
SET "COUNTRYCODE="
SET "CREATIONCLASSNAME="
SET "CSCREATIONCLASSNAME="
SET "CSDVERSION="
SET "CSNAME="
SET "CURRENTTIMEZONE="
SET "DATAEXECUTIONPREVENTION_32BITAPPLICATIONS="
SET "DATAEXECUTIONPREVENTION_AVAILABLE="
SET "DATAEXECUTIONPREVENTION_DRIVERS="
SET "FREEVIRTUALMEMORY="
SET "INSTALLDATE="
SET "LARGESYSTEMCACHE="
SET "LASTBOOTUPTIME="
SET "LOCALDATETIME="
SET "LOCALE="
SET "MANUFACTURER="
SET "MAXNUMBEROFPROCESSES="
SET "MAXPROCESSMEMORYSIZE="
SET "MUILANGUAGES="
SET "NUMBEROFLICENSEDUSERS="
SET "NUMBEROFPROCESSES="
SET "NUMBEROFUSERS="
SET "OPERATINGSYSTEMSKU="
SET "ORGANIZATION="
SET "OSARCHITECTURE="
SET "OSLANGUAGE="
SET "OSPRODUCTSUITE="
SET "OSTYPE="
SET "OTHERTYPEDESCRIPTION="
SET "PAEENABLED="
SET "PLUSPRODUCTID="
SET "PLUSVERSIONNUMBER="
SET "PORTABLEOPERATINGSYSTEM="
SET "PRIMARY="
SET "PRODUCTTYPE="
SET "REGISTEREDUSER="
SET "SERIALNUMBER="
SET "SERVICEPACKMAJORVERSION="
SET "SERVICEPACKMINORVERSION="
SET "SIZESTOREDINPAGINGFILES="
SET "STATUS="
SET "SUITEMASK="
SET "SYSTEMDEVICE="
SET "SYSTEMDIRECTORY="
SET "SYSTEMDRIVE="
SET "TOTALSWAPSPACESIZE="
SET "TOTALVIRTUALMEMORYSIZE="
SET "TOTALVISIBLEMEMORYSIZE="
SET "VERSION="
SET "WINDOWSDIRECTORY="
set "IP_CONFIG="
@REM set "PHYSICALADDRESS="
@REM set "SUBNETMASK="
SET "MACADDRESS="
@REM SET "TRANSPORTNAME="

echo Preparing Data...
echo Do not close this window.

for /f "delims=" %%a in ('wmic OS get /Value 2^>^&1') do (
    echo %%a | findstr /C:"BootDevice" >nul
    if !errorlevel! equ 0 (
        SET "BOOTDEVICE=%%a"
    )
    echo %%a | findstr /C:"BuildNumber" >nul
    if !errorlevel! equ 0 (
        SET "BUILDNUMBER=%%a"
    )
    echo %%a | findstr /C:"BuildType" >nul
    if !errorlevel! equ 0 (
        SET "BUILDTYPE=%%a"
    )
    echo %%a | findstr /C:"Caption" >nul
    if !errorlevel! equ 0 (
        SET "CAPTION=%%a"
    )
    echo %%a | findstr /C:"CodeSet" >nul
    if !errorlevel! equ 0 (
        SET "CODESET=%%a"
    )
    echo %%a | findstr /C:"CountryCode" >nul
    if !errorlevel! equ 0 (
        SET "COUNTRYCODE=%%a"
    )
    echo %%a | findstr /C:"CreationClassName" >nul
    if !errorlevel! equ 0 (
        SET "CREATIONCLASSNAME=%%a"
    )
    echo %%a | findstr /C:"CSCreationClassName" >nul
    if !errorlevel! equ 0 (
        SET "CSCREATIONCLASSNAME=%%a"
    )
    echo %%a | findstr /C:"CSDVersion" >nul
    if !errorlevel! equ 0 (
        SET "CSDVERSION=%%a"
    )
    echo %%a | findstr /C:"CSName" >nul
    if !errorlevel! equ 0 (
        SET "CSNAME=%%a"
    )
    echo %%a | findstr /C:"CurrentTimeZone" >nul
    if !errorlevel! equ 0 (
        SET "CURRENTTIMEZONE=%%a"
    )
    echo %%a | findstr /C:"DataExecutionPrevention_32BitApplications" >nul
    if !errorlevel! equ 0 (
        SET "DATAEXECUTIONPREVENTION_32BITAPPLICATIONS=%%a"
    )
    echo %%a | findstr /C:"DataExecutionPrevention_Available" >nul
    if !errorlevel! equ 0 (
        SET "DATAEXECUTIONPREVENTION_AVAILABLE=%%a"
    )
    echo %%a | findstr /C:"DataExecutionPrevention_Drivers" >nul
    if !errorlevel! equ 0 (
        SET "DATAEXECUTIONPREVENTION_DRIVERS=%%a"
    )
    echo %%a | findstr /C:"FreeVirtualMemory" >nul
    if !errorlevel! equ 0 (
        SET "FREEVIRTUALMEMORY=%%a"
    )
    echo %%a | findstr /C:"InstallDate" >nul
    if !errorlevel! equ 0 (
        SET "INSTALLDATE=%%a"
    )
    echo %%a | findstr /C:"LargeSystemCache" >nul
    if !errorlevel! equ 0 (
        SET "LARGESYSTEMCACHE=%%a"
    )
    echo %%a | findstr /C:"LastBootUpTime" >nul
    if !errorlevel! equ 0 (
        SET "LASTBOOTUPTIME=%%a"
    )
    echo %%a | findstr /C:"LocalDateTime" >nul
    if !errorlevel! equ 0 (
        SET "LOCALDATETIME=%%a"
    )
    echo %%a | findstr /C:"Locale" >nul
    if !errorlevel! equ 0 (
        SET "LOCALE=%%a"
    )
    echo %%a | findstr /C:"Manufacturer" >nul
    if !errorlevel! equ 0 (
        SET "MANUFACTURER=%%a"
    )
    echo %%a | findstr /C:"MaxNumberOfProcesses" >nul
    if !errorlevel! equ 0 (
        SET "MAXNUMBEROFPROCESSES=%%a"
    )
    echo %%a | findstr /C:"MaxProcessMemorySize" >nul
    if !errorlevel! equ 0 (
        SET "MAXPROCESSMEMORYSIZE=%%a"
    )
    echo %%a | findstr /C:"MUILanguages" >nul
    if !errorlevel! equ 0 (
        SET "MUILANGUAGES=%%a"
    )
    echo %%a | findstr /C:"NumberOfLicensedUsers" >nul
    if !errorlevel! equ 0 (
        SET "NUMBEROFLICENSEDUSERS=%%a"
    )
    echo %%a | findstr /C:"NumberOfProcesses" >nul
    if !errorlevel! equ 0 (
        SET "NUMBEROFPROCESSES=%%a"
    )
    echo %%a | findstr /C:"NumberOfUsers" >nul
    if !errorlevel! equ 0 (
        SET "NUMBEROFUSERS=%%a"
    )
    echo %%a | findstr /C:"OperatingSystemSKU" >nul
    if !errorlevel! equ 0 (
        SET "OPERATINGSYSTEMSKU=%%a"
    )
    echo %%a | findstr /C:"Organization" >nul
    if !errorlevel! equ 0 (
        SET "ORGANIZATION=%%a"
    )
    echo %%a | findstr /C:"OSArchitecture" >nul
    if !errorlevel! equ 0 (
        SET "OSARCHITECTURE=%%a"
    )
    echo %%a | findstr /C:"OSLanguage" >nul
    if !errorlevel! equ 0 (
        SET "OSLANGUAGE=%%a"
    )
    echo %%a | findstr /C:"OSProductSuite" >nul
    if !errorlevel! equ 0 (
        SET "OSPRODUCTSUITE=%%a"
    )
    echo %%a | findstr /C:"OSType" >nul
    if !errorlevel! equ 0 (
        SET "OSTYPE=%%a"
    )
    echo %%a | findstr /C:"OtherTypeDescription" >nul
    if !errorlevel! equ 0 (
        SET "OTHERTYPEDESCRIPTION=%%a"
    )
    echo %%a | findstr /C:"PAEEnabled" >nul
    if !errorlevel! equ 0 (
        SET "PAEENABLED=%%a"
    )
    echo %%a | findstr /C:"PlusProductID" >nul
    if !errorlevel! equ 0 (
        SET "PLUSPRODUCTID=%%a"
    )
    echo %%a | findstr /C:"PlusVersionNumber" >nul
    if !errorlevel! equ 0 (
        SET "PLUSVERSIONNUMBER=%%a"
    )
    echo %%a | findstr /C:"PortableOperatingSystem" >nul
    if !errorlevel! equ 0 (
        SET "PORTABLEOPERATINGSYSTEM=%%a"
    )
    echo %%a | findstr /C:"Primary" >nul
    if !errorlevel! equ 0 (
        SET "PRIMARY=%%a"
    )
    echo %%a | findstr /C:"ProductType" >nul
    if !errorlevel! equ 0 (
        SET "PRODUCTTYPE=%%a"
    )
    echo %%a | findstr /C:"RegisteredUser" >nul
    if !errorlevel! equ 0 (
        SET "REGISTEREDUSER=%%a"
    )
    echo %%a | findstr /C:"SerialNumber" >nul
    if !errorlevel! equ 0 (
        SET "SERIALNUMBER=%%a"
    )
    echo %%a | findstr /C:"ServicePackMajorVersion" >nul
    if !errorlevel! equ 0 (
        SET "SERVICEPACKMAJORVERSION=%%a"
    )
    echo %%a | findstr /C:"ServicePackMinorVersion" >nul
    if !errorlevel! equ 0 (
        SET "SERVICEPACKMINORVERSION=%%a"
    )
    echo %%a | findstr /C:"SizeStoredInPagingFiles" >nul
    if !errorlevel! equ 0 (
        SET "SIZESTOREDINPAGINGFILES=%%a"
    )
    echo %%a | findstr /C:"Status" >nul
    if !errorlevel! equ 0 (
        SET "STATUS=%%a"
    )
    echo %%a | findstr /C:"SuiteMask" >nul
    if !errorlevel! equ 0 (
        SET "SUITEMASK=%%a"
    )
    echo %%a | findstr /C:"SystemDevice" >nul
    if !errorlevel! equ 0 (
        SET "SYSTEMDEVICE=%%a"
    )
    echo %%a | findstr /C:"SystemDirectory" >nul
    if !errorlevel! equ 0 (
        SET "SYSTEMDIRECTORY=%%a"
    )
    echo %%a | findstr /C:"SystemDrive" >nul
    if !errorlevel! equ 0 (
        SET "SYSTEMDRIVE=%%a"
    )
    echo %%a | findstr /C:"TotalSwapSpaceSize" >nul
    if !errorlevel! equ 0 (
        SET "TOTALSWAPSPACESIZE=%%a"
    )
    echo %%a | findstr /C:"TotalVirtualMemorySize" >nul
    if !errorlevel! equ 0 (
        SET "TOTALVIRTUALMEMORYSIZE=%%a"
    )
    echo %%a | findstr /C:"TotalVisibleMemorySize" >nul
    if !errorlevel! equ 0 (
        SET "TOTALVISIBLEMEMORYSIZE=%%a"
    )
    echo %%a | findstr /C:"Version" >nul
    if !errorlevel! equ 0 (
        SET "VERSION=%%a"
    )
    echo %%a | findstr /C:"WindowsDirectory" >nul
    if !errorlevel! equ 0 (
        SET "WINDOWSDIRECTORY=%%a"
    )
)

for /f "delims=" %%a in ('ipconfig /all ^| findstr /C:"Ethernet adapter Ethernet" /C:"Physical Address" /C:"IPv4 Address" /C:"Subnet Mask"') do (
    echo %%a | findstr /C:"IPv4 Address" >nul
    if !errorlevel! equ 0 (
        if not defined IP_CONFIG (
            set "IP_CONFIG=%%a"
        )
    )
    @REM echo %%a | findstr /C:"Physical Address" >nul
    @REM if !errorlevel! equ 0 (
    @REM     if not defined PHYSICALADDRESS (
    @REM         set "PHYSICALADDRESS=%%a"
    @REM     )
    @REM )
    @REM echo %%a | findstr /C:"Subnet Mask" >nul
    @REM if !errorlevel! equ 0 (
    @REM     if not defined SUBNETMASK (
    @REM         set "SUBNETMASK=%%a"
    @REM     )
    @REM )
)

for /f "delims=" %%a in ('getmac') do (
    echo %%a | findstr /C:"-" >nul
    if !errorlevel! equ 0 (
        SET "TEMP_MACADDRESS=%%a"
        for /f "tokens=1,* delims=\" %%a in ("!TEMP_MACADDRESS!") do (
            SET "MACADDRESS=%%a"
            @REM SET "TRANSPORTNAME=%%b"
        )
    )
)

cls

echo Handle the unexpected...
echo Do not close this window.

SET "BOOTDEVICE=!BOOTDEVICE:\=\\!"
SET "BUILDNUMBER=!BUILDNUMBER:\=\\!"
SET "BUILDTYPE=!BUILDTYPE:\=\\!"
SET "CAPTION=!CAPTION:\=\\!"
SET "CODESET=!CODESET:\=\\!"
SET "COUNTRYCODE=!COUNTRYCODE:\=\\!"
SET "CREATIONCLASSNAME=!CREATIONCLASSNAME:\=\\!"
SET "CSCREATIONCLASSNAME=!CSCREATIONCLASSNAME:\=\\!"
SET "CSDVERSION=!CSDVERSION:\=\\!"
SET "CSNAME=!CSNAME:\=\\!"
SET "CURRENTTIMEZONE=!CURRENTTIMEZONE:\=\\!"
SET "DATAEXECUTIONPREVENTION_32BITAPPLICATIONS=!DATAEXECUTIONPREVENTION_32BITAPPLICATIONS:\=\\!"
SET "DATAEXECUTIONPREVENTION_AVAILABLE=!DATAEXECUTIONPREVENTION_AVAILABLE:\=\\!"
SET "DATAEXECUTIONPREVENTION_DRIVERS=!DATAEXECUTIONPREVENTION_DRIVERS:\=\\!"
SET "FREEVIRTUALMEMORY=!FREEVIRTUALMEMORY:\=\\!"
SET "INSTALLDATE=!INSTALLDATE:\=\\!"
SET "LARGESYSTEMCACHE=!LARGESYSTEMCACHE:\=\\!"
SET "LASTBOOTUPTIME=!LASTBOOTUPTIME:\=\\!"
SET "LOCALDATETIME=!LOCALDATETIME:\=\\!"
SET "LOCALE=!LOCALE:\=\\!"
SET "MANUFACTURER=!MANUFACTURER:\=\\!"
SET "MAXNUMBEROFPROCESSES=!MAXNUMBEROFPROCESSES:\=\\!"
SET "MAXPROCESSMEMORYSIZE=!MAXPROCESSMEMORYSIZE:\=\\!"
SET "MUILANGUAGES=!MUILANGUAGES:\=\\!"
SET "NUMBEROFLICENSEDUSERS=!NUMBEROFLICENSEDUSERS:\=\\!"
SET "NUMBEROFPROCESSES=!NUMBEROFPROCESSES:\=\\!"
SET "NUMBEROFUSERS=!NUMBEROFUSERS:\=\\!"
SET "OPERATINGSYSTEMSKU=!OPERATINGSYSTEMSKU:\=\\!"
SET "ORGANIZATION=!ORGANIZATION:\=\\!"
SET "OSARCHITECTURE=!OSARCHITECTURE:\=\\!"
SET "OSLANGUAGE=!OSLANGUAGE:\=\\!"
SET "OSPRODUCTSUITE=!OSPRODUCTSUITE:\=\\!"
SET "OSTYPE=!OSTYPE:\=\\!"
SET "OTHERTYPEDESCRIPTION=!OTHERTYPEDESCRIPTION:\=\\!"
SET "PAEENABLED=!PAEENABLED:\=\\!"
SET "PLUSPRODUCTID=!PLUSPRODUCTID:\=\\!"
SET "PLUSVERSIONNUMBER=!PLUSVERSIONNUMBER:\=\\!"
SET "PORTABLEOPERATINGSYSTEM=!PORTABLEOPERATINGSYSTEM:\=\\!"
SET "PRIMARY=!PRIMARY:\=\\!"
SET "PRODUCTTYPE=!PRODUCTTYPE:\=\\!"
SET "REGISTEREDUSER=!REGISTEREDUSER:\=\\!"
SET "SERIALNUMBER=!SERIALNUMBER:\=\\!"
SET "SERVICEPACKMAJORVERSION=!SERVICEPACKMAJORVERSION:\=\\!"
SET "SERVICEPACKMINORVERSION=!SERVICEPACKMINORVERSION:\=\\!"
SET "SIZESTOREDINPAGINGFILES=!SIZESTOREDINPAGINGFILES:\=\\!"
SET "STATUS=!STATUS:\=\\!"
SET "SUITEMASK=!SUITEMASK:\=\\!"
SET "SYSTEMDEVICE=!SYSTEMDEVICE:\=\\!"
SET "SYSTEMDIRECTORY=!SYSTEMDIRECTORY:\=\\!"
SET "SYSTEMDRIVE=!SYSTEMDRIVE:\=\\!"
SET "TOTALSWAPSPACESIZE=!TOTALSWAPSPACESIZE:\=\\!"
SET "TOTALVIRTUALMEMORYSIZE=!TOTALVIRTUALMEMORYSIZE:\=\\!"
SET "TOTALVISIBLEMEMORYSIZE=!TOTALVISIBLEMEMORYSIZE:\=\\!"
SET "VERSION=!VERSION:\=\\!"
SET "WINDOWSDIRECTORY=!WINDOWSDIRECTORY:\=\\!"
SET "MACADDRESS=!MACADDRESS:\=\\!"
@REM SET "TRANSPORTNAME=!TRANSPORTNAME:\=\\!"

@REM SET "JSON={\"BootDevice\":\"%BOOTDEVICE%\", \"BuildNumber\":\"%BUILDNUMBER%\", \"BuildType\":\"%BUILDTYPE%\", \"Caption\":\"%CAPTION%\", \"CodeSet\":\"%CODESET%\", \"CountryCode\":\"%COUNTRYCODE%\", \"CreationClassName\":\"%CREATIONCLASSNAME%\", \"CSCreationClassName\":\"%CSCREATIONCLASSNAME%\", \"CSDVersion\":\"%CSDVERSION%\", \"CSName\":\"%CSNAME%\", \"CurrentTimeZone\":\"%CURRENTTIMEZONE%\", \"DataExecutionPrevention_32BitApplications\":\"%DATAEXECUTIONPREVENTION_32BITAPPLICATIONS%\", \"DataExecutionPrevention_Available\":\"%DATAEXECUTIONPREVENTION_AVAILABLE%\", \"DataExecutionPrevention_Drivers\":\"%DATAEXECUTIONPREVENTION_DRIVERS%\", \"FreeVirtualMemory\":\"%FREEVIRTUALMEMORY%\", \"InstallDate\":\"%INSTALLDATE%\", \"LargeSystemCache\":\"%LARGESYSTEMCACHE%\", \"LastBootUpTime\":\"%LASTBOOTUPTIME%\", \"LargeSystemCache\":\"%LargeSystemCache%\", \"LocalDateTime\":\"%LOCALDATETIME%\", \"Locale\":\"%LOCALE%\", \"Manufacturer\":\"%MANUFACTURER%\", \"MaxNumberOfProcesses\":\"%MAXNUMBEROFPROCESSES%\", \"MaxProcessMemorySize\":\"%MAXPROCESSMEMORYSIZE%\", \"MUILanguages\":\"%MUILANGUAGES%\", \"NumberOfLicensedUsers\":\"%NUMBEROFLICENSEDUSERS%\", \"NumberOfProcesses\":\"%NUMBEROFPROCESSES%\", \"NumberOfUsers\":\"%NUMBEROFUSERS%\", \"OperatingSystemSKU\":\"%OPERATINGSYSTEMSKU%\", \"Organization\":\"%ORGANIZATION%\", \"OSArchitecture\":\"%OSARCHITECTURE%\", \"OSLanguage\":\"%OSLANGUAGE%\", \"OSProductSuite\":\"%OSPRODUCTSUITE%\", \"OSType\":\"%OSTYPE%\", \"OtherTypeDescription\":\"%OTHERTYPEDESCRIPTION%\", \"PAEEnabled\":\"%PAEENABLED%\", \"PlusProductID\":\"%PLUSPRODUCTID%\", \"PlusVersionNumber\":\"%PLUSVERSIONNUMBER%\", \"PortableOperatingSystem\":\"%PORTABLEOPERATINGSYSTEM%\", \"Primary\":\"%PRIMARY%\", \"ProductType\":\"%PRODUCTTYPE%\", \"RegisteredUser\":\"%REGISTEREDUSER%\", \"SerialNumber\":\"%SERIALNUMBER%\", \"ServicePackMajorVersion\":\"%SERVICEPACKMAJORVERSION%\", \"ServicePackMinorVersion\":\"%SERVICEPACKMINORVERSION%\", \"SizeStoredInPagingFiles\":\"%SIZESTOREDINPAGINGFILES%\", \"Status\":\"%STATUS%\", \"SuiteMask\":\"%SUITEMASK%\", \"SystemDevice\":\"%SYSTEMDEVICE%\", \"SystemDirectory\":\"%SYSTEMDIRECTORY%\", \"SystemDrive\":\"%SYSTEMDRIVE%\", \"TotalSwapSpaceSize\":\"%TOTALSWAPSPACESIZE%\", \"TotalVirtualMemorySize\":\"%TOTALVIRTUALMEMORYSIZE%\", \"TotalVisibleMemorySize\":\"%TOTALVISIBLEMEMORYSIZE%\", \"Version\":\"%VERSION%\", \"WindowsDirectory\":\"%WINDOWSDIRECTORY%\", \"IP_Config\":\"%IP_CONFIG%\", \"PhysicalAddress\":\"%PHYSICALADDRESS%\", \"SubnetMask\":\"%SUBNETMASK%\", \"MACAddress\":\"%MACADDRESS%\", \"TransportName\":\"%TRANSPORTNAME%\", \"FullName\":\"%USERNAME%\", \"NIK\":\"%NIK%\"}"
SET "JSON={\"BootDevice\":\"%BOOTDEVICE%\", \"BuildNumber\":\"%BUILDNUMBER%\", \"BuildType\":\"%BUILDTYPE%\", \"Caption\":\"%CAPTION%\", \"CodeSet\":\"%CODESET%\", \"CountryCode\":\"%COUNTRYCODE%\", \"CreationClassName\":\"%CREATIONCLASSNAME%\", \"CSCreationClassName\":\"%CSCREATIONCLASSNAME%\", \"CSDVersion\":\"%CSDVERSION%\", \"CSName\":\"%CSNAME%\", \"CurrentTimeZone\":\"%CURRENTTIMEZONE%\", \"DataExecutionPrevention_32BitApplications\":\"%DATAEXECUTIONPREVENTION_32BITAPPLICATIONS%\", \"DataExecutionPrevention_Available\":\"%DATAEXECUTIONPREVENTION_AVAILABLE%\", \"DataExecutionPrevention_Drivers\":\"%DATAEXECUTIONPREVENTION_DRIVERS%\", \"FreeVirtualMemory\":\"%FREEVIRTUALMEMORY%\", \"InstallDate\":\"%INSTALLDATE%\", \"LargeSystemCache\":\"%LARGESYSTEMCACHE%\", \"LastBootUpTime\":\"%LASTBOOTUPTIME%\", \"LargeSystemCache\":\"%LargeSystemCache%\", \"LocalDateTime\":\"%LOCALDATETIME%\", \"Locale\":\"%LOCALE%\", \"Manufacturer\":\"%MANUFACTURER%\", \"MaxNumberOfProcesses\":\"%MAXNUMBEROFPROCESSES%\", \"MaxProcessMemorySize\":\"%MAXPROCESSMEMORYSIZE%\", \"MUILanguages\":\"%MUILANGUAGES%\", \"NumberOfLicensedUsers\":\"%NUMBEROFLICENSEDUSERS%\", \"NumberOfProcesses\":\"%NUMBEROFPROCESSES%\", \"NumberOfUsers\":\"%NUMBEROFUSERS%\", \"OperatingSystemSKU\":\"%OPERATINGSYSTEMSKU%\", \"Organization\":\"%ORGANIZATION%\", \"OSArchitecture\":\"%OSARCHITECTURE%\", \"OSLanguage\":\"%OSLANGUAGE%\", \"OSProductSuite\":\"%OSPRODUCTSUITE%\", \"OSType\":\"%OSTYPE%\", \"OtherTypeDescription\":\"%OTHERTYPEDESCRIPTION%\", \"PAEEnabled\":\"%PAEENABLED%\", \"PlusProductID\":\"%PLUSPRODUCTID%\", \"PlusVersionNumber\":\"%PLUSVERSIONNUMBER%\", \"PortableOperatingSystem\":\"%PORTABLEOPERATINGSYSTEM%\", \"Primary\":\"%PRIMARY%\", \"ProductType\":\"%PRODUCTTYPE%\", \"RegisteredUser\":\"%REGISTEREDUSER%\", \"SerialNumber\":\"%SERIALNUMBER%\", \"ServicePackMajorVersion\":\"%SERVICEPACKMAJORVERSION%\", \"ServicePackMinorVersion\":\"%SERVICEPACKMINORVERSION%\", \"SizeStoredInPagingFiles\":\"%SIZESTOREDINPAGINGFILES%\", \"Status\":\"%STATUS%\", \"SuiteMask\":\"%SUITEMASK%\", \"SystemDevice\":\"%SYSTEMDEVICE%\", \"SystemDirectory\":\"%SYSTEMDIRECTORY%\", \"SystemDrive\":\"%SYSTEMDRIVE%\", \"TotalSwapSpaceSize\":\"%TOTALSWAPSPACESIZE%\", \"TotalVirtualMemorySize\":\"%TOTALVIRTUALMEMORYSIZE%\", \"TotalVisibleMemorySize\":\"%TOTALVISIBLEMEMORYSIZE%\", \"Version\":\"%VERSION%\", \"WindowsDirectory\":\"%WINDOWSDIRECTORY%\", \"IP_Config\":\"%IP_CONFIG%\", \"MACAddress\":\"%MACADDRESS%\", \"FullName\":\"%USERNAME%\", \"NIK\":\"%NIK%\"}"

cls

echo Dump into server...

curl -X POST --location %url% -k --header "%headers%" --header "%token%" -d "%JSON%"

echo .
echo Cleaning workplace...

del %currentPath%dumper.bat

endlocal

timeout /t 10