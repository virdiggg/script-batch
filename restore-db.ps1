#requires -Version 5.1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$defaultDb = "mysql"
$defaultUserMysql = "root"
$defaultUserSqlserver = "sa"
$defaultHost = "localhost"
$defaultFolderMysql = "D:\dump\db\mysql"
$defaultFolderSqlserver = "D:\dump\db\sqlserver"
$restoreDir = Join-Path -Path $defaultFolderSqlserver -ChildPath "temp"

Write-Warning "Make sure .sql for mysql and .bak for sqlserver is in different folder"

$userInputDb = Read-Host -Prompt "Enter your database type (mysql or sqlserver) (Default: [$defaultDb])"
if ([string]::IsNullOrWhiteSpace($userInputDb)) {
    $targetDb = $defaultDb
}
elseif ($userInputDb -eq "mysql" -or $userInputDb -eq "sqlserver") {
    $targetDb = $userInputDb
}
else {
    Write-Host "Invalid database type. Using default: $defaultDb"
    $targetDb = $defaultDb
}

if ($targetDb -eq "mysql") {
    $defUserInputDb = $defaultUserMysql
}
else {
    $defUserInputDb = $defaultUserSqlserver
}
$userInputUser = Read-Host -Prompt "Enter your database user (Default: [$defUserInputDb])"

if ([string]::IsNullOrWhiteSpace($userInputUser)) {
    if ($targetDb -eq "mysql") {
        $userDb = $defaultUserMysql
    }
    else {
        $userDb = $defaultUserSqlserver
    }
}
else {
    $userDb = $userInputUser
}

$userInputPass = Read-Host -Prompt "Enter your database pass (Leave blank if no password)"
$passDb = $userInputPass

if ($targetDb -eq "mysql") {
    $defUserInputFolder = $defaultFolderMysql
}
else {
    $defUserInputFolder = $defaultFolderSqlserver
}
$userInputUser = Read-Host -Prompt "Enter your .sql folder (Default: [$defUserInputFolder])"

if ([string]::IsNullOrWhiteSpace($userInputFolder)) {
    if ($targetDb -eq "mysql") {
        $targetFolder = $defaultFolderMysql
    }
    else {
        $targetFolder = $defaultFolderSqlserver
    }
}
else {
    $targetFolder = $userInputFolder
}

if (-not (Test-Path $targetFolder)) {
    Write-Error "Target folder does not exist: $targetFolder"
    return
}

Write-Output "Configuration:"
Write-Output "  Database: $targetDb"
Write-Output "  User DB: $userDb"
Write-Output "  Target Folder: $targetFolder"
Write-Output ""

function Check-Tool {
    param($Tool)

    $cmd = Get-Command $Tool -ErrorAction SilentlyContinue
    if ($cmd) {
        Write-Output "[OK] Found $Tool in PATH: $($cmd.Source)"
        return
    }

    Write-Warning "$Tool not found in PATH. Trying fallback locations..."

    $fallbacks = @()

    switch ($Tool.ToLower()) {
        "7z" {
            $fallbacks = @(
                "C:\Program Files\7-Zip",
                "C:\Program Files (x86)\7-Zip"
            )
        }

        "mysql" {
            # Laragon fallback (C: and D:)
            foreach ($drive in @("C:", "D:")) {
                $laragonRoot = Join-Path "$drive\" "laragon\bin\mysql"
                if (Test-Path $laragonRoot) {
                    $versionDirs = Get-ChildItem -Path $laragonRoot -Directory -Filter "mysql*" -ErrorAction SilentlyContinue |
                    Sort-Object { ($_ -replace 'mysql-', '') -as [version] } -Descending
                    foreach ($verDir in $versionDirs) {
                        $binPath = Join-Path $verDir.FullName "bin"
                        if (Test-Path (Join-Path $binPath "$Tool.exe")) {
                            $fallbacks += $binPath
                            break
                        }
                    }
                }

                # XAMPP fallback
                $xamppPath = Join-Path "$drive\" "xampp\mysql\bin"
                if (Test-Path (Join-Path $xamppPath "$Tool.exe")) {
                    $fallbacks += $xamppPath
                }
            }
        }

        "sqlcmd" {
            $sqlDirs = @(
                "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC",
                "C:\Program Files\Microsoft SQL Server"
            )
            foreach ($basePath in $sqlDirs) {
                if (Test-Path $basePath) {
                    $foundDirs = Get-ChildItem -Path $basePath -Directory -Recurse -ErrorAction SilentlyContinue |
                    Where-Object { $_.FullName -like "*Tools\Binn" -and (Test-Path (Join-Path $_.FullName "$Tool.exe")) }
                    foreach ($match in $foundDirs) {
                        $fallbacks += $match.FullName
                    }
                }
            }
        }
    }

    foreach ($binDir in $fallbacks | Select-Object -Unique) {
        if (-not ($env:PATH -like "*$binDir*")) {
            $env:PATH += ";$binDir"
        }

        $check = Get-Command $Tool -ErrorAction SilentlyContinue
        if ($check) {
            Write-Output "[OK] Found $Tool in fallback: $binDir"
            return
        }
    }

    Write-Error "[X] $Tool not found in PATH or fallback locations. Please install or add to PATH."
    return
}

