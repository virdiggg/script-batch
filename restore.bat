@echo off

set "tarFile=%~1"
set "tarFilename=%~n1"
set "extension=%tarFile:~-7%"

@REM Restore db PostgreSQL dari lokal ke remote server, file di-upload dalam ekstensi .tar.gz

if not exist "%tarFile%" (
    echo File does not exist: "%tarFile%"
    @pause
    exit /b
)

@REM echo Dragged file: "%tarFile%"
@REM echo File Name: %tarFilename%
@REM echo extension: "%extension%"

set HOUR=%time:~0,2%
set dtStamp9=%date:~-4%%date:~4,2%%date:~7,2%_0%time:~1,1%%time:~3,2%%time:~6,2%
set dtStamp24=%date:~-4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%

if "%HOUR:~0,1%" == " " (set dtStamp=%dtStamp9%) else (set dtStamp=%dtStamp24%)

@REM echo DateTime: %dtStamp%

set "filename=your_db_name_%dtStamp%.sql"
set "backupfileWOExt=your_db_name_%dtStamp%"
set "backupfile=%backupfileWOExt%%extension%"

@REM Remote server user
SET userServ=
@REM Plain text
SET passServ=D:\dump\KEY\password.txt
@REM Private key
SET keyServ=D:\dump\KEY\password.ppk
@REM Remote server host
SET ipServ=

SET ownerDB=postgres
SET portDB=5432
@REM Remote server host, bisa beda server sama remote erver-nya
SET ipDB=

if not "%extension%"==".tar.gz" (
    echo The file does not have a .tar.gz extension.
    @pause
    exit /b
)

echo Upload "%backupfileWOExt%%extension%" to CentOS

@REM Kalo pake plain text
pscp -P 22 -pwfile %passServ% %tarFile% %userServ%@%ipServ%:/home/%backupfile%
@REM Kalo pake private key
pscp -P 22 -i %keyServ% %tarFile% %userServ%@%ipServ%:/home/%backupfile%

echo Create New Database "db_restore%dtStamp%"
@REM Kalo gak ada .pgpass
plink -batch %userServ%@%ipServ% -pwfile %passServ% "PGPASSWORD=your_db_password /usr/pgsql-13/bin/psql -h %ipDB% -p %portDB% -U %ownerDB% -c """CREATE DATABASE db_restore%dtStamp% WITH OWNER %ownerDB%""""
@REM Kalo ada .pgpass
plink -batch %userServ%@%ipServ% -pwfile %passServ% "/usr/pgsql-13/bin/psql -h %ipDB% -p %portDB% -U %ownerDB% -c """CREATE DATABASE db_restore%dtStamp% WITH OWNER %ownerDB%""""

echo Extract "%backupfileWOExt%%extension%" to "%backupfileWOExt%.tar"
plink -batch %userServ%@%ipServ% -pwfile %passServ% "gzip -d -q -f /home/%backupfile%"

echo Restore SQL "%backupfileWOExt%.tar" to "db_restore%dtStamp%"
@REM Kalo gak ada .pgpass
plink -batch %userServ%@%ipServ% -pwfile %passServ% "PGPASSWORD=your_db_password /usr/pgsql-13/bin/pg_restore -h %ipDB% -p %portDB% -U %ownerDB% -Ft -d db_restore%dtStamp% < /home/%backupfileWOExt%.tar"
@REM Kalo ada .pgpass
plink -batch %userServ%@%ipServ% -pwfile %passServ% "/usr/pgsql-13/bin/pg_restore -h %ipDB% -p %portDB% -U %ownerDB% -Ft -d db_restore%dtStamp% < /home/%backupfileWOExt%.tar"

echo Delete file "%backupfileWOExt%.tar"
plink -batch %userServ%@%ipServ% -pwfile %passServ% "rm -rf /home/%backupfileWOExt%.tar"

echo Finish
@pause
exit /b