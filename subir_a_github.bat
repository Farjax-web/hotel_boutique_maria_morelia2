@echo off
title Subir Hotel Boutique Maria Morelia a GitHub
color 0B
cls
echo ================================================================
echo     SUBIR REPOSITORIO A GITHUB: Farjax-web
echo ================================================================
echo.
echo  Repositorio destino:
echo  https://github.com/Farjax-web/hotel_boutique_maria_morelia2.git
echo.
echo  1. Al presionar una tecla, Git abrira la ventana de inicio
echo     de sesion de GitHub en tu navegador o te pedira credenciales.
echo  2. Una vez autorizado, los archivos se subiran a la rama 'main'.
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
    echo  EXITO: Los archivos se subieron correctamente a GitHub!
    echo.
    echo  Tu repositorio publico:
    echo  https://github.com/Farjax-web/hotel_boutique_maria_morelia2
    echo.
    echo  Ahora despliega tu pagina en Vercel en 1 minuto:
    echo  1. Ve a: https://vercel.com/new
    echo  2. Selecciona 'hotel_boutique_maria_morelia2'
    echo  3. Haz clic en 'Deploy'
    echo ================================================================
) else (
    echo.
    echo ================================================================
    echo  ERROR AL SUBIR.
    echo  Por favor verifica que hayas iniciado sesion con tu cuenta
    echo  de GitHub (Farjax-web) en el navegador.
    echo ================================================================
)

echo.
pause