foreach ($tool in @("7z", "gzip", "mysql", "mysqladmin", "sqlcmd")) {
    Check-Tool $tool
}

# Ekstrak semua file.zip, kalo ada
Write-Output "[>] Mengekstrak semua .zip di $targetFolder"
Get-ChildItem -Path $targetFolder -Filter *.zip -Recurse | ForEach-Object {
    $zipFile = $_.FullName
    $outputDir = "$($_.Directory.FullName)\extracted"
    $result = & 7z x "$zipFile" "-o$outputDir" -aoa 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Output "[OK] Ekstrak ZIP: $($_.Name)"
    }
    else {
        Write-Warning "[X] Gagal ekstrak ZIP: $($_.Name) → $result"
    }
}

# Ekstrak semua file .gz, kalo ada
Write-Output "[>] Mengekstrak semua .gz di $targetFolder"
Get-ChildItem -Path $targetFolder -Filter *.gz -Recurse | ForEach-Object {
    $gzFile = $_.FullName
    $result = & gzip -d -f "$gzFile" 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Output "[OK] Ekstrak GZ: $($_.Name)"
    }
    else {
        Write-Warning "[X] Gagal ekstrak GZ: $($_.Name) === $result"
    }
}

if ($targetDb -eq "sqlserver") {
    # Temp file SQL Server
    $restoreDir = Join-Path -Path $targetFolder -ChildPath "temp"

    # Rename semua file .bak biar gampang dibaca
    Write-Output "[>] Rename dan Restore semua file .bak"
    Get-ChildItem -Path $targetFolder -Recurse -Filter *.bak | ForEach-Object {
        $originalFile = $_
        $originalPath = $originalFile.FullName
        $originalName = $originalFile.BaseName

        # Cuma hapus format date sama tulisan backup
        $dbName = $originalName -replace "_backup_\d{4}_\d{2}_\d{2}_\d{6}(_\d+)?$", "" -replace "_\d{4}_\d{2}_\d{2}_\d{6}(_\d+)?$", ""

        $renamedBak = Join-Path -Path $originalFile.Directory.FullName -ChildPath "$dbName.bak"

        if ($originalPath -ne $renamedBak) {
            try {
                Rename-Item -Path $originalPath -NewName "$dbName.bak" -Force
                Write-Output "[OK] Rename: $($originalFile.Name) -> $dbName.bak"
            }
            catch {
                Write-Warning "[X] Gagal Rename $($originalFile.Name): $_"
                return
            }
        }
    }

    # Restore .bak ke SQL Server 2008
    Get-ChildItem -Path $targetFolder -Recurse -Filter *.bak | ForEach-Object {
        $bakFile = $_.FullName
        $dbName = $_.BaseName

        Write-Output "[>] Proses DB: $dbName dari file: $($_.Name)"

        # DROP db dulu kalo ada
        $dropCmd = "IF EXISTS (SELECT name FROM sys.databases WHERE name = N'$dbName') BEGIN ALTER DATABASE [$dbName] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [$dbName]; END;"
        $dropResult = & sqlcmd -S $defaultHost -U $userDb -P $passDb -Q "$dropCmd" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Output "[OK] DROP ${dbName}: berhasil"
        }
        else {
            Write-Warning "[X] Gagal DROP ${dbName}: ${dropResult}"
        }

        # Cek Logical Name dalam metadata file
        $fileListRaw = & sqlcmd -S $defaultHost -U $userDb -P $passDb -Q "RESTORE FILELISTONLY FROM DISK = N'$bakFile'" -s "|" -W 2>&1
        if ($LASTEXITCODE -ne 0 -or -not ($fileListRaw -match "LogicalName")) {
            Write-Warning "[X] Tidak bisa baca struktur .bak: $($_.Name)"
            return
        }

        # Ambil data yang dibutuhkan untuk restore
        $lines = $fileListRaw | Where-Object { $_ -match "\|" }
        $header = ($lines | Select-Object -First 1) -split "\|"
        $data = ($lines | Select-Object -Skip 1 | ConvertFrom-Csv -Delimiter "|" -Header $header)

        $mdfRow = $data | Where-Object { $_.Type -eq 'D' } | Select-Object -First 1
        $ldfRow = $data | Where-Object { $_.Type -eq 'L' } | Select-Object -First 1

        $mdfLogical = $mdfRow.LogicalName.Trim()
        $ldfLogical = $ldfRow.LogicalName.Trim()

        # Metadata db yang di-restore nanti di-copy ke $restoreDir
        New-Item -ItemType Directory -Path $restoreDir -Force | Out-Null

        # Metadata yang dipake pas restore
        $mdfPath = Join-Path $restoreDir "$dbName.mdf"
        $ldfPath = Join-Path $restoreDir "$dbName.ldf"

        # Eksekusi query restore
        $restoreQuery = "RESTORE DATABASE [$dbName] FROM DISK = N'$bakFile' WITH MOVE N'$mdfLogical' TO N'$mdfPath', MOVE N'$ldfLogical' TO N'$ldfPath', REPLACE, STATS = 5"
        $restoreResult = & sqlcmd -S $defaultHost -U $userDb -P $passDb -Q "$restoreQuery" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Output "[OK] RESTORE ${dbName}: berhasil"
        }
        else {
            Write-Warning "[X] Gagal RESTORE ${dbName}: ${restoreResult}"
        }
    }
}

