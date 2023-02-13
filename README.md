# BurpSuiteCA Auto Insert Batch Script
## ** 필독 **
1. BurpSuite - Proxy - Proxy settings - Import/export CA certificate - [Export] Certificate in DER format - Next - cert.der
- 위 과정을 통해 버프슈트 인증서(cert.der) 준비

2. OpenSSL 설치
- https://slproweb.com/products/Win32OpenSSL.html
- 자신의 Windows 환경에 맞게 설치
- 필자는 Win64 OpenSSL v1.1.1t 버전을 설치했음
- 설치 완료 후 C:\Program Files\OpenSSL-Win64\bin\openssl.exe 가 존재하는지 확인

3. Android Debug Bridge (ADB) 설치
- https://developer.android.com/studio/releases/platform-tools?hl=ko
- Windows용 SDK 플랫폼 도구 다운로드
- adb.exe 가 포함되어 있는 경로를 환경변수에 등록
- 시스템 환경 변수 편집 -> 환경 변수 -> [시스템 변수] Path 클릭 -> 편집 -> 새로 만들기 -> 경로 입력 -> 확인

4. 루팅이 완료된 안드로이드 기기 준비
- Magisk 루팅

5. USB 디버깅 활성화
- 해당 안드로이드 기기에서 개발자 옵션 -> USB 디버깅 활성화
- 안드로이드 기기를 PC에 USB 연결
- cmd 에서 adb devices 명령어를 통해 기기가 잘 연결되었는지 확인 (device 라고 떠야함)
