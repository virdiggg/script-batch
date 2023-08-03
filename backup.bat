@ECHO OFF

@REM Dump db PostgreSQL dari remote server ke lokal, dalam ekstensi .tar.gz

SET HOUR=%time:~0,2%
SET TODAY=%date:~-4%%date:~4,2%%date:~7,2%
SET dtStamp9=%TODAY%_0%time:~1,1%%time:~3,2%%time:~6,2%
SET dtStamp24=%TODAY%_%time:~0,2%%time:~3,2%%time:~6,2%

if "%HOUR:~0,1%" == " " (SET dtStamp=%dtStamp9%) else (SET dtStamp=%dtStamp24%)

@REM ECHO DateTime
ECHO %dtStamp%

SET tarname=your_db_name_latest.tar
SET "tarnameStamp=your_db_name_%dtStamp%.tar"

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

ECHO Create "%tarname%.gz"
@REM Kalo gak ada .pgpass
plink -batch %userServ%@%ipServ% -pwfile %passServ% "PGPASSWORD=your_db_password /usr/pgsql-13/bin/pg_dump -h %ipDB% -p %portDB% -F t -U %ownerDB% your_db_name | gzip -9 > /home/%tarname%.gz"
@REM Kalo pake private key
plink -batch %userServ%@%ipServ% -i %keyServ% "PGPASSWORD=your_db_password /usr/pgsql-13/bin/pg_dump -h %ipDB% -p %portDB% -F t -U %ownerDB% your_db_name | gzip -9 > /home/%tarname%.gz"
@REM Kalo ada .pgpass
plink -batch %userServ%@%ipServ% -pwfile %passServ% "/usr/pgsql-13/bin/pg_dump -h %ipDB% -p %portDB% -F t -U %ownerDB% your_db_name | gzip -9 > /home/%tarname%.gz"

ECHO Create folder %TODAY%
if not exist "D:\dump\db\your_db_name\%TODAY%" (
    mkdir D:\dump\db\your_db_name\%TODAY%
) else (
    ECHO Folder %TODAY% already exists
)

ECHO Download "%tarnameStamp%.gz"
pscp -P 22 -pwfile %passServ% %userServ%@%ipServ%:/home/%tarname%.gz D:\dump\db\your_db_name\%TODAY%\%tarnameStamp%.gz

ECHO Selesai
TIMEOUT /t 1
@REM @PAUSE