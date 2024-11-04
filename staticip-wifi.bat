@echo off

@REM 관리자 권한 실행 시 필요 bat file 실행하는 경로가 달라짐
pushd %~dp0

chcp 65001 >nul
setlocal enabledelayedexpansion

echo 유동/고정 IP 설정 메뉴를 선택해주세요.
echo 1. 교육 시작 - 고정 IP로 설정하기
echo 2. 교육 종료 - 유동 IP로 되돌리기
echo 3. Wi-Fi 연결 최적화

set /p MENU=^(번호를 입력해주세요^): 

if "%MENU%"=="3" (
    echo Wi-Fi 연결을 최적화합니다.
    netsh wlan delete profile name=*
    netsh interface ip set dns "Wi-Fi" dhcp
    echo Wi-Fi 연결 최적화가 완료되었습니다.
    goto :end
) else if "%MENU%"=="2" (
    echo 교육 종료 - 유동 IP로 되돌립니다.
    netsh interface ip set address "Wi-Fi" dhcp
    netsh interface ip set dns "Wi-Fi" dhcp
    echo 유동 IP 설정이 완료되었습니다.
    goto :end
) else if "%MENU%"=="1" (
    echo 교육 시작 - 고정 IP로 설정합니다. IP 인터페이스를 조회합니다. 잠시만 기다려주세요...

    set "MY_IP="

    @REM DHCP로 할당된 현재 IP 주소 가져오기
    for /f "tokens=3" %%a in ('netsh interface ip show addresses name^="Wi-Fi" ^| findstr /r /c:"IP Address"') do set MY_IP=%%a

    @REM 통신사 확인
    set ISP_NAME="UNKNOWN"

    @REM nslookup으로 현재 IP 주소의 ISP 확인
    for /f "tokens=2" %%i in ('nslookup !MY_IP! 2^>nul ^| findstr "Name:"') do set "ISP_NAME=%%i"

    echo [LOG] 현재 IP 주소: !MY_IP!
    echo [LOG] 감지된 ISP: !ISP_NAME!

    @REM ISP에 따른 DNS 서버 주소 설정
    if /i "!ISP_NAME!" equ "kt.com" (
        set "DNS1=168.126.63.1"
        set "DNS2=168.126.63.2"
    ) else if /i "!ISP_NAME!" equ "sk.com" (
        set "DNS1=210.220.163.82"
        set "DNS2=219.250.36.130"
    ) else if /i "!ISP_NAME!" equ "lg.com" (
        set "DNS1=164.124.101.2"
        set "DNS2=203.248.252.2"
    ) else (
        @REM ISP를 확인할 수 없는 경우 기본 DNS (Google Public DNS) 사용
        set "DNS1=8.8.8.8"
        set "DNS2=8.8.4.4"
    )

    echo [LOG] 설정된 DNS 서버: 기본 DNS - !DNS1!, 보조 DNS - !DNS2!

    set "CONTINUE=192.168.0.254"

    set /p CONTINUE=[SETTING] 192.168.0.254로 고정 IP 설정합니다. 엔터를 누르시면 진행하고, IP 충돌 시 여기에 입력하시면 입력하신 IP로 설정됩니다.^(예시, 192.168.0.253^): 
    
    @REM IP 주소 형식 확인: x.x.x.x 형태인지 확인
    for /f "tokens=1-4 delims=." %%a in ("!CONTINUE!") do (
        set "octet1=%%a"
        set "octet2=%%b"
        set "octet3=%%c"
        set "octet4=%%d"
    )

    @REM IP 주소의 옥텟 개수와 각 옥텟이 숫자인지 확인
    if "!octet1!"=="" (
        echo [LOG] 잘못된 IP 설정입니다.
        exit /b 1
    )
    if "!octet2!"=="" (
        echo [LOG] 잘못된 IP 설정입니다.
        exit /b 1
    )
    if "!octet3!"=="" (
        echo [LOG] 잘못된 IP 설정입니다.
        exit /b 1
    )
    if "!octet4!"=="" (
        echo [LOG] 잘못된 IP 설정입니다.
        exit /b 1
    )

    @REM 각 옥텟이 숫자인지 확인
    for %%i in (!octet1! !octet2! !octet3! !octet4!) do (
        set "octet=%%i"
        for /f "delims=0123456789" %%a in ("%%i") do (
            echo [LOG] !octet! 옥텟이 숫자가 아닙니다.
            exit /b 1
        )
    )

    @REM 첫 번째 옥텟의 범위 확인 (1 ~ 255)
    if !octet1! lss 0 (
        echo [LOG] 첫 번째 !octet1! 옥텟이 1보다 작습니다.
        exit /b 1
    )
    if !octet1! gtr 255 (
        echo [LOG] 첫 번째 !octet1! 옥텟이 255보다 큽니다.
        exit /b 1
    )

    @REM 두 번째 옥텟의 범위 확인 (1 ~ 255)
    if !octet2! lss 0 (
        echo [LOG] 두 번째 !octet2! 옥텟이 1보다 작습니다.
        exit /b 1
    )
    if !octet2! gtr 255 (
        echo [LOG] 두 번째 !octet2! 옥텟이 255보다 큽니다.
        exit /b 1
    )

    @REM 세 번째 옥텟의 범위 확인 (1 ~ 255)
    if !octet3! lss 0 (
        echo [LOG] 세 번째 !octet3! 옥텟이 1보다 작습니다.
        exit /b 1
    )
    if !octet3! gtr 255 (
        echo [LOG] 세 번째 !octet3! 옥텟이 255보다 큽니다.
        exit /b 1
    )

    @REM 네 번째 옥텟의 범위 확인 (2 ~ 254)
    if !octet4! lss 2 (
        echo [LOG] 네 번째 !octet4! 옥텟이 2보다 작습니다.
        exit /b 1
    )
    if !octet4! gtr 254 (
        echo [LOG] 네 번째 !octet4! 옥텟이 254보다 큽니다.
        exit /b 1
    )


    @REM @REM IP 주소가 올바르다면 성공 메시지
    @REM echo 올바른 IP 주소입니다.

    :: 변수 초기화
    set "INTERFACE_NAME="
    set "IP_ADDRESS="
    set "COUNT=0"

    :: 저장된 결과 파일
    set "RESULT_FILE=netsh_output.txt"

    :: netsh 명령어 실행 결과를 파일로 저장
    netsh interface ip show config > "!RESULT_FILE!"

    :: 파일이 존재하는지 확인
    if not exist "!RESULT_FILE!" (3
        echo [WARN] Result file not found!
        exit /b 1
    )

    :: 파일을 줄 단위로 읽어 처리
    for /f "tokens=*" %%i in (!RESULT_FILE!) do (
        set "line=%%i"
        
        :: 인터페이스 이름 추출 (영어 및 한글 모두 처리)
        if "!line!" neq "!line:Configuration for interface "Wi-Fi"=!" (
            set "INTERFACE_NAME=!line:Configuration for interface =!"
            set "INTERFACE_NAME=!INTERFACE_NAME:~1,-1!"
            for /f "tokens=* delims= " %%a in ("!INTERFACE_NAME!") do set "INTERFACE_NAME=%%a"
        )
        
        :: IP 주소 추출
        if "!line!" neq "!line:IP Address=!" (
            for /f "tokens=* delims= " %%a in ("!line:IP Address: =!") do set "IP_ADDRESS=%%a"
            @REM echo Interface Name: !INTERFACE_NAME!
            @REM echo IP Address: !IP_ADDRESS!
            @REM echo
            set /a COUNT+=1
            if !COUNT! geq 3 (
                goto :pass
            )
        )
    )

    :pass
    echo test: %INTERFACE_NAME% > result.txt

    :: 결과 출력 후 인터페이스 IP 주소 설정
    if defined INTERFACE_NAME (
        netsh interface ip set address name="!INTERFACE_NAME!" static !CONTINUE! 255.255.255.0 192.168.0.1
        netsh interface ip set dns name="!INTERFACE_NAME!" static !DNS1! primary no
        netsh interface ip add dns name="!INTERFACE_NAME!" !DNS2! index=2 no
    ) else (
        echo [WARN] Interface Name not found!
    )

    echo [LOG] 고정 IP 설정 및 DNS서버 설정이 완료되었습니다. 적용된 IP는 !CONTINUE!입니다.
    if "!ISP_NAME!" equ "UNKNOWN" (
        echo [LOG] DNS가 !ISP_NAME!입니다. 네트워크 구성을 Google public DNS로 지정합니다.
        echo [LOG] default dns: !DNS1!
        echo [LOG] sub dns: !DNS2!
    ) else (
        echo [LOG] DNS가 !ISP_NAME!를 기반으로 설정되었습니다.
        echo [LOG] default dns: !DNS1!
        echo [LOG] sub dns: !DNS2!
    )
    echo [LOG] 모든 설정이 완료되었습니다.
    goto :end
) else (
    echo [LOG] 잘못된 입력입니다. 다시 선택해주세요.
    goto :end
)

:end

endlocal

pause