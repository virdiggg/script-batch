@echo off

@REM Scan port website dengan IP-nya, simpan result-nya ke file .log

@REM Timeout 0.001 detik
SET CURL_TIMEOUT="0.001"
@REM IP Server
SET IPServer="http://"
SET output=D:\dump\output_scan.log

for /l %%x in (1, 1, 65535) do (
	curl -X GET --connect-timeout %CURL_TIMEOUT% "%IPServer%:%%x"
	if errorlevel 28 (
		echo "Curl timed out. Port %%x" >> %output%
	) else (
		echo "Curl completed successfully. Port %%x" >> %output%
	)
)

echo "Header:" >> %output%
curl -I --connect-timeout %CURL_TIMEOUT% "%IPServer%" >> %output%
@REM curl -v -L -X HEAD --connect-timeout %CURL_TIMEOUT% "%IPServer%" >> %output%
@pause
