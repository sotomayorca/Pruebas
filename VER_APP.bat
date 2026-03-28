@echo off
setlocal

REM Abre la vista previa sin instalar nada (modo archivo local)
set "APP_DIR=%~dp0"
set "HTML_FILE=%APP_DIR%preview\index.html"

if not exist "%HTML_FILE%" (
  echo.
  echo [ERROR] No se encontro el archivo: %HTML_FILE%
  echo Verifique que exista la carpeta "preview".
  pause
  exit /b 1
)

echo.
echo ==============================================
echo   Puerto Panul - Vista previa del aplicativo
echo ==============================================
echo Abriendo: %HTML_FILE%
echo.

start "Puerto Panul Preview" "%HTML_FILE%"

echo Listo. Si no se abre, copie y pegue esta ruta en su navegador:
echo %HTML_FILE%
echo.
pause
