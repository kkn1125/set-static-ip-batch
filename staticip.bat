@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

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
    if "!line!" neq "!line:Configuration for interface=!" (
        set "INTERFACE_NAME=!line:Configuration for interface =!"
        set "INTERFACE_NAME=!INTERFACE_NAME:~1,-1!"
        for /f "tokens=* delims= " %%a in ("!INTERFACE_NAME!") do set "INTERFACE_NAME=%%a"
        @REM echo !INTERFACE_NAME!
    )
    @REM if "!line!"=="인터페이스에 대한 구성" (
    @REM     set "INTERFACE_NAME=!line:~1,-1!"
    @REM )

    @REM echo line: !line!
    
    :: IP 주소 추출
    if "!line!" neq "!line:IP Address=!" (
        for /f "tokens=* delims= " %%a in ("!line:IP Address: =!") do set "IP_ADDRESS=%%a"
        @REM set "IP_ADDRESS=!line:IP Address: =!"
        echo Interface Name: !INTERFACE_NAME!
        echo IP Address: !IP_ADDRESS!
        echo
        set /a COUNT+=1
        if !COUNT! geq 1 (
            goto :end
        )
    )
    @REM if "!line!"=="IP 주소" (
    @REM     set "IP_ADDRESS=!line:IP 주소: =!"
    @REM     echo Interface Name: !INTERFACE_NAME!
    @REM     echo IP Address: !IP_ADDRESS!
    @REM     echo
    @REM     set /a COUNT+=1
    @REM     if !COUNT! geq 2 (
    @REM         goto :end
    @REM     )
    @REM )
)

:end

echo echo test: %INTERFACE_NAME% > result.txt




:: 결과 출력 후 인터페이스 IP 주소 설정
if defined INTERFACE_NAME (
    netsh interface ip set address name="!INTERFACE_NAME!" static 192.168.0.10 255.255.255.0 192.168.0.1
) else (
    echo Interface Name not found!
)

endlocal
