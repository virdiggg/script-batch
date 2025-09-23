#requires -Version 5.1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- Elevation helper ---
function Ensure-Elevated {
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Host "Requesting administrative privileges..." -ForegroundColor Yellow
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = (Get-Process -Id $PID).Path
        $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        $psi.Verb = "runas"
        try {
            [System.Diagnostics.Process]::Start($psi) | Out-Null
        } catch {
            Write-Error "Failed to elevate. Exiting."
        }
        Exit 0
    }
}

# If running via iex the $PSCommandPath may be empty. Handle that by re-launching current script block.
function Relaunch-Elevated {
    Write-Host "Relaunching elevated..." -ForegroundColor Yellow
    $scriptBlock = (Get-Content -Raw -Path $PSCommandPath -ErrorAction SilentlyContinue)
    if (-not $scriptBlock) {
        # Running from pipeline (iex). Reconstruct command to re-run this session elevated.
        $cmd = "powershell -NoProfile -ExecutionPolicy Bypass -Command `"& { $(Get-Content -Raw -Path $MyInvocation.MyCommand.Definition) }`""
        Start-Process -FilePath "powershell" -ArgumentList "-NoProfile","-ExecutionPolicy","Bypass","-Command","& { $([ScriptBlock]::Create((Get-Content -Raw -Path $MyInvocation.MyCommand.Definition))) }" -Verb RunAs
        Exit 0
    } else {
        Start-Process -FilePath "powershell" -ArgumentList "-NoProfile","-ExecutionPolicy","Bypass","-File",$PSCommandPath -Verb RunAs
        Exit 0
    }
}

# Prefer simple elevation approach: if script file path is unknown (iex), ask user to re-run elevated manually.
if ($PSCommandPath) {
    Ensure-Elevated
} else {
    # Running via iex (no PSCommandPath). If not elevated, attempt to relaunch interactive elevated prompt that runs a copy.
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Host "This session was started with iex and cannot auto-elevate reliably." -ForegroundColor Yellow
        Write-Host "Please run PowerShell as Administrator and execute the command again:" -ForegroundColor Yellow
        Write-Host "  irm <url-to-script.ps1> | iex" -ForegroundColor Cyan
        Exit 1
    }
}

# --- Main ---
try {
    Write-Host ""
    Write-Host "=== PECL/PEAR Installer for Windows (PowerShell) ===" -ForegroundColor Cyan

    # Prompt for PHP path
    $phpPath = Read-Host "Copy your PHP installation path (e.g. C:\php or C:\tools\php)"
    if ([string]::IsNullOrWhiteSpace($phpPath)) {
        Write-Error "PHP Path is empty. Cancelling installation."
        exit 1
    }

    # Normalize path (remove trailing slash)
    $phpPath = $phpPath.TrimEnd('\','/')

    if (-not (Test-Path -Path $phpPath -PathType Container)) {
        Write-Error "Invalid PHP path: $phpPath"
        exit 1
    }

    # Locate php.exe
    $phpExe = Join-Path $phpPath "php.exe"
    if (-not (Test-Path -Path $phpExe -PathType Leaf)) {
        Write-Error "php.exe not found in $phpPath. Make sure you've provided the correct PHP installation path."
        exit 1
    }

    Write-Host "PHP found: $phpExe" -ForegroundColor Green

    # Add to current PATH for this session
    $env:PATH = "$phpPath;$env:PATH"
    Write-Host "Added PHP path to current session PATH."

    # Persist to USER PATH (so future shells see it)
    try {
        $currentUserPath = [Environment]::GetEnvironmentVariable("PATH","User")
        if (-not ($currentUserPath -split ';' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ieq $phpPath })) {
            $newUserPath = if ([string]::IsNullOrEmpty($currentUserPath)) { $phpPath } else { "$currentUserPath;$phpPath" }
            [Environment]::SetEnvironmentVariable("PATH",$newUserPath,"User")
            Write-Host "Added PHP path to USER environment PATH. You may need to re-open shells for it to take effect." -ForegroundColor Green
        } else {
            Write-Host "PHP path already exists in USER PATH."
        }
    } catch {
        Write-Warning "Failed to update user PATH: $_"
    }

    Push-Location -Path $phpPath

    # Helper to download a file if not present
    function Ensure-File {
        param(
            [string]$Url,
            [string]$OutFile
        )
        if (-not (Test-Path -Path $OutFile)) {
            Write-Host "Downloading $OutFile ..."
            try {
                Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing -ErrorAction Stop
                Write-Host "Downloaded $OutFile" -ForegroundColor Green
            } catch {
                Write-Error "Failed to download $Url : $_"
                throw
            }
        } else {
            Write-Host "$OutFile already exists, skipping download."
        }
    }

    # Download required files
    Ensure-File -Url "https://raw.githubusercontent.com/pear/pear-core/refs/heads/master/scripts/peclcmd.php" -OutFile "peclcmd.php"
    Ensure-File -Url "https://raw.githubusercontent.com/pear/pear-core/refs/heads/master/scripts/pearcmd.php" -OutFile "pearcmd.php"
    Ensure-File -Url "https://pear.php.net/go-pear.phar" -OutFile "go-pear.phar"

    # Create pecl.bat if missing (simple wrapper)
    $peclBatPath = Join-Path $phpPath "pecl.bat"
    if (-not (Test-Path -Path $peclBatPath)) {
        Write-Host "Creating pecl.bat..."
        $lines = @(
            '@echo off'
            'set PHP_PEAR_PHP_BIN=php.exe'
            "set PHP_PEAR_INSTALL_DIR=$phpPath\"
            'php "%PHP_PEAR_INSTALL_DIR%peclcmd.php" %*'
        )
        try {
            $lines | Set-Content -Path $peclBatPath -Encoding ASCII
            Write-Host "Created $peclBatPath" -ForegroundColor Green
        } catch {
            Write-Warning "Failed to create $peclBatPath : $_"
        }
    } else {
        Write-Host "pecl.bat exists, skipping creation."
    }

    # Run go-pear.phar using php
    # Run go-pear.phar and capture all output
    Write-Host "Running: php go-pear.phar (capturing output)" -ForegroundColor Cyan
    try {
        $proc = Start-Process -FilePath $phpExe -ArgumentList "go-pear.phar" -RedirectStandardOutput "$phpPath\pear_install.log" -RedirectStandardError "$phpPath\pear_install.err" -Wait -PassThru
        Write-Host "Process exited with code $($proc.ExitCode)"
        if (Test-Path "$phpPath\pear_install.log") {
            Write-Host "`n--- STDOUT ---" -ForegroundColor Yellow
            Get-Content "$phpPath\pear_install.log" | Out-Host
        }
        if (Test-Path "$phpPath\pear_install.err") {
            Write-Host "`n--- STDERR ---" -ForegroundColor Red
            Get-Content "$phpPath\pear_install.err" | Out-Host
        }
    } catch {
        Write-Error "Failed to run go-pear.phar: $_"
    }

    Pop-Location

    Write-Host "Finished. If you need to use pecl from new shells, open a new PowerShell/CMD window." -ForegroundColor Cyan
    exit 0

} catch {
    Write-Error "Unhandled error: $_"
    exit 1
}
