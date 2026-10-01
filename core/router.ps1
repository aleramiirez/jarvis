# ============================================================
# JARVIS - ROUTER DE PETICIONES RAPIDAS
# ============================================================

function Obtener-Ruta-Rapida {

    param (
        [Parameter(Mandatory = $true)]
        [string]$Mensaje
    )

    $texto = Normalizar-Texto $Mensaje

    # ========================================================
    # BLOC DE NOTAS
    # ========================================================

    if (
        $texto -match "bloc de notas" -or
        $texto -match "notepad"
    ) {

        return @{
            Tipo = "accion"
            Accion = "abrir_app"
            Objetivo = "notepad"
            Respuesta = "Entendido. Voy a abrir el Bloc de notas."
        }
    }

    # ========================================================
    # CALCULADORA
    # ========================================================

    if (
        $texto -match "calculadora" -or
        $texto -match "abre calc" -or
        $texto -match "abrir calc"
    ) {

        return @{
            Tipo = "accion"
            Accion = "abrir_app"
            Objetivo = "calc"
            Respuesta = "Entendido. Voy a abrir la Calculadora."
        }
    }

    # ========================================================
    # PAINT
    # ========================================================

    if (
        $texto -match "abre paint" -or
        $texto -match "abrir paint"
    ) {

        return @{
            Tipo = "accion"
            Accion = "abrir_app"
            Objetivo = "mspaint"
            Respuesta = "Entendido. Voy a abrir Paint."
        }
    }

    # ========================================================
    # CMD
    # ========================================================

    if (
        $texto -match "abre cmd" -or
        $texto -match "abrir cmd"
    ) {

        return @{
            Tipo = "accion"
            Accion = "abrir_app"
            Objetivo = "cmd"
            Respuesta = "Entendido. Voy a abrir CMD."
        }
    }

    # ========================================================
    # POWERSHELL
    # ========================================================

    if (
        $texto -match "abre powershell" -or
        $texto -match "abrir powershell"
    ) {

        return @{
            Tipo = "accion"
            Accion = "abrir_app"
            Objetivo = "powershell"
            Respuesta = "Entendido. Voy a abrir PowerShell."
        }
    }

    # ========================================================
    # EXPLORADOR
    # ========================================================

    if (
        $texto -match "abre el explorador" -or
        $texto -match "abre explorador" -or
        $texto -match "abrir el explorador" -or
        $texto -match "abrir explorador"
    ) {

        return @{
            Tipo = "accion"
            Accion = "abrir_app"
            Objetivo = "explorer"
            Respuesta = "Entendido. Voy a abrir el Explorador."
        }
    }

    # ========================================================
    # PROYECTO JARVIS
    # ========================================================

    if (
        $texto -match "proyecto de jarvis" -or
        $texto -match "proyecto jarvis" -or
        $texto -match "carpeta de jarvis" -or
        $texto -match "carpeta jarvis"
    ) {

        return @{
            Tipo = "accion"
            Accion = "abrir_carpeta"
            Objetivo = "jarvis"
            Respuesta = "Entendido. Voy a abrir el proyecto JARVIS."
        }
    }

    return $null
}
