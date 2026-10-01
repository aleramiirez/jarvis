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
# OBTENER INDICE DE ARCHIVOS DEL PROYECTO
# ============================================================

function Obtener-Archivos-Proyecto {

    $ruta = "C:\dev\proyectos\jarvis"

    if (-not (Test-Path $ruta -PathType Container)) {

        return @()
    }

    try {

        $archivos = @(
            Get-ChildItem `
                -Path $ruta `
                -Recurse `
                -File `
                -Force `
                -ErrorAction Stop |
                Where-Object {
                    $_.FullName -notmatch '\\\.git\\' -and
                    $_.FullName -notmatch '\\data\\'
                }
        )

        $resultado = @()

        foreach ($archivo in $archivos) {

            $rutaRelativa = $archivo.FullName.Substring(
                $ruta.Length
            ).TrimStart("\")

            $resultado += $rutaRelativa
        }

        return $resultado | Sort-Object
    }
    catch {

        return @()
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

                $consultaNormalizada = Normalizar-Texto $Consulta

                $elementos = @(
                    Get-ChildItem `
                        -Path $ruta `
                        -Recurse `
                        -File `
                        -Force `
                        -ErrorAction Stop |
                        Where-Object {
                            $_.FullName -notmatch '\\\.git\\' -and
                            $_.FullName -notmatch '\\data\\'
                        }
                )

                $resultados = @()

                foreach ($elemento in $elementos) {

                    $nombre = $elemento.Name
                    $nombreSinExtension =
                        [System.IO.Path]::GetFileNameWithoutExtension(
                            $nombre
                        )

                    $nombreNormalizado =
                        Normalizar-Texto $nombre

                    $nombreBaseNormalizado =
                        Normalizar-Texto $nombreSinExtension

                    $puntuacion = 0

                    # =================================================
                    # COINCIDENCIA EXACTA
                    # =================================================

                    if ($nombreNormalizado -eq $consultaNormalizada) {

                        $puntuacion = 1000
                    }
                    elseif (
                        $nombreBaseNormalizado -eq
                        $consultaNormalizada
                    ) {

                        $puntuacion = 950
                    }
                    elseif (
                        $nombreNormalizado.StartsWith(
                            $consultaNormalizada
                        )
                    ) {

                        $puntuacion = 800
                    }
                    elseif (
                        $nombreNormalizado.Contains(
                            $consultaNormalizada
                        )
                    ) {

                        $puntuacion = 700
                    }
                    else {

                        # =============================================
                        # COINCIDENCIA POR PALABRAS
                        # =============================================

                        $tokens = @(
                            $consultaNormalizada -split '\s+' |
                                Where-Object {
                                    $_.Length -ge 2
                                }
                        )

                        if ($tokens.Count -gt 0) {

                            $coincidencias = 0

                            foreach ($token in $tokens) {

                                if (
                                    $nombreNormalizado.Contains(
                                        $token
                                    )
                                ) {

                                    $coincidencias++
                                }
                            }

                            if ($coincidencias -eq $tokens.Count) {

                                $puntuacion = 650
                            }
                            elseif ($coincidencias -gt 0) {

                                $puntuacion =
                                    300 +
                                    ($coincidencias * 50)
                            }
                        }
                    }

                    if ($puntuacion -gt 0) {

                        $rutaRelativa =
                            $elemento.FullName.Substring(
                                $ruta.Length
                            ).TrimStart("\")

                        $resultados += [PSCustomObject]@{
                            Ruta = $rutaRelativa
                            Puntuacion = $puntuacion
                            Nombre = $elemento.Name
                        }
                    }
                }

                # =====================================================
                # ORDENAR RESULTADOS
                # =====================================================

                $resultados = @(
                    $resultados |
                        Sort-Object `
                            @{ Expression = "Puntuacion"; Descending = $true },
                            @{ Expression = "Ruta"; Descending = $false } |
                        Select-Object -First 20
                )

                if ($resultados.Count -eq 0) {

                    return "No he encontrado ningun archivo que coincida con '$Consulta'."
                }

                $lineas = @()

                # =====================================================
                # MEJOR COINCIDENCIA
                # =====================================================

                $mejor = $resultados[0]

                $lineas += "Mejor coincidencia:"
                $lineas += "[ARCHIVO] $($mejor.Ruta)"

                # =====================================================
                # OTRAS COINCIDENCIAS
                # =====================================================

                if ($resultados.Count -gt 1) {

                    $lineas += ""
                    $lineas += "Otras coincidencias:"

                    for (
                        $indice = 1;
                        $indice -lt $resultados.Count;
                        $indice++
                    ) {

                        $lineas += "[ARCHIVO] $($resultados[$indice].Ruta)"
                    }
                }

                if ($resultados.Count -eq 20) {

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
