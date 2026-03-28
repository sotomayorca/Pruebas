@echo off
setlocal

REM Levanta un servidor local y abre navegador en /preview/
set "APP_DIR=%~dp0"
set "PORT=8080"
set "URL=http://localhost:%PORT%/preview/"

cd /d "%APP_DIR%"

echo.
echo ==============================================
echo   Puerto Panul - Servidor local de vista previa
echo ==============================================
echo Carpeta: %APP_DIR%
echo URL: %URL%
echo.

echo Verificando Python...
where py >nul 2>nul
if %errorlevel%==0 (
  set "PY_CMD=py -m http.server %PORT%"
  goto :run
)

where python >nul 2>nul
if %errorlevel%==0 (
  set "PY_CMD=python -m http.server %PORT%"
  goto :run
)

where python3 >nul 2>nul
if %errorlevel%==0 (
  set "PY_CMD=python3 -m http.server %PORT%"
  goto :run
)

echo.
echo [ERROR] No se encontro Python instalado.
echo Solucion rapida:
echo 1) Instalar Python desde https://www.python.org/downloads/
echo 2) Marcar la opcion "Add Python to PATH"
echo 3) Ejecutar nuevamente este archivo.
echo.
pause
exit /b 1

:run
echo Iniciando servidor con: %PY_CMD%
start "PuertoPanulPreviewServer" cmd /k "%PY_CMD%"
timeout /t 2 >nul
start "" "%URL%"

echo.
echo Servidor iniciado. Cuando quiera detenerlo, use:
echo DETENER_APP_LOCAL.bat
echo.
pause
