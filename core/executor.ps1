# ============================================================
# JARVIS - EJECUTOR CENTRAL DE HERRAMIENTAS
# ============================================================

function Ejecutar-Herramienta {

    param (
        [Parameter(Mandatory = $true)]
        [string]$Nombre,

        [Parameter(Mandatory = $false)]
        [string]$Objetivo = "",

        [Parameter(Mandatory = $false)]
        [hashtable]$Parametros = @{}
    )

    # ========================================================
    # VALIDAR QUE LA HERRAMIENTA EXISTE
    # ========================================================

    if (-not (Existe-Herramienta $Nombre)) {

        return @{
            Exito = $false
            Error = "La herramienta '$Nombre' no esta registrada."
        }
    }

    # ========================================================
    # VALIDAR OBJETIVO
    # ========================================================

    if (
        -not [string]::IsNullOrWhiteSpace($Objetivo) -and
        -not (Existe-Objetivo-Herramienta $Nombre $Objetivo)
    ) {

        return @{
            Exito = $false
            Error = "El objetivo '$Objetivo' no esta permitido para la herramienta '$Nombre'."
        }
    }

    # ========================================================
    # EJECUTAR HERRAMIENTA
    # ========================================================

    switch ($Nombre) {

        "abrir_aplicacion" {

            $resultado = Abrir-Aplicacion $Objetivo

            if ($resultado) {

                return @{
                    Exito = $true
                    Resultado = $null
                }
            }

            return @{
                Exito = $false
                Error = "No se ha podido abrir la aplicacion '$Objetivo'."
            }
        }

        "abrir_carpeta" {

            $resultado = Abrir-Carpeta $Objetivo

            if ($resultado) {

                return @{
                    Exito = $true
                    Resultado = $null
                }
            }

            return @{
                Exito = $false
                Error = "No se ha podido abrir la carpeta '$Objetivo'."
            }
        }

        "listar_carpeta" {

            $resultado = Listar-Carpeta $Objetivo

            if ($null -ne $resultado) {

                return @{
                    Exito = $true
                    Resultado = $resultado
                }
            }

            return @{
                Exito = $false
                Error = "No se ha podido consultar la carpeta '$Objetivo'."
            }
        }

        "buscar_archivo" {

            if (
                -not $Parametros.ContainsKey("consulta") -or
                [string]::IsNullOrWhiteSpace(
                    [string]$Parametros["consulta"]
                )
            ) {

                return @{
                    Exito = $false
                    Error = "La herramienta buscar_archivo necesita el parametro 'consulta'."
                }
            }

            $consulta = [string]$Parametros["consulta"]

            $resultado = Buscar-Archivo `
                $Objetivo `
                $consulta

            if ($null -ne $resultado) {

                return @{
                    Exito = $true
                    Resultado = $resultado
                }
            }

            return @{
                Exito = $false
                Error = "No se ha podido realizar la busqueda."
            }
        }

        "leer_archivo" {

            if (
                -not $Parametros.ContainsKey("ruta") -or
                [string]::IsNullOrWhiteSpace(
                    [string]$Parametros["ruta"]
                )
            ) {

                return @{
                    Exito = $false
                    Error = "La herramienta leer_archivo necesita el parametro 'ruta'."
                }
            }

            $ruta = [string]$Parametros["ruta"]

            $resultado = Leer-Archivo `
                $Objetivo `
                $ruta

            if ($null -ne $resultado) {

                return @{
                    Exito = $true
                    Resultado = $resultado
                }
            }

            return @{
                Exito = $false
                Error = "No se ha podido leer el archivo solicitado."
            }
        }

        "analizar_archivo" {

            if (
                -not $Parametros.ContainsKey("ruta") -or
                [string]::IsNullOrWhiteSpace(
                    [string]$Parametros["ruta"]
                )
            ) {

                return @{
                    Exito = $false
                    Error = "La herramienta analizar_archivo necesita el parametro 'ruta'."
                }
            }

            $ruta = [string]$Parametros["ruta"]

            # =================================================
            # PASO 1: LEER ARCHIVO REAL
            # =================================================

            $contenido = Leer-Archivo `
                $Objetivo `
                $ruta

            if ($null -eq $contenido) {

                return @{
                    Exito = $false
                    Error = "No se ha podido leer el archivo que se quiere analizar."
                }
            }

            # =================================================
            # PASO 2: ANALIZAR CONTENIDO REAL CON IA
            # =================================================

            $resultadoAnalisis = Analizar-Contenido-Con-IA `
                $ruta `
                $contenido

            if (-not $resultadoAnalisis.Exito) {

                return @{
                    Exito = $false
                    Error = $resultadoAnalisis.Error
                }
            }

            return @{
                Exito = $true
                Resultado = $resultadoAnalisis.Resultado
            }
        }

        "buscar_contenido" {

            if (
                -not $Parametros.ContainsKey("consulta") -or
                [string]::IsNullOrWhiteSpace(
                    [string]$Parametros["consulta"]
                )
            ) {

                return @{
                    Exito = $false
                    Error = "La herramienta buscar_contenido necesita el parametro 'consulta'."
                }
            }

            $consulta = [string]$Parametros["consulta"]

            $resultado = Buscar-Contenido `
                $Objetivo `
                $consulta

            if ($null -ne $resultado) {

                return @{
                    Exito = $true
                    Resultado = $resultado
                }
            }

            return @{
                Exito = $false
                Error = "No se ha podido buscar dentro del contenido del proyecto."
            }
        }

        "informacion_sistema" {

            $resultado = Obtener-InformacionSistema $Objetivo

            if ($null -ne $resultado) {

                return @{
                    Exito = $true
                    Resultado = $resultado
                }
            }

            return @{
                Exito = $false
                Error = "No he podido obtener la informacion solicitada."
            }
        }

        default {

            return @{
                Exito = $false
                Error = "La herramienta '$Nombre' no tiene un ejecutor definido."
            }
        }
    }
}