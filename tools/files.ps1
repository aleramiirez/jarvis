# ============================================================
# JARVIS - HERRAMIENTAS DE ARCHIVOS
# ============================================================

function Listar-Carpeta {

    param (
        [Parameter(Mandatory = $true)]
        [string]$Carpeta
    )

    switch ($Carpeta.ToLower()) {

        "jarvis" {

            $ruta = "C:\dev\proyectos\jarvis"

            if (-not (Test-Path $ruta -PathType Container)) {

                return $null
            }

            try {

                $elementos = Get-ChildItem `
                    -Path $ruta `
                    -Force |
                    Sort-Object `
                        @{ Expression = "PSIsContainer"; Descending = $true },
                        Name

                if ($elementos.Count -eq 0) {

                    return "La carpeta JARVIS esta vacia."
                }

                $lineas = @()

                foreach ($elemento in $elementos) {

                    if ($elemento.PSIsContainer) {

                        $lineas += "[CARPETA] $($elemento.Name)"
                    }
                    else {

                        $lineas += "[ARCHIVO] $($elemento.Name)"
                    }
                }

                return $lineas -join "`n"
            }
            catch {

                return $null
            }
        }

        default {

            return $null
        }
    }
}
