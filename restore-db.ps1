#requires -Version 5.1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Info($msg)  { Write-Host "[>] $msg" -ForegroundColor Cyan }
function Ok($msg)    { Write-Host "[OK] $msg" -ForegroundColor Green }
function Warn($msg)  { Write-Host "[!] $msg" -ForegroundColor Yellow }
function Err($msg)   { Write-Host "[X] $msg" -ForegroundColor Red }

$defaultDb = "mysql"
$defaultUserMysql = "root"
$defaultUserSqlserver = "sa"
$defaultHost = "localhost"
$defaultFolderMysql = "D:\dump\db\mysql"
$defaultFolderSqlserver = "D:\dump\db\sqlserver"
$restoreDir = Join-Path -Path $defaultFolderSqlserver -ChildPath "temp"

Warn "Make sure .sql for mysql and .bak for sqlserver is in different folder"

$userInputDb = Read-Host -Prompt "Enter your database type (mysql or sqlserver) (Default: [$defaultDb])"
if ([string]::IsNullOrWhiteSpace($userInputDb)) {
    $targetDb = $defaultDb
}
elseif ($userInputDb -eq "mysql" -or $userInputDb -eq "sqlserver") {
    $targetDb = $userInputDb
}
else {
    Warn "Invalid database type. Using default: $defaultDb"
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
    $userDb = $defUserInputDb
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
$userInputFolder = Read-Host -Prompt "Enter your .sql folder (Default: [$defUserInputFolder])"

if ([string]::IsNullOrWhiteSpace($userInputFolder)) {
    $targetFolder = $defUserInputFolder
}
else {
    $targetFolder = $userInputFolder
}

if (-not (Test-Path $targetFolder)) {
    Err "Target folder does not exist: $targetFolder"
    return
}

Info "Configuration:"
Info "  Database: $targetDb"
Info "  User DB: $userDb"
Info "  Target Folder: $targetFolder"
Info ""

function Check-Tool {
    param($Tool)

    $cmd = Get-Command $Tool -ErrorAction SilentlyContinue
    if ($cmd) {
        Ok "Found $Tool in PATH: $($cmd.Source)"
        return
    }

    Warn "$Tool not found in PATH. Trying fallback locations..."

    $fallbacks = @()

    switch ($Tool.ToLower()) {
        "7z" {
            $fallbacks = @(
                "C:\Program Files\7-Zip",
                "C:\Program Files (x86)\7-Zip"
            )
            # Check if 7z exists in fallback locations
            $found = $false
            foreach ($binDir in $fallbacks) {
                if (Test-Path (Join-Path $binDir "7z.exe")) {
                    $found = $true
                    break
                }
            }
            # If not found in fallback locations, download and install
            if (-not $found) {
                Ok "7-Zip not found. Downloading and installing..."
                try {
                    $downloadUrl = "https://www.7-zip.org/a/7z2500-x64.exe"
                    $tempFile = Join-Path $env:TEMP "7z2500-x64.exe"

                    # Download 7-Zip installer
                    Ok "Downloading 7-Zip from $downloadUrl"
                    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile -UseBasicParsing

                    # Install 7-Zip silently
                    Ok "Installing 7-Zip..."
                    Start-Process -FilePath $tempFile -ArgumentList "/S" -Wait

                    # Clean up temp file
                    Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue

                    # Add to fallbacks again after installation
                    $fallbacks = @(
                        "C:\Program Files\7-Zip",
                        "C:\Program Files (x86)\7-Zip"
                    )
                    Ok "7-Zip installation completed"
                }
                catch {
                    Err "Failed to download/install 7-Zip: $_"
                }
            }
        }

        "gzip" {
            # Git fallback locations
            $gitDirs = @(
                "C:\Program Files\Git\usr\bin",
                "C:\Program Files (x86)\Git\usr\bin"
            )
            foreach ($drive in @("C:", "D:", "E:")) {
                # Portable Git installations
                $portableGit = Join-Path "$drive\" "PortableGit\usr\bin"
                if (Test-Path $portableGit) {
                    $gitDirs += $portableGit
                }
                # Git installations in other common locations
                $gitRoot = Join-Path "$drive\" "Git\usr\bin"
                if (Test-Path $gitRoot) {
                    $gitDirs += $gitRoot
                }
            }
            foreach ($gitBin in $gitDirs) {
                if (Test-Path (Join-Path $gitBin "$Tool.exe")) {
                    $fallbacks += $gitBin
                }
            }
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
            Ok "Found $Tool in fallback: $binDir"
            return
        }
    }

    Err "$Tool not found in PATH or fallback locations. Please install or add to PATH."
    return
}

foreach ($tool in @("7z", "gzip", "mysql", "mysqladmin", "sqlcmd")) {
    Check-Tool $tool
}

# Ekstrak semua file.zip, kalo ada
Ok "Mengekstrak semua .zip di $targetFolder"
Get-ChildItem -Path $targetFolder -Filter *.zip -Recurse | ForEach-Object {
    $zipFile = $_.FullName
    $outputDir = "$($_.Directory.FullName)\extracted"
    $result = & 7z x "$zipFile" "-o$outputDir" -aoa 2>&1

    if ($LASTEXITCODE -eq 0) {
        Ok "Ekstrak ZIP: $($_.Name)"
    }
    else {
        Err "Gagal ekstrak ZIP: $($_.Name) → $result"
    }
}

# Ekstrak semua file .gz, kalo ada
Ok "Mengekstrak semua .gz di $targetFolder"
Get-ChildItem -Path $targetFolder -Filter *.gz -Recurse | ForEach-Object {
    $gzFile = $_.FullName
    $result = & gzip -d -f "$gzFile" 2>&1

    if ($LASTEXITCODE -eq 0) {
        Ok "Ekstrak GZ: $($_.Name)"
    }
    else {
        Err "Gagal ekstrak GZ: $($_.Name) === $result"
    }
}

if ($targetDb -eq "sqlserver") {
    # Temp file SQL Server
    $restoreDir = Join-Path -Path $targetFolder -ChildPath "temp"

    $sqlserverParams = @("-S", $defaultHost, "-U", $userDb)
    if ($passDb -and $passDb.Trim() -ne "") {
        $sqlserverParams += "-P"
        $sqlserverParams += $passDb
    }

    # Rename semua file .bak biar gampang dibaca
    Ok "Rename dan Restore semua file .bak"
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
                Ok "Rename: $($originalFile.Name) -> $dbName.bak"
            }
            catch {
                Err "Gagal Rename $($originalFile.Name): $_"
                return
            }
        }
    }

    # Restore .bak ke SQL Server 2008
    Get-ChildItem -Path $targetFolder -Recurse -Filter *.bak | ForEach-Object {
        $bakFile = $_.FullName
        $dbName = $_.BaseName

        Ok "Proses DB: $dbName dari file: $($_.Name)"

        # DROP db dulu kalo ada
        $dropCmd = "IF EXISTS (SELECT name FROM sys.databases WHERE name = N'$dbName') BEGIN ALTER DATABASE [$dbName] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [$dbName]; END;"
        $dropResult = & sqlcmd @sqlserverParams -Q "$dropCmd" 2>&1

        if ($LASTEXITCODE -eq 0) {
            Ok "DROP ${dbName}: berhasil"
        }
        else {
            Err "Gagal DROP ${dbName}: ${dropResult}"
        }

        # Cek Logical Name dalam metadata file
        $fileListRaw = & sqlcmd @sqlserverParams -Q "RESTORE FILELISTONLY FROM DISK = N'$bakFile'" -s "|" -W 2>&1
        if ($LASTEXITCODE -ne 0 -or -not ($fileListRaw -match "LogicalName")) {
            Err "Tidak bisa baca struktur .bak: $($_.Name)"
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
        $restoreResult = & sqlcmd @sqlserverParams -Q "$restoreQuery" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Ok "RESTORE ${dbName}: berhasil"
        }
        else {
            Err "Gagal RESTORE ${dbName}: ${restoreResult}"
        }
    }
}

