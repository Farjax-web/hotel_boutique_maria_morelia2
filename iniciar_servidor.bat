@echo off
title Hotel Boutique Maria Morelia - Servidor Web
color 0F
cls
echo ================================================================
echo           HOTEL BOUTIQUE MARIA MORELIA - SERVIDOR WEB
echo ================================================================
echo.
echo  Iniciando servidor local en http://localhost:8080 ...
echo  Tu navegador predeterminado se abrira automaticamente.
echo.
echo  Para detener el servidor, simplemente cierra esta ventana.
echo ================================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0server.ps1" -Port 8080
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Ocurrio un error al iniciar el servidor.
    pause
)
