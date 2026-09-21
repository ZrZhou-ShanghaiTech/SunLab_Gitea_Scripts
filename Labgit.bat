@echo off
setlocal EnableExtensions
title Lab Git Launcher

REM =========================================================
REM Lab Git configuration
REM =========================================================

set "SSH_HOST=10.15.49.221"
set "SSH_PORT=22112"

set "WEB_PORT=3000"
set "GIT_PORT=2222"

set "GITEA_URL=http://127.0.0.1:%WEB_PORT%/"

echo ========================================
echo          Lab Git Launcher
echo ========================================
echo.


REM =========================================================
REM 1. Check OpenSSH
REM =========================================================

where ssh >nul 2>&1

if errorlevel 1 (
    echo ERROR: Windows OpenSSH client was not found.
    echo.
    echo Please install OpenSSH Client first.
    echo.
    pause
    exit /b 1
)


REM =========================================================
REM 2. Check curl
REM =========================================================

where curl >nul 2>&1

if errorlevel 1 (
    echo ERROR: curl was not found.
    echo.
    echo Windows 10/11 normally includes curl.
    echo.
    pause
    exit /b 1
)


REM =========================================================
REM 3. Check whether Gitea tunnel is already available
REM =========================================================

curl.exe -sS --max-time 2 -o NUL "%GITEA_URL%" >nul 2>&1

if not errorlevel 1 (
    echo Lab Gitea is already connected.
    echo.
    echo Opening:
    echo %GITEA_URL%
    echo.

    start "" "%GITEA_URL%"

    timeout /t 2 /nobreak >nul
    exit /b 0
)


REM =========================================================
REM 4. Check whether local port 3000 is occupied
REM =========================================================

netstat -ano | findstr ":%WEB_PORT% " | findstr "LISTENING" >nul

if not errorlevel 1 (
    echo ERROR:
    echo Local port %WEB_PORT% is already in use,
    echo but Gitea is not responding.
    echo.
    echo Run this command to inspect it:
    echo.
    echo     netstat -ano ^| findstr :%WEB_PORT%
    echo.
    pause
    exit /b 1
)


REM =========================================================
REM 5. Check whether local port 2222 is occupied
REM =========================================================

netstat -ano | findstr ":%GIT_PORT% " | findstr "LISTENING" >nul

if not errorlevel 1 (
    echo ERROR:
    echo Local port %GIT_PORT% is already in use.
    echo.
    echo Run this command to inspect it:
    echo.
    echo     netstat -ano ^| findstr :%GIT_PORT%
    echo.
    pause
    exit /b 1
)


REM =========================================================
REM 6. Ask for SSH username
REM =========================================================

set /p "SSH_USER=SSH username: "

if "%SSH_USER%"=="" (
    echo.
    echo ERROR: SSH username cannot be empty.
    echo.
    pause
    exit /b 1
)


echo.
echo Connecting to Lab Gitea...
echo.
echo A new SSH window will open.
echo Please enter your SSH password in that window.
echo.
echo DO NOT close the SSH window while using Gitea.
echo.


REM =========================================================
REM 7. Start SSH tunnel
REM =========================================================

start "Lab Git SSH Tunnel" cmd /k ^
ssh -N ^
-p %SSH_PORT% ^
-L 127.0.0.1:%WEB_PORT%:127.0.0.1:3000 ^
-L 127.0.0.1:%GIT_PORT%:127.0.0.1:2222 ^
-o ExitOnForwardFailure=yes ^
-o ServerAliveInterval=30 ^
-o ServerAliveCountMax=3 ^
%SSH_USER%@%SSH_HOST%


REM =========================================================
REM 8. Wait for Gitea
REM =========================================================

echo Waiting for Gitea...
echo.

set /a WAIT_COUNT=0


:WAIT_LOOP

timeout /t 1 /nobreak >nul

curl.exe -sS --max-time 2 -o NUL "%GITEA_URL%" >nul 2>&1

if not errorlevel 1 goto CONNECTED

set /a WAIT_COUNT+=1

if %WAIT_COUNT% GEQ 60 goto TIMEOUT

goto WAIT_LOOP


REM =========================================================
REM 9. Connected
REM =========================================================

:CONNECTED

echo.
echo ========================================
echo       Connected to Lab Gitea
echo ========================================
echo.
echo Web:
echo     %GITEA_URL%
echo.
echo Git SSH:
echo     ssh://git@127.0.0.1:%GIT_PORT%/
echo.
echo Keep the "Lab Git SSH Tunnel" window open.
echo.

start "" "%GITEA_URL%"

timeout /t 3 /nobreak >nul

exit /b 0


REM =========================================================
REM 10. Timeout
REM =========================================================

:TIMEOUT

echo.
echo ERROR:
echo Gitea did not become available within 60 seconds.
echo.
echo Please check the "Lab Git SSH Tunnel" window for errors.
echo.
pause

exit /b 1