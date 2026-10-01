# ============================================================
# JARVIS - HERRAMIENTAS DE CARPETAS
# ============================================================

function Abrir-Carpeta {

    param (
        [Parameter(Mandatory = $true)]
        [string]$Carpeta
    )

    switch ($Carpeta.ToLower()) {

        "jarvis" {

            Start-Process "explorer.exe" "C:\dev\proyectos\jarvis"
            return $true
        }

        default {

            return $false
        }
    }
}