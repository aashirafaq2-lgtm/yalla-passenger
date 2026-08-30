@echo off
echo Searching for Flutter...
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo Flutter not found in PATH. Trying common locations...
    set "PATH=%PATH%;C:\src\flutter\bin;C:\flutter\bin;%USERPROFILE%\flutter\bin;%USERPROFILE%\AppData\Local\Flutter\bin"
)
echo Starting APK Build...
flutter build apk --release
if %errorlevel% equ 0 (
    echo.
    echo SUCCESS! APK is located at:
    echo build\app\outputs\flutter-apk\app-release.apk
) else (
    echo.
    echo Error: Could not build APK. Please make sure Flutter is installed and working.
)
pause
