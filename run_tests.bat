@echo off
set GODOT_EXE="C:\Users\appar\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe"
if not exist %GODOT_EXE% (
    echo Godot console executable not found.
    pause
    exit /b 1
)

echo Running After the Rain Automated Verification...
%GODOT_EXE% --headless --path "%~dp0." "res://tests/test_runner.tscn"
pause
