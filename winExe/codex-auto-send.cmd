@echo off
set "SCRIPT_DIR=%~dp0"
start "" powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File "%SCRIPT_DIR%codex-auto-send.ps1"
