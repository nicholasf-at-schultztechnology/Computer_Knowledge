@echo off
REM Check if a file was dropped onto the script
if "%~1"=="" (
    echo Please drop a file onto this script to convert it.
    pause
    exit /b
)

REM Get the full path of the input file
set "inputFile=%~1"

REM Define the output file name (add _converted before the extension)
set "outputFile=%~dpn1_converted%~x1"

REM Run the ffmpeg command
ffmpeg -i "%inputFile%" -b:v 1000k -b:a 128k "%outputFile%"

REM Check if the conversion was successful
if %errorlevel% equ 0 (
    echo Conversion successful: %outputFile%
) else (
    echo Conversion failed.
)

pause
