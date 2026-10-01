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
. "$PSScriptRoot\core\tools.ps1"
. "$PSScriptRoot\core\router.ps1"
. "$PSScriptRoot\core\ai-router.ps1"

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
    # 3. ROUTER IA
    # ========================================================

    Write-Host ""
    Write-Host "JARVIS: Estoy procesando tu peticion..." `
        -ForegroundColor Cyan
    Write-Host ""

    $resultadoIA = Resolver-Peticion-Con-IA $mensaje

    if (-not $resultadoIA.Exito) {

        Write-Host ""
        Write-Host "JARVIS: $($resultadoIA.Error)" `
            -ForegroundColor Red
        Write-Host ""

        continue
    }

    # ========================================================
    # RESPUESTA DE IA
    # ========================================================

    if (
        -not [string]::IsNullOrWhiteSpace(
            [string]$resultadoIA.Respuesta
        )
    ) {

        Write-Host "JARVIS: " -ForegroundColor Cyan -NoNewline
        Write-Host $resultadoIA.Respuesta
    }

    # ========================================================
    # EJECUTAR ACCION DE IA
    # ========================================================

    if (
        $resultadoIA.Accion -ne "ninguna"
    ) {

        $resultadoHerramienta = Ejecutar-Herramienta `
            $resultadoIA.Accion `
            $resultadoIA.Objetivo

        if (-not $resultadoHerramienta.Exito) {

            Write-Host ""
            Write-Host "JARVIS: $($resultadoHerramienta.Error)" `
                -ForegroundColor Yellow
        }
    }

    Write-Host ""
}
