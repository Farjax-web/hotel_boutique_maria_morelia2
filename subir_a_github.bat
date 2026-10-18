@echo off
title Subir Hotel Boutique Maria Morelia a GitHub
color 0B
cls
echo ================================================================
echo     SUBIR REPOSITORIO A GITHUB: Farjax-web
echo ================================================================
echo.
echo  Repositorio destino:
echo  https://github.com/Farjax-web/hotel_boutique_maria_morelia.git
echo.
echo  NOTA IMPORTANTE:
echo  1. Asegurate de haber creado el repositorio en GitHub:
echo     https://github.com/new con el nombre:
echo     hotel_boutique_maria_morelia
echo.
echo  2. Al presionar una tecla, Git abrira la ventana de inicio
echo     de sesion de GitHub en tu navegador o te pedira credenciales.
echo ================================================================
echo.
pause

set "PATH=%LOCALAPPDATA%\Programs\Git\cmd;%LOCALAPPDATA%\Programs\Git\ucrt64\bin;%PATH%"

echo.
echo [1/3] Verificando estado local...
git status

echo.
echo [2/3] Verificando rama 'main'...
git branch -M main

echo.
echo [3/3] Subiendo cambios a GitHub...
git push -u origin main

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ================================================================
    echo  EXITO: Los archivos se subieron correctamente a GitHub.
    echo  Ahora puedes desplegar tu pagina en Vercel desde:
    echo  https://vercel.com/new
    echo ================================================================
) else (
    echo.
    echo ================================================================
    echo  ERROR AL SUBIR. Posibles causas:
    echo  1. El repositorio no existe en https://github.com/Farjax-web
    echo     Crealos en: https://github.com/new
    echo  2. No se otorgaron los permisos de acceso / inicio de sesion.
    echo ================================================================
)

echo.
pause
