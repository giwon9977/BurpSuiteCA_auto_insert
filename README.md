# BurpSuiteCA Auto Insert Batch Script
- 안드로이드 7.0 버전 이상의 기기에서 BurpSuite 프록시 설정을 하기 위해서 설치해야 하는 인증서(CA)를 자동으로 기기에 넣어주는 배치 스크립트입니다.
- 아래 필독사항대로 환경구성이 되어 있어야 정상 동작합니다.

## ** 필독 **
1. `BurpSuite - Proxy - Proxy settings - Import/export CA certificate - [Export] Certificate in DER format - Next - cert.der`
- 위 과정을 통해 버프슈트 인증서(cert.der) 준비

2. OpenSSL 설치
- https://slproweb.com/products/Win32OpenSSL.html
- 자신의 Windows 환경에 맞게 설치
- 필자는 Win64 OpenSSL v1.1.1t 버전을 설치했음
- 설치 완료 후 `C:\Program Files\OpenSSL-Win64\bin\openssl.exe` 가 존재하는지 확인

3. Android Debug Bridge (ADB) 설치
- https://developer.android.com/studio/releases/platform-tools?hl=ko
- Windows용 SDK 플랫폼 도구 다운로드
- adb.exe 가 포함되어 있는 경로를 환경변수에 등록
- `시스템 환경 변수 편집 -> 환경 변수 -> [시스템 변수] Path 클릭 -> 편집 -> 새로 만들기 -> 경로 입력 -> 확인`

4. 루팅이 완료된 안드로이드 기기 준비
- Magisk 루팅
- 녹스(Nox)의 경우 설정 - 일반에서 루트 켜기

5. USB 디버깅 활성화 및 기기 연결
- 해당 안드로이드 기기에서 개발자 옵션 -> USB 디버깅 활성화
- 안드로이드 기기를 PC에 USB 연결
- cmd 에서 `adb devices` 명령어를 통해 기기가 잘 연결되었는지 확인 (device 라고 떠야함)
- 녹스(Nox)의 경우 `adb connect 127.0.0.1:62001` 명령어를 통해 기기를 연결한 후 device 가 잘 뜨는지 확인

## 이슈
- 230503 추가) 안드로이드 10 버전을 사용하는 갤럭시 노트9 SM-N960N 기기에서 /system 마운트가 안되는 현상이 있었음.
  - `Command> mount -o rw,remount /system`
  - `Error> mount: '/system' not in /proc/mounts`
  - 원인: https://twitter.com/topjohnwu/status/1170404631865778177 (Magisk 개발자 트윗)
  - 요약: 안드로이드 10 에서 파일 시스템 포맷이 바뀌어서 루트 디렉토리 아래로 rw,remount 가 기존 방법들로 안됨.
  - 살펴보니 아예 /system 디렉토리가 /proc/mounts 목록에 없음. (`mount | grep "/system" => No results`)
  - 해결방법: https://www.theburpsuite.com/2020/05/intercepting-android-application-https.html
  1. 스마트폰에 버프 프록시 설정해서 http://burp 에서 인증서 다운로드 (cacert.der)
  2. 파일 확장자 변경 (cacert.der -> cacert.cer)
  3. 설정 - 생체 인식 및 보안 - 기타 보안 설정 - 디바이스에 저장된 인증서 설치 - cacert.cer 선택 및 완료
  4. 임의의 인증서 이름 기입(필자는 PostSwigger 로 함), VPN 및 앱 선택하고 확인 (이래야 /data/misc/user/0/cacerts-added/ 아래에 9a5ba575.0 파일 생김)
  5. https://github.com/NVISOsecurity/MagiskTrustUserCerts/releases/tag/v0.4.1 에서 AlwaysTrustUserCerts.zip 다운로드
  6. PC 에서 받았으면 `adb push AlwaysTrustUserCerts.zip /sdcard/Download/` 스마트폰에서 받았으면 Download 경로에 저장
  7. Magisk - Modules - 저장소에서 설치 - AlwaysTrustUserCerts.zip 선택해서 설치 진행 - 다 됐으면 Reboot 버튼 클릭
  8. 재부팅 후 다시 Magisk - Modules 에 가서 해당 모듈이 잘 설치/활성화 되어 있는지 확인
  9. PC 에서 `adb shell "ls -l /system/etc/security/cacerts/9a5ba575.0"` 명령어 실행
  10. `-rw-r--r-- 1 root root 940 2023-05-03 15:37 /system/etc/security/cacerts/9a5ba575.0` 이런식으로 잘 들어가 있나 확인
