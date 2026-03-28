@echo off
setlocal

echo Cerrando ventanas de servidor local (python http.server)...
taskkill /FI "WINDOWTITLE eq PuertoPanulPreviewServer" /T /F >nul 2>nul

echo Si quedo algun proceso abierto, cerrando por comando...
taskkill /IM python.exe /F >nul 2>nul
taskkill /IM py.exe /F >nul 2>nul
taskkill /IM python3.exe /F >nul 2>nul

echo.
echo Listo. Si tenia otros procesos Python importantes, revise que no se hayan cerrado.
echo.
pause
