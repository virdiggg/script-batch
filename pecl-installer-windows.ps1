#requires -Version 5.1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Info($msg)  { Write-Host "[>] $msg" -ForegroundColor Cyan }
function Ok($msg)    { Write-Host "[OK] $msg" -ForegroundColor Green }
function Warn($msg)  { Write-Host "[!] $msg" -ForegroundColor Yellow }
function Err($msg)   { Write-Host "[X] $msg" -ForegroundColor Red }
function Blank($msg) { Write-Host "$msg" }

function Ensure-Elevated {
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    if (-not $isAdmin) {
        Warn "Requesting administrative privileges..."
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = (Get-Process -Id $PID).Path
        $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        $psi.Verb = "runas"
        try {
            [System.Diagnostics.Process]::Start($psi) | Out-Null
            Ok "Launched elevated process. (Original session remains open.)"
        } catch {
            Err "Failed to elevate: $_"
        }
        return
    } else {
        Info "Already running as Administrator."
    }
}


function Relaunch-Elevated {
    Info "Relaunching elevated..."
    $scriptBlock = (Get-Content -Raw -Path $PSCommandPath -ErrorAction SilentlyContinue)
    if (-not $scriptBlock) {
        try {
            Start-Process -FilePath "powershell" -ArgumentList "-NoProfile","-ExecutionPolicy","Bypass","-Command","& { $([ScriptBlock]::Create((Get-Content -Raw -Path $MyInvocation.MyCommand.Definition))) }" -Verb RunAs
            Ok "Elevated session started (from iex flow). Original session remains open."
        } catch {
            Err "Failed to start elevated session (iex path): $_"
        }
        return
    } else {
        try {
            Start-Process -FilePath "powershell" -ArgumentList "-NoProfile","-ExecutionPolicy","Bypass","-File",$PSCommandPath -Verb RunAs
            Ok "Elevated session started. Original session remains open."
        } catch {
            Err "Failed to start elevated session (file path): $_"
        }
        return
    }
}

if ($PSCommandPath) {
    Ensure-Elevated
} else {
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    if (-not $isAdmin) {
        Warn "This session was started with iex and cannot auto-elevate reliably."
        Warn "Please run PowerShell as Administrator and execute the command again:"
        Info "  irm <url-to-script.ps1> | iex"
        return
    }
}

try {
    Write-Host ""
    Info "=== PECL/PEAR Installer for Windows (PowerShell) ==="

    $phpPath = Read-Host "Copy your PHP installation path (e.g. C:\php or C:\tools\php)"
    if ([string]::IsNullOrWhiteSpace($phpPath)) {
        Err "PHP Path is empty. Cancelling installation."
        throw "Installation failed: empty PHP path."
    }

    $phpPath = $phpPath.TrimEnd('\','/')

    if (-not (Test-Path -Path $phpPath -PathType Container)) {
        Err "Invalid PHP path: $phpPath"
        throw "Installation failed: invalid PHP path."
    }

    $phpExe = Join-Path $phpPath "php.exe"
    if (-not (Test-Path -Path $phpExe -PathType Leaf)) {
        Err "php.exe not found in $phpPath. Make sure you've provided the correct PHP installation path."
        throw "Installation failed: php.exe not found."
    }

    Ok "PHP found: $phpExe"

    $env:PATH = "$phpPath;$env:PATH"
    Info "Added PHP path to current session PATH."

    try {
        $currentUserPath = [Environment]::GetEnvironmentVariable("PATH","User")
        if (-not ($currentUserPath -split ';' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ieq $phpPath })) {
            $newUserPath = if ([string]::IsNullOrEmpty($currentUserPath)) { $phpPath } else { "$currentUserPath;$phpPath" }
            [Environment]::SetEnvironmentVariable("PATH",$newUserPath,"User")
            Ok "Added PHP path to USER environment PATH. You may need to re-open shells for it to take effect."
        } else {
            Info "PHP path already exists in USER PATH."
        }
    } catch {
        Warn "Failed to update user PATH: $_"
    }

    Push-Location -Path $phpPath

    function Ensure-File {
        param(
            [string]$Url,
            [string]$OutFile
        )
        if (-not (Test-Path -Path $OutFile)) {
            Info "Downloading $OutFile ..."
            try {
                Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing -ErrorAction Stop
                Ok "Downloaded $OutFile"
            } catch {
                Err "Failed to download $Url : $_"
                throw
            }
        } else {
            Info "$OutFile already exists, skipping download."
        }
    }

    Ensure-File -Url "https://raw.githubusercontent.com/pear/pear-core/refs/heads/master/scripts/peclcmd.php" -OutFile "peclcmd.php"
    Ensure-File -Url "https://raw.githubusercontent.com/pear/pear-core/refs/heads/master/scripts/pearcmd.php" -OutFile "pearcmd.php"
    Ensure-File -Url "https://pear.php.net/go-pear.phar" -OutFile "go-pear.phar"

    $peclBatPath = Join-Path $phpPath "pecl.bat"
    if (-not (Test-Path -Path $peclBatPath)) {
        Info "Creating pecl.bat..."
        $lines = @(
            '@echo off'
            'set PHP_PEAR_PHP_BIN=php.exe'
            "set PHP_PEAR_INSTALL_DIR=$phpPath\"
            'php "%PHP_PEAR_INSTALL_DIR%peclcmd.php" %*'
        )
        try {
            $lines | Set-Content -Path $peclBatPath -Encoding ASCII
            Ok "Created $peclBatPath"
        } catch {
            Warn "Failed to create $peclBatPath : $_"
        }
    } else {
        Info "pecl.bat exists, skipping creation."
    }

    Info "Running: php go-pear.phar"

    if (Get-Command refreshenv -ErrorAction SilentlyContinue) {
        Ok "refreshenv available, running it..."
        try {
            if ($env:ChocolateyInstall) {
                Import-Module ($env:ChocolateyInstall + "\helpers\chocolateyProfile.psm1") -ErrorAction SilentlyContinue
            }
        } catch {
            Warn "Could not import chocolatey helpers: $_"
        }

        try {
            refreshenv
            & php "go-pear.phar"
            if ($LASTEXITCODE -ne 0) {
                Warn "php go-pear.phar returned exit code $LASTEXITCODE"
            } else {
                Ok "Completed go-pear.phar"
            }
        } catch {
            Err "Failed to run go-pear.phar with refreshenv: $_"
        }
    } else {
        Warn "refreshenv not found, falling back to full path..."
        try {
            & $phpExe "go-pear.phar"
            if ($LASTEXITCODE -ne 0) {
                Warn "php go-pear.phar returned exit code $LASTEXITCODE"
            } else {
                Ok "Completed go-pear.phar"
            }
        } catch {
            Err "Failed to run go-pear.phar: $_"
        }
    }

    Pop-Location

    Ok "Finished. If you need to use pecl from new shells, open a new PowerShell/CMD window."
} catch {
    Err "Unhandled error: $_"
}
