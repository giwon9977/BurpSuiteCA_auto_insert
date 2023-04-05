:: BurpSuiteCA Auto Insert Script v1.0.0 Made by Nowiz 230213

@echo off
chcp 65001
color 0b
cls

:: 1. 버프슈트 인증서가 현재 경로에 있는지 확인
echo [*] 1. 버프슈트 인증서(*.der)가 현재 경로에 존재하는지 확인 중...

if exist *.der (
	echo [+] 버프 슈트 인증서^(*.der^)가 존재합니다. 프로그램을 계속 진행합니다.
	for /f %%a in ('dir /b *.der') do (
		echo [+] 파일명: %%a
		set BURPCA=%%a
	)
) else (
	echo [-] 버프 슈트 인증서^(*.der^)가 존재하지 않습니다. 프로그램을 종료합니다.
	pause
	exit
)
echo ================================================================


:: 2. OpenSSL 설치 여부 확인
:: C:\Program Files\OpenSSL-Win64\bin\openssl.exe
echo [*] 2. OpenSSL 이 설치되어 있는지 확인 중...

set OPENSSL="C:\Program Files\OpenSSL-Win64\bin\openssl.exe"
if exist %OPENSSL% (
	echo [+] OpenSSL 이 설치되어 있습니다. 프로그램을 계속 진행합니다.
) else (
	echo [-] OpenSSL 이 설치되어 있지 않습니다. 프로그램을 종료합니다.
	pause
	exit
)
echo ================================================================


:: 3. 버프슈트 인증서 공개키 파일(cacert.pem) 생성
:: openssl x509 -inform DER -in *.der -out cacert.pem
echo [*] 3. 버프슈트 인증서 공개키 파일(cacert.pem) 생성 중...

if exist cacert.pem (
	echo [+] 버프슈트 인증서 공개키 파일^(cacert.pem^)이 이미 존재합니다. 삭제 후 재생성합니다.
	del cacert.pem
)

%OPENSSL% x509 -inform DER -in %BURPCA% -out cacert.pem
echo [+] 생성 완료
echo ================================================================


:: 4. 생성된 공개키 파일 해시 확인 후 파일명 변경(cacert.pem -> 9a5ba575.0)
:: openssl x509 -inform PEM -subject_hash_old -in cacert.pem
:: move cacert.pem [hash.0]
echo [*] 4. 생성된 공개키 파일 해시 확인 후 파일명 변경(cacert.pem -^> 9a5ba575.0)

:: 해시 확인 명령어 결과의 맨 첫줄만 PEMHASH 변수에 저장 (PEMHASH=9a5ba575)
for /f %%a in ('%OPENSSL% x509 -inform PEM -subject_hash_old -in cacert.pem') do (
	if not defined PEMHASH set PEMHASH=%%a
)
echo [+] 해시값: %PEMHASH%

if exist %PEMHASH%.0 (
	echo [+] 동일한 이름의 파일^(%PEMHASH%.0^)이 이미 존재합니다. 삭제 후 변경합니다.
	del %PEMHASH%.0
)

move cacert.pem %PEMHASH%.0
echo [+] 변경 완료
echo ================================================================


:: 5. ADB 설치 여부 확인
echo [*] 5. ADB 설치 여부 확인
adb version

:: ADB 프로그램을 찾지 못했으면 ERRORLEVEL 이 9009 으로 설정됨.
if %ERRORLEVEL% == 0 (
	echo [+] ADB 가 설치되어 있습니다. 프로그램을 계속 진행합니다.
) else (
	echo [-] ADB 가 설치되어 있지 않습니다. 환경변수에 adb.exe 가 존재하는 경로를 설정해주세요.
	echo [-] 프로그램을 종료합니다.
	pause
	exit
)
echo ================================================================


:: 6. 안드로이드 기기 연결 여부 확인
echo [*] 6. 안드로이드 기기 연결 여부 확인
adb devices
for /f %%a in ('adb get-state') do set DEVSTATE=%%a
:: 연결되어 있지 않으면 error: no devices/emulators found 출력
:: DEVSTATE 에는 아무것도 저장되지 않음
:: 연결되어 있으면 DEVSTATE=device 저장

if defined DEVSTATE (
	echo [+] 안드로이드 기기가 정상 연결되어 있습니다. 프로그램을 계속 진행합니다.
) else (
	echo [-] 안드로이드 기기가 연결되어 있지 않습니다. 프로그램을 종료합니다.
	pause
	exit
)
echo ================================================================


:: 7. 안드로이드 기기 /sdcard 경로에 인증서 공개키 파일 삽입
:: adb push 9a5ba575.0 /sdcard
echo [*] 7. 안드로이드 기기 /sdcard 경로에 인증서 공개키 파일 삽입
adb push %PEMHASH%.0 /sdcard
adb shell "ls -l /sdcard/%PEMHASH%.0"
echo [+] 파일 삽입 완료

echo ================================================================


:: 8. 안드로이드 인증서 디렉토리 권한 설정 및 인증서 공개키 파일 이동 
:: su 를 사용하기 위해 기기 루팅이 되어 있어야 함.
echo [*] 8. 안드로이드 인증서 디렉토리 권한 설정 및 인증서 공개키 파일 이동
adb shell "su -c 'mount -o rw,remount /system'"
adb shell "su -c 'mv /sdcard/%PEMHASH%.0 /system/etc/security/cacerts'"
adb shell "su -c 'chmod 644 /system/etc/security/cacerts/%PEMHASH%.0'"
adb shell "su -c 'mount -o ro,remount /system'"
adb shell "su -c 'ls -l /system/etc/security/cacerts/%PEMHASH%.0'"
echo [+] 파일 이동 및 권한 설정 완료

echo ================================================================


:: 9. 인증서 설치 완료
echo [*] 9. 인증서 설치를 완료하였습니다.
echo [*] 10초 뒤 프로그램을 종료합니다.
timeout /t 10
pause
