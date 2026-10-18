@echo off
title Hotel Boutique Maria Morelia - Detener Servidor
echo Deteniendo servidor en puerto 8080...
powershell.exe -NoProfile -Command "Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like '*server.ps1*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force; Write-Host ('Servidor detenido (PID ' + $_.ProcessId + ')') }"
echo Listo.
timeout /t 3
