@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set "CONTINUE=192.168.0.254"

set /p CONTINUE=192.168.0.254로 고정 IP 설정합니다. 엔터를 누르시면 진행하고, IP 충돌 시 여기에 입력하시면 입력하신 IP로 설정됩니다.(예시, 192.168.0.253): 

@REM IP 주소 형식 확인: x.x.x.x 형태인지 확인
for /f "tokens=1-4 delims=." %%a in ("%CONTINUE%") do (
    set "octet1=%%a"
    set "octet2=%%b"
    set "octet3=%%c"
    set "octet4=%%d"
)

@REM IP 주소의 옥텟 개수와 각 옥텟이 숫자인지 확인
if "%octet1%"=="" (
    echo 잘못된 IP 설정입니다.
    exit /b 1
)
if "%octet2%"=="" (
    echo 잘못된 IP 설정입니다.
    exit /b 1
)
if "%octet3%"=="" (
    echo 잘못된 IP 설정입니다.
    exit /b 1
)
if "%octet4%"=="" (
    echo 잘못된 IP 설정입니다.
    exit /b 1
)

for %%i in (%octet1% %octet2% %octet3% %octet4%) do (
    @REM 옥텟이 숫자인지 확인
    for /f "delims=0123456789" %%j in ("%%i") do (
        echo 잘못된 IP 설정입니다.
        exit /b 1
    )
    @REM 옥텟이 0-255 범위에 있는지 확인
    if %%i lss 0 (
        echo 잘못된 IP 설정입니다.
        exit /b 1
    )
    if %%i gtr 255 (
        echo 잘못된 IP 설정입니다.
        exit /b 1
    )
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
netsh interface ip show config > "%RESULT_FILE%"

:: 파일이 존재하는지 확인
if not exist "%RESULT_FILE%" (
    echo Result file not found!
    exit /b 1
)

:: 파일을 줄 단위로 읽어 처리
for /f "tokens=*" %%i in (%RESULT_FILE%) do (
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
        echo Interface Name: !INTERFACE_NAME!
        echo IP Address: !IP_ADDRESS!
        echo
        set /a COUNT+=1
        if !COUNT! geq 3 (
            goto :end
        )
    )
)

:end

echo test: %INTERFACE_NAME% > result.txt

:: 결과 출력 후 인터페이스 IP 주소 설정
if defined INTERFACE_NAME (
    netsh interface ip set address name="!INTERFACE_NAME!" static !CONTINUE! 255.255.255.0 192.168.0.1
) else (
    echo Interface Name not found!
)

echo "고정 IP 설정이 완료되었습니다. 적용된 IP는 !CONTINUE!입니다."

endlocal

pause