if ($targetDb -eq "mysql") {
    # List db yang di-drop
    $dbList = @(
        "chicco-test", "db_action_plan", "db_aset_v3", "db_expenses", "db_marketing2", "db_mitra", "mitra",
        "db_registrasi", "ememes", "healty_report", "plat_kendaraan", "sso7", "riaden", "riadene", "legalitas-makloon"
    )

    $mysqlParams = @("-u", $userDb, "-h", $defaultHost)
    if ($passDb -and $passDb.Trim() -ne "") {
        $mysqlParams += "-p$passDb"
    }

    # Drop db, terus buat lagi
    foreach ($db in $dbList) {
        # Drop DB
        $dropResult = & mysql @mysqlParams -e "DROP DATABASE IF EXISTS ``${db}``;" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Ok "DROP ${db}: berhasil"
        }
        else {
            Err "Gagal DROP ${db}: ${dropResult}"
        }

        # Create DB
        $createResult = & mysql @mysqlParams -e "CREATE DATABASE ``${db}``;" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Ok "CREATE ${db}: berhasil"
        }
        else {
            Err "Gagal CREATE ${db}: ${createResult}"
        }
    }

    # Import file .sql ke db
    Ok "Import semua file .sql"
    Get-ChildItem -Path $targetFolder -Recurse -Filter *.sql | ForEach-Object {
        $sqlFile = $_.FullName
        $fileName = $_.BaseName
        $cleanSqlPath = "$sqlFile.cleaned.sql"

        $content = Get-Content -Raw -Path $sqlFile

        # Cek dulu file .sql ada line NO_AUTO_CREATE_USER apa enggak
        # kalo ada, maka hapus line-nya, terus buat file .cleaned.sql
        # Karena ini line dari MySQL versi lama, kalo diimpor ke MySQL baru, jadi gak bisa
        if ($content -match "NO_AUTO_CREATE_USER") {
            Warn "Found NO_AUTO_CREATE_USER in $($_.Name), cleaning..."
            $cleaned = $content -replace "NO_AUTO_CREATE_USER,?", ""
            $cleaned | Set-Content -Path $cleanSqlPath
            $finalSqlFile = $cleanSqlPath
        }
        else {
            $finalSqlFile = $sqlFile
        }

        # Hapus format date dari nama file
        $dbName = $fileName -replace "_\d{8}_\d{6}$", ""

        Ok "Import ke DB: $dbName dari $($_.Name)"
        Get-Content -Raw -Path $finalSqlFile | & mysql @mysqlParams $dbName

        # Kalo ada file .cleaned.sql, hapus
        if (Test-Path $cleanSqlPath) {
            Remove-Item -Path $cleanSqlPath -Force -ErrorAction SilentlyContinue
        }
    }
}

Ok "Database restoration completed! [$targetDb] [$defaultHost] [$targetFolder]"

