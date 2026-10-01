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
                    $_.FullName -notmatch '\\data\\' -and
                    $_.Name -notmatch '_backup\.' -and
                    $_.Name -notmatch '\.bak$' -and
                    $_.Name -notmatch '\.tmp$'
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
                            $_.FullName -notmatch '\\data\\' -and
                            $_.Name -notmatch '_backup\.' -and
                            $_.Name -notmatch '\.bak$' -and
                            $_.Name -notmatch '\.tmp$'
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

                $mejor = $resultados[0]

                $lineas += "Mejor coincidencia:"
                $lineas += "[ARCHIVO] $($mejor.Ruta)"

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

# ============================================================
# LEER ARCHIVO
# ============================================================

function Leer-Archivo {

    param (
        [Parameter(Mandatory = $true)]
        [string]$Carpeta,

        [Parameter(Mandatory = $true)]
        [string]$RutaArchivo
    )

    switch ($Carpeta.ToLower()) {

        "jarvis" {

            $rutaBase = "C:\dev\proyectos\jarvis"

            if (-not (Test-Path $rutaBase -PathType Container)) {

                return $null
            }

            if ([string]::IsNullOrWhiteSpace($RutaArchivo)) {

                return $null
            }

            # =================================================
            # NORMALIZAR SEPARADORES
            # =================================================

            $rutaRelativa = $RutaArchivo.Trim().Replace(
                "/",
                "\"
            )

            # =================================================
            # SEGURIDAD
            # =================================================

            if (
                [System.IO.Path]::IsPathRooted($rutaRelativa) -or
                $rutaRelativa.Contains("..") -or
                $rutaRelativa.StartsWith("\")
            ) {

                return $null
            }

            $rutaCompleta = Join-Path `
                $rutaBase `
                $rutaRelativa

            # =================================================
            # VERIFICAR QUE SEA UN ARCHIVO REAL
            # =================================================

            if (-not (Test-Path $rutaCompleta -PathType Leaf)) {

                return $null
            }

            # =================================================
            # VERIFICAR UBICACION PERMITIDA
            # =================================================

            $rutaCompletaNormalizada =
                [System.IO.Path]::GetFullPath($rutaCompleta)

            $rutaBaseNormalizada =
                [System.IO.Path]::GetFullPath($rutaBase).TrimEnd(
                    "\"
                )

            $rutaComparacion =
                $rutaCompletaNormalizada.ToLower()

            $baseComparacion =
                $rutaBaseNormalizada.ToLower()

            if (
                -not $rutaComparacion.StartsWith(
                    "$baseComparacion\"
                )
            ) {

                return $null
            }

            if (
                $rutaComparacion.Contains("\.git\") -or
                $rutaComparacion.Contains("\data\")
            ) {

                return $null
            }

            # =================================================
            # LIMITE DE TAMAÑO
            # =================================================

            try {

                $archivo = Get-Item $rutaCompleta

                $maxBytes = 256KB

                if ($archivo.Length -gt $maxBytes) {

                    return "El archivo '$rutaRelativa' es demasiado grande para mostrarlo completo. Tamaño: $([math]::Round($archivo.Length / 1KB, 2)) KB."
                }

                # =================================================
                # LEER COMO UTF-8
                # =================================================

                $contenido = [System.IO.File]::ReadAllText(
                    $rutaCompleta,
                    [System.Text.UTF8Encoding]::new($false)
                )

                if ([string]::IsNullOrWhiteSpace($contenido)) {

                    return "El archivo '$rutaRelativa' esta vacio."
                }

                return $contenido
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
# BUSCAR CONTENIDO
# ============================================================

function Buscar-Contenido {

    param (
        [Parameter(Mandatory = $true)]
        [string]$Carpeta,

        [Parameter(Mandatory = $true)]
        [string]$Consulta
    )

    switch ($Carpeta.ToLower()) {

        "jarvis" {

            $rutaBase = "C:\dev\proyectos\jarvis"

            if (-not (Test-Path $rutaBase -PathType Container)) {

                return $null
            }

            if ([string]::IsNullOrWhiteSpace($Consulta)) {

                return $null
            }

            # =================================================
            # LIMITAR CONSULTA
            # =================================================

            $consulta = $Consulta.Trim()

            if ($consulta.Length -gt 200) {

                $consulta = $consulta.Substring(0, 200)
            }

            $consultaNormalizada = Normalizar-Texto $consulta

            # =================================================
            # PALABRAS GENERICAS QUE NO APORTAN A LA BUSQUEDA
            # =================================================

            $palabrasIgnoradas = @(
                "donde",
                "como",
                "cuando",
                "quien",
                "cual",
                "que",
                "para",
                "por",
                "con",
                "sin",
                "del",
                "las",
                "los",
                "una",
                "uno",
                "unos",
                "unas",
                "esta",
                "este",
                "estos",
                "estas",
                "hay",
                "hace",
                "hacer",
                "entre",
                "desde",
                "sobre",
                "dentro",
                "aparece",
                "encuentra",
                "buscar",
                "busca",
                "quiero",
                "necesito",
                "puedes",
                "juntos"
            )

            $tokens = @(
                $consultaNormalizada -split '\s+' |
                    Where-Object {
                        $_.Length -ge 2 -and
                        $_ -notin $palabrasIgnoradas
                    }
            )

            if ($tokens.Count -eq 0) {

                $tokens = @(
                    $consultaNormalizada -split '\s+' |
                        Where-Object {
                            $_.Length -ge 2
                        }
                )
            }

            if ($tokens.Count -eq 0) {

                return "No he podido obtener un termino valido para buscar."
            }

            # =================================================
            # EXTENSIONES PERMITIDAS
            # =================================================

            $extensionesPermitidas = @(
                ".ps1",
                ".psm1",
                ".txt",
                ".md",
                ".json",
                ".yaml",
                ".yml",
                ".xml",
                ".js",
                ".ts",
                ".jsx",
                ".tsx"
            )

            # =================================================
            # OBTENER ARCHIVOS
            # =================================================

            try {

                $archivos = @(
                    Get-ChildItem `
                        -Path $rutaBase `
                        -Recurse `
                        -File `
                        -Force `
                        -ErrorAction Stop |
                        Where-Object {

                            $_.FullName -notmatch '\\\.git\\' -and
                            $_.FullName -notmatch '\\data\\' -and
                            $_.Name -notmatch '_backup\.' -and
                            $_.Name -notmatch '\.bak$' -and
                            $_.Name -notmatch '\.tmp$' -and
                            $extensionesPermitidas -contains $_.Extension.ToLower()
                        }
                )
            }
            catch {

                return $null
            }

            # =================================================
            # BUSCAR COINCIDENCIAS
            # =================================================

            $resultados = @()

            foreach ($archivo in $archivos) {

                try {

                    if ($archivo.Length -gt 512KB) {

                        continue
                    }

                    $lineasArchivo = [System.IO.File]::ReadAllLines(
                        $archivo.FullName,
                        [System.Text.UTF8Encoding]::new($false)
                    )
                }
                catch {

                    continue
                }

                $enHereString = $false
                $numeroLinea = 0

                foreach ($linea in $lineasArchivo) {

                    $numeroLinea++

                    # =================================================
                    # DETECTAR BLOQUES HERE-STRING
                    #
                    # Estos bloques son usados por JARVIS para guardar
                    # prompts largos. No queremos que sus ejemplos,
                    # instrucciones o textos internos contaminen una
                    # busqueda de codigo.
                    # =================================================

                    if (-not $enHereString) {

                        if ($linea -match '@["'']\s*$') {

                            $enHereString = $true
                            continue
                        }
                    }
                    else {

                        if ($linea -match '^\s*["'']@') {

                            $enHereString = $false
                        }

                        continue
                    }

                    if ([string]::IsNullOrWhiteSpace($linea)) {

                        continue
                    }

                    $lineaNormalizada = Normalizar-Texto $linea

                    $puntuacion = 0

                    # =================================================
                    # COINCIDENCIA EXACTA
                    # =================================================

                    if (
                        $lineaNormalizada.Contains(
                            $consultaNormalizada
                        )
                    ) {

                        $puntuacion = 1000
                    }
                    else {

                        # =============================================
                        # COINCIDENCIA POR TOKENS
                        # =============================================

                        $coincidencias = 0

                        foreach ($token in $tokens) {

                            if (
                                $lineaNormalizada.Contains(
                                    $token
                                )
                            ) {

                                $coincidencias++
                            }
                        }

                        if ($tokens.Count -eq 1) {

                            if ($coincidencias -eq 1) {

                                $puntuacion = 650
                            }
                        }
                        elseif (
                            $coincidencias -eq $tokens.Count
                        ) {

                            $puntuacion = 700
                        }
                    }

                    if ($puntuacion -eq 0) {

                        continue
                    }

                    # =================================================
                    # MEJORAR EL RANKING PARA CODIGO REAL
                    # =================================================

                    $lineaTrim = $linea.Trim()

                    # Los comentarios son menos prioritarios que
                    # las lineas ejecutables.
                    if ($lineaTrim.StartsWith("#")) {

                        $puntuacion -= 250
                    }

                    # Las declaraciones de funciones son especialmente
                    # interesantes para busquedas de codigo.
                    if (
                        $lineaNormalizada.StartsWith("function ")
                    ) {

                        $puntuacion += 150
                    }

                    # Variables, asignaciones y llamadas suelen
                    # representar codigo real.
                    if (
                        $linea.Contains("=") -or
                        $lineaNormalizada.Contains(
                            "invokerestmethod"
                        )
                    ) {

                        $puntuacion += 100
                    }

                    if (
                        $linea.Contains("$")
                    ) {

                        $puntuacion += 50
                    }

                    # =================================================
                    # RUTA RELATIVA
                    # =================================================

                    $rutaRelativa =
                        $archivo.FullName.Substring(
                            $rutaBase.Length
                        ).TrimStart("\")

                    # =================================================
                    # GUARDAR RESULTADO
                    # =================================================

                    $contenidoMostrar = $linea.Trim()

                    if ($contenidoMostrar.Length -gt 220) {

                        $contenidoMostrar =
                            $contenidoMostrar.Substring(0, 220) + "..."
                    }

                    $resultados += [PSCustomObject]@{
                        Ruta = $rutaRelativa
                        Linea = $numeroLinea
                        Contenido = $contenidoMostrar
                        Puntuacion = $puntuacion
                    }
                }
            }

            # =================================================
            # ORDENAR Y LIMITAR
            # =================================================

            $resultados = @(
                $resultados |
                    Sort-Object `
                        @{ Expression = "Puntuacion"; Descending = $true },
                        @{ Expression = "Ruta"; Descending = $false },
                        @{ Expression = "Linea"; Descending = $false } |
                    Select-Object -First 20
            )

            # =================================================
            # SIN RESULTADOS
            # =================================================

            if ($resultados.Count -eq 0) {

                return "No he encontrado ninguna coincidencia para '$Consulta'."
            }

            # =================================================
            # FORMATEAR RESULTADOS
            # =================================================

            $lineasResultado = @()

            $lineasResultado += "Coincidencias encontradas: $($resultados.Count)"
            $lineasResultado += ""

            foreach ($resultado in $resultados) {

                $lineasResultado += "[ARCHIVO] $($resultado.Ruta)"
                $lineasResultado += "[LINEA] $($resultado.Linea)"
                $lineasResultado += "[CONTENIDO] $($resultado.Contenido)"
                $lineasResultado += ""
            }

            if ($resultados.Count -eq 20) {

                $lineasResultado += "Se muestran los primeros 20 resultados."
            }

            return $lineasResultado -join "`n"
        }

        default {

            return $null
        }
    }
}