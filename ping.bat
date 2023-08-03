@ECHO OFF

@REM Buat ping aja ke hosting, kalo timeout berarti gak bisa diakses
@REM Perlu punya aplikasi dan buat webhook-nya buat kirim WA ke orang lain kalo hosting yang di-ping gak bisa diakses

SET notif="https://send-notif-example.com/whatsapp/"

curl -X GET "https://example.com/"

@REM Gak bisa di-ping
if errorlevel 28 (
	curl --location --request GET "%notif%"
) else (
	echo "Server hidup"
)

TIMEOUT /t 1