@echo off

@REM Scan Vulnerable Website

SET website=""
SET websiteWHost="https://%website%"
SET output=D:\dump\output.log

echo Scanning Web %website%

@REM Cek detail website
nuclei -u %website%
@REM Cek subdomain website
subfinder -d %website%
@REM Cek open port
naabu -host %website%
@REM Cek DNS
subfinder -silent -d %website% | dnsx -silent -a -resp

@pause