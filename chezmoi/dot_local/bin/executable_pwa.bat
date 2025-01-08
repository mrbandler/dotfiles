@echo off

REM Check if a URL was provided
if "%~1"=="" (
    echo Usage: %~nx0 [URL]
    exit /B 1
)

REM The URL is the first argument
set "URL=%~1"

REM Launch Edge in app mode
"%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" --app=%URL%
