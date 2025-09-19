# Skrip batch buat back up & restore DB PostgreSQL remote server

## Cara pake **`backup.bat`**
- Double click `backup.bat`
- Tunggu selesai

## Cara pake **`restore.bat`**
- Drag and drop file back up-nya (`file.tar.gz`) ke `restore.bat`
- Tunggu selesai

## Cara pake **`replace_lokal_db.bat`**
- Double click `replace_lokal_db.bat`, pastikan file .sql-nya udah sesuai sama path-nya
- Tunggu selesai

## Cara pake **`ping.bat`**
- Double click `ping.bat`
- Tunggu selesai

## Cara pake **`scan_port.bat`**
- Double click `scan_port.bat`
- Tunggu selesai
- Cek hasilnya di file `output_scan.bat`

## Cara pake **`restore-db.ps1`**
Bisa buat restore DB MySQL dan SQL Server 2008
- Buka `powershell`
- Ketik
```
irm https://raw.githubusercontent.com/virdiggg/script-batch/refs/heads/master/restore-db.ps1 | iex
```
- Ikutin instruksinya
