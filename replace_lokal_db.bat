@echo off

@REM Replace db MySQL di lokal dengan yang baru, git pull, migrate (laravel)

SET passDB=
SET userGit=
SET passGit=
SET hostGit=
SET repoGit=

echo Drop Database "your_db_name" And Create Database "your_db_name"
mysql -u root -p"%passDB%" -e "DROP DATABASE your_db_name; CREATE DATABASE your_db_name"

@REM echo Create Database "your_db_name"
@REM mysql -u root -p"%passDB%" -e "CREATE DATABASE your_db_name"

echo Import Database "your_db_name.sql"
REM D:\dump\ sesuaiin sama tempat download db-nya di lokal
mysql -u root -p"%passDB%" your_db_name < D:\dump\db\your_db_name.sql

echo Git Pull dan Migrate

cd /d D:\laragon\www\your_project
@REM cd D:\laragon\www\your_project

git pull "https://%userGit%:%passGit%@%hostGit%/%repoGit%.git"

php artisan migrate

echo Selesai
@pause