if ($targetDb -eq "mysql") {
    # List db yang di-drop
    $dbList = @(
        "chicco-test", "db_action_plan", "db_aset_v3", "db_expenses", "db_marketing2", "db_mitra", "mitra",
        "db_registrasi", "ememes", "healty_report", "plat_kendaraan", "sso7", "riaden", "riadene", "legalitas-makloon"
    )

    # Drop db, terus buat lagi
    foreach ($db in $dbList) {
        # Drop DB
        $dropResult = & mysql -u $userDb -p"$passDb" -h $defaultHost -e "DROP DATABASE IF EXISTS ``${db}``;" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Output "[OK] DROP ${db}: berhasil"
        }
        else {
            Write-Warning "[X] Gagal DROP ${db}: ${dropResult}"
        }

        # Create DB
        $createResult = & mysql -u $userDb -p"$passDb" -h $defaultHost -e "CREATE DATABASE ``${db}``;" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Output "[OK] CREATE ${db}: berhasil"
        }
        else {
            Write-Warning "[X] Gagal CREATE ${db}: ${createResult}"
        }
    }

    # Import file .sql ke db
    Write-Output "[>] Import semua file .sql"
    Get-ChildItem -Path $targetFolder -Recurse -Filter *.sql | ForEach-Object {
        $sqlFile = $_.FullName
        $fileName = $_.BaseName
        $cleanSqlPath = "$sqlFile.cleaned.sql"

        $content = Get-Content -Raw -Path $sqlFile

        # Cek dulu file .sql ada line NO_AUTO_CREATE_USER apa enggak
        # kalo ada, maka hapus line-nya, terus buat file .cleaned.sql
        # Karena ini line dari MySQL versi lama, kalo diimpor ke MySQL baru, jadi gak bisa
        if ($content -match "NO_AUTO_CREATE_USER") {
            Write-Output "[!] Found NO_AUTO_CREATE_USER in $($_.Name), cleaning..."
            $cleaned = $content -replace "NO_AUTO_CREATE_USER,?", ""
            $cleaned | Set-Content -Path $cleanSqlPath
            $finalSqlFile = $cleanSqlPath
        }
        else {
            $finalSqlFile = $sqlFile
        }

        # Hapus format date dari nama file
        $dbName = $fileName -replace "_\d{8}_\d{6}$", ""

        Write-Output "[>] Import ke DB: $dbName dari $($_.Name)"
        Get-Content -Raw -Path $finalSqlFile | & mysql -u $userDb -p"$passDb" -h $defaultHost $dbName

        # Kalo ada file .cleaned.sql, hapus
        if (Test-Path $cleanSqlPath) {
            Remove-Item -Path $cleanSqlPath -Force -ErrorAction SilentlyContinue
        }
    }
}

Write-Output "[OK] Database restoration completed! [$targetDb] [$defaultHost] [$targetFolder]"
