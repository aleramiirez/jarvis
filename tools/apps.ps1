# ============================================================
# JARVIS - HERRAMIENTAS DE APLICACIONES
# ============================================================

function Abrir-Aplicacion {

    param (
        [Parameter(Mandatory = $true)]
        [string]$Aplicacion
    )

    switch ($Aplicacion.ToLower()) {

        "notepad" {
            Start-Process "notepad.exe"
            return $true
        }

        "calc" {
            Start-Process "calc.exe"
            return $true
        }

        "mspaint" {
            Start-Process "mspaint.exe"
            return $true
        }

        "cmd" {
            Start-Process "cmd.exe"
            return $true
        }

        "powershell" {
            Start-Process "powershell.exe"
            return $true
        }

        "explorer" {
            Start-Process "explorer.exe"
            return $true
        }

        default {
            return $false
        }
    }
}