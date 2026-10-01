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

                $elementos = @(
                    Get-ChildItem `
                        -Path $ruta `
                        -Force |
                        Sort-Object `
                            @{ Expression = "PSIsContainer"; Descending = $true },
                            Name
                )

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

# ============================================================
# BUSCAR ARCHIVO
# ============================================================

function Buscar-Archivo {

    param (
        [Parameter(Mandatory = $true)]
        [string]$Carpeta,

        [Parameter(Mandatory = $true)]
        [string]$Consulta
    )

    switch ($Carpeta.ToLower()) {

        "jarvis" {

            $ruta = "C:\dev\proyectos\jarvis"

            if (-not (Test-Path $ruta -PathType Container)) {

                return $null
            }

            if ([string]::IsNullOrWhiteSpace($Consulta)) {

                return $null
            }

            # =================================================
            # SEGURIDAD
            # =================================================

            if (
                $Consulta.Contains("\") -or
                $Consulta.Contains("/") -or
                $Consulta.Contains("..")
            ) {

                return $null
            }

            try {

                $patron = "*$Consulta*"

                $elementos = @(
                    Get-ChildItem `
                        -Path $ruta `
                        -Recurse `
                        -File `
                        -Force `
                        -Filter $patron `
                        -ErrorAction Stop |
                        Where-Object {
                            $_.FullName -notmatch '\\\.git\\' -and
                            $_.FullName -notmatch '\\data\\'
                        } |
                        Select-Object -First 20
                )

                if ($elementos.Count -eq 0) {

                    return "No he encontrado ningun archivo que coincida con '$Consulta'."
                }

                $lineas = @()

                foreach ($elemento in $elementos) {

                    $rutaRelativa = $elemento.FullName.Substring(
                        $ruta.Length
                    ).TrimStart("\")
                    
                    $lineas += "[ARCHIVO] $rutaRelativa"
                }

                if ($elementos.Count -eq 20) {

                    $lineas += ""
                    $lineas += "Se muestran los primeros 20 resultados."
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
