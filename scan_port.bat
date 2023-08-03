@echo off

@REM Timeout 0.001 detik
SET CURL_TIMEOUT="0.001"
@REM IP Server
SET IPServer="http://"

for /l %%x in (1, 1, 65535) do (
	curl -X GET --connect-timeout %CURL_TIMEOUT% "%IPServer%:%%x"
	if errorlevel 28 (
		echo "Curl timed out. Port %%x" >> output_scan.txt
	) else (
		echo "Curl completed successfully. Port %%x" >> output_scan.txt
	)
)

echo "Header:" >> output_scan.txt
curl -v -L -X HEAD --connect-timeout %CURL_TIMEOUT% "%IPServer%" >> output_scan.txt
@pause