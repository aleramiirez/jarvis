# ============================================================
# JARVIS - ASISTENTE LOCAL
# ============================================================

$utf8 = [System.Text.UTF8Encoding]::new($false)

[Console]::InputEncoding = $utf8
[Console]::OutputEncoding = $utf8
$OutputEncoding = $utf8

# ============================================================
# CARGAR CONFIGURACION
# ============================================================

. "$PSScriptRoot\config\config.ps1"

# ============================================================
# CARGAR UTILIDADES
# ============================================================

. "$PSScriptRoot\core\text.ps1"
. "$PSScriptRoot\core\router.ps1"
. "$PSScriptRoot\core\tools.ps1"

# ============================================================
# CARGAR HERRAMIENTAS
# ============================================================

. "$PSScriptRoot\tools\apps.ps1"
. "$PSScriptRoot\tools\folders.ps1"
. "$PSScriptRoot\tools\system.ps1"

# ============================================================
# CARGAR EJECUTOR
# ============================================================

. "$PSScriptRoot\core\executor.ps1"

# ============================================================
# CABECERA
# ============================================================

Clear-Host

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "        JARVIS - ASISTENTE LOCAL" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

$herramientas = Obtener-Herramientas

Write-Host "Herramientas cargadas: $($herramientas.Count)" `
    -ForegroundColor DarkGray

Write-Host ""
Write-Host "Escribe '/salir' para terminar." -ForegroundColor DarkGray
Write-Host ""

# ============================================================
# BUCLE PRINCIPAL
# ============================================================

while ($true) {

    $mensaje = Read-Host "TU"

    if ([string]::IsNullOrWhiteSpace($mensaje)) {
        continue
    }

    # ========================================================
    # SALIR
    # ========================================================

    if ((Normalizar-Texto $mensaje) -eq "/salir") {

        Write-Host ""
        Write-Host "JARVIS: Hasta luego, Ale." -ForegroundColor Cyan
        break
    }

    # ========================================================
    # 1. INFORMACION DEL SISTEMA
    # ========================================================

    $resultadoSistema = Obtener-InformacionSistema $mensaje

    if ($null -ne $resultadoSistema) {

        Write-Host ""
        Write-Host "JARVIS: " -ForegroundColor Cyan -NoNewline
        Write-Host $resultadoSistema.Texto
        Write-Host ""

        continue
    }

    # ========================================================
    # 2. ROUTER RAPIDO
    # ========================================================

    $rutaRapida = Obtener-Ruta-Rapida $mensaje

    if ($null -ne $rutaRapida) {

        Write-Host ""
        Write-Host "JARVIS: $($rutaRapida.Respuesta)" `
            -ForegroundColor Cyan

        $resultado = Ejecutar-Herramienta `
            $rutaRapida.Accion `
            $rutaRapida.Objetivo

        if (-not $resultado.Exito) {

            Write-Host ""
            Write-Host "JARVIS: $($resultado.Error)" `
                -ForegroundColor Yellow
        }

        Write-Host ""

        continue
    }

    # ========================================================
    # 3. OLLAMA
    # ========================================================

    Write-Host ""
    Write-Host "JARVIS: Estoy procesando tu peticion..." `
        -ForegroundColor Cyan
    Write-Host ""

    # ========================================================
    # PROMPT
    # ========================================================

    $prompt = @"
Eres JARVIS, un asistente personal local de Windows.

Analiza la peticion del usuario y devuelve exclusivamente
un objeto JSON valido.

El JSON debe tener exactamente estos campos:

{
  "respuesta": "mensaje para el usuario",
  "accion": "ninguna",
  "objetivo": ""
}

ACCIONES DISPONIBLES:

abrir_aplicacion
abrir_carpeta
ninguna

APLICACIONES PERMITIDAS:

notepad
calc
mspaint
cmd
powershell
explorer

CARPETA PERMITIDA:

jarvis

REGLAS:

- Responde siempre en espanol.
- La respuesta debe ser breve, clara y natural.
- No inventes informacion sobre el ordenador.
- No inventes informacion del sistema.
- No inventes acciones.
- No afirmes que has realizado una accion si no se ha ejecutado.
- Utiliza exactamente los nombres de las acciones disponibles.
- Devuelve solamente JSON valido.
- No escribas Markdown.
- No escribas explicaciones fuera del JSON.

Peticion del usuario:

$mensaje
"@

    # ========================================================
    # BODY
    # ========================================================

    $body = @{
        model = $JARVIS_MODEL
        prompt = $prompt
        stream = $false
        think = $false
        format = "json"
    } | ConvertTo-Json -Compress

    # ========================================================
    # PETICION A OLLAMA
    # ========================================================

    try {

        $resultado = Invoke-RestMethod `
            -Uri $OLLAMA_GENERATE_URL `
            -Method Post `
            -ContentType "application/json; charset=utf-8" `
            -Body ([System.Text.Encoding]::UTF8.GetBytes($body))
    }
    catch {

        Write-Host ""
        Write-Host "JARVIS: No puedo conectar con Ollama." `
            -ForegroundColor Red

        Write-Host $_.Exception.Message `
            -ForegroundColor DarkRed

        Write-Host ""

        continue
    }

    # ========================================================
    # PARSEAR RESPUESTA
    # ========================================================

    try {

        $jarvis = $resultado.response | ConvertFrom-Json
    }
    catch {

        Write-Host ""
        Write-Host "JARVIS: La respuesta del modelo no es valida." `
            -ForegroundColor Red

        Write-Host ""

        continue
    }

    # ========================================================
    # RESPUESTA DE OLLAMA
    # ========================================================

    if (
        -not [string]::IsNullOrWhiteSpace(
            [string]$jarvis.respuesta
        )
    ) {

        Write-Host "JARVIS: " -ForegroundColor Cyan -NoNewline
        Write-Host $jarvis.respuesta
    }

    # ========================================================
    # ACCIONES DEVUELTAS POR OLLAMA
    # ========================================================

    if (
        -not [string]::IsNullOrWhiteSpace(
            [string]$jarvis.accion
        ) -and
        $jarvis.accion -ne "ninguna"
    ) {

        $resultadoHerramienta = Ejecutar-Herramienta `
            $jarvis.accion `
            $jarvis.objetivo

        if (-not $resultadoHerramienta.Exito) {

            Write-Host ""
            Write-Host "JARVIS: $($resultadoHerramienta.Error)" `
                -ForegroundColor Yellow
        }
    }

    Write-Host ""
}
