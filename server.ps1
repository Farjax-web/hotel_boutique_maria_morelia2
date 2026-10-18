param(
    [int]$Port = 8080,
    [string]$Root = $PSScriptRoot,
    [switch]$NoBrowser
)

$mimeTypes = @{
    ".html" = "text/html; charset=utf-8"
    ".htm"  = "text/html; charset=utf-8"
    ".css"  = "text/css; charset=utf-8"
    ".js"   = "application/javascript; charset=utf-8"
    ".json" = "application/json; charset=utf-8"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".gif"  = "image/gif"
    ".svg"  = "image/svg+xml"
    ".webp" = "image/webp"
    ".ico"  = "image/x-icon"
    ".woff" = "font/woff"
    ".woff2"= "font/woff2"
    ".ttf"  = "font/ttf"
}

$prefix = "http://localhost:$Port/"
$browserOpened = $NoBrowser.IsPresent

while ($true) {
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add($prefix)

    try {
        $listener.Start()
        Write-Host "====================================================" -ForegroundColor Green
        Write-Host " Hotel Boutique Maria Morelia - Servidor Web Activo" -ForegroundColor Cyan
        Write-Host " URL: $prefix" -ForegroundColor Yellow
        Write-Host " Directorio: $Root"
        Write-Host " Presione Ctrl+C en esta ventana para detener" -ForegroundColor Gray
        Write-Host "====================================================" -ForegroundColor Green

        if (-not $browserOpened) {
            Start-Process $prefix
            $browserOpened = $true
        }
    } catch {
        Write-Warning "No se pudo enlazar el puerto $Port (posiblemente ocupado). Reintentando en 3s... : $_"
        Start-Sleep -Seconds 3
        continue
    }

    try {
        while ($listener.IsListening) {
            try {
                $context = $listener.GetContext()
            } catch {
                break
            }

            try {
                $request = $context.Request
                $response = $context.Response

                $rawUrl = $request.RawUrl.Split('?')[0]
                if ($rawUrl -eq "/" -or [string]::IsNullOrWhiteSpace($rawUrl)) {
                    $rawUrl = "/index.html"
                }

                $decodedUrl = [System.Uri]::UnescapeDataString($rawUrl).TrimStart('/')
                $decodedUrl = $decodedUrl -replace '/', '\'
                $filePath = Join-Path $Root $decodedUrl

                if (-not (Test-Path $filePath -PathType Leaf)) {
                    if ($rawUrl -eq "/index.html" -and (Test-Path (Join-Path $Root "code.html"))) {
                        $filePath = Join-Path $Root "code.html"
                    }
                }

                if (Test-Path $filePath -PathType Leaf) {
                    $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
                    $mime = if ($mimeTypes.ContainsKey($ext)) { $mimeTypes[$ext] } else { "application/octet-stream" }

                    $bytes = [System.IO.File]::ReadAllBytes($filePath)
                    $response.ContentType = $mime
                    $response.ContentLength64 = $bytes.Length
                    $response.StatusCode = 200
                    $response.AddHeader("Access-Control-Allow-Origin", "*")
                    $response.AddHeader("Cache-Control", "no-cache")
                    $response.OutputStream.Write($bytes, 0, $bytes.Length)
                } elseif ($rawUrl -eq "/favicon.ico") {
                    $response.StatusCode = 204
                } else {
                    $response.StatusCode = 404
                    $msg = [System.Text.Encoding]::UTF8.GetBytes("<html><head><title>404 No Encontrado</title></head><body style='font-family:sans-serif;padding:2rem;'><h2>404 - Archivo no encontrado</h2><p>La ruta <code>$rawUrl</code> no existe.</p><a href='/'>Volver al inicio</a></body></html>")
                    $response.ContentType = "text/html; charset=utf-8"
                    $response.ContentLength64 = $msg.Length
                    $response.OutputStream.Write($msg, 0, $msg.Length)
                }
            } catch {
                # Error en solicitud individual
            } finally {
                try {
                    $response.Close()
                } catch {}
            }
        }
    } catch {
        Write-Warning "Ciclo de escucha interrumpido: $_"
    } finally {
        try {
            $listener.Stop()
            $listener.Close()
        } catch {}
    }

    Start-Sleep -Seconds 1
}
