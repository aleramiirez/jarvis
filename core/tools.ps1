# ============================================================
# JARVIS - REGISTRO DE HERRAMIENTAS
# ============================================================

# ============================================================
# OBTENER HERRAMIENTAS DISPONIBLES
# ============================================================

function Obtener-Herramientas {

    return @(
        @{
            Nombre = "abrir_aplicacion"
            Descripcion = "Abre una aplicacion permitida de Windows."
            Tipo = "accion"
            Capacidades = @(
                "abrir aplicaciones de Windows"
            )
            RequiereConfirmacion = $false

            Parametros = @(
                @{
                    Nombre = "aplicacion"
                    Tipo = "string"
                    Requerido = $true
                    Descripcion = "Identificador de la aplicacion que se quiere abrir."
                }
            )

            Objetivos = @(
                @{
                    Nombre = "notepad"
                    Descripcion = "Bloc de notas de Windows."
                    Alias = @(
                        "bloc de notas"
                        "notepad"
                    )
                    Respuesta = "Entendido. Voy a abrir el Bloc de notas."
                }

                @{
                    Nombre = "calc"
                    Descripcion = "Calculadora de Windows."
                    Alias = @(
                        "calculadora"
                        "abre calc"
                        "abrir calc"
                    )
                    Respuesta = "Entendido. Voy a abrir la Calculadora."
                }

                @{
                    Nombre = "mspaint"
                    Descripcion = "Microsoft Paint."
                    Alias = @(
                        "abre paint"
                        "abrir paint"
                        "paint"
                    )
                    Respuesta = "Entendido. Voy a abrir Paint."
                }

                @{
                    Nombre = "cmd"
                    Descripcion = "Consola de comandos de Windows."
                    Alias = @(
                        "abre cmd"
                        "abrir cmd"
                    )
                    Respuesta = "Entendido. Voy a abrir CMD."
                }

                @{
                    Nombre = "powershell"
                    Descripcion = "PowerShell de Windows."
                    Alias = @(
                        "abre powershell"
                        "abrir powershell"
                    )
                    Respuesta = "Entendido. Voy a abrir PowerShell."
                }

                @{
                    Nombre = "explorer"
                    Descripcion = "Explorador de archivos de Windows."
                    Alias = @(
                        "abre el explorador"
                        "abre explorador"
                        "abrir el explorador"
                        "abrir explorador"
                    )
                    Respuesta = "Entendido. Voy a abrir el Explorador."
                }
            )
        }

        @{
            Nombre = "abrir_carpeta"
            Descripcion = "Abre una carpeta permitida del sistema."
            Tipo = "accion"
            Capacidades = @(
                "abrir carpetas permitidas del sistema"
            )
            RequiereConfirmacion = $false

            Parametros = @(
                @{
                    Nombre = "carpeta"
                    Tipo = "string"
                    Requerido = $true
                    Descripcion = "Identificador de la carpeta que se quiere abrir."
                }
            )

            Objetivos = @(
                @{
                    Nombre = "jarvis"
                    Descripcion = "Carpeta del proyecto JARVIS."
                    Alias = @(
                        "proyecto de jarvis"
                        "proyecto jarvis"
                        "carpeta de jarvis"
                        "carpeta jarvis"
                    )
                    Respuesta = "Entendido. Voy a abrir el proyecto JARVIS."
                }
            )
        }

        @{
            Nombre = "informacion_sistema"
            Descripcion = "Obtiene informacion del ordenador y del sistema."
            Tipo = "consulta"
            Capacidades = @(
                "consultar la hora"
                "consultar la fecha"
                "consultar el nombre del ordenador"
                "consultar la memoria RAM"
                "consultar el procesador"
                "consultar el sistema operativo"
                "consultar el modelo del ordenador"
            )
            RequiereConfirmacion = $false

            Parametros = @(
                @{
                    Nombre = "consulta"
                    Tipo = "string"
                    Requerido = $true
                    Descripcion = "Pregunta sobre la informacion del sistema que se quiere obtener."
                }
            )

            Objetivos = @()
        }
    )
}

# ============================================================
# BUSCAR UNA HERRAMIENTA
# ============================================================

function Obtener-Herramienta {

    param (
        [Parameter(Mandatory = $true)]
        [string]$Nombre
    )

    $herramientas = Obtener-Herramientas

    foreach ($herramienta in $herramientas) {

        if ($herramienta.Nombre -eq $Nombre) {

            return $herramienta
        }
    }

    return $null
}

# ============================================================
# COMPROBAR SI EXISTE UNA HERRAMIENTA
# ============================================================

function Existe-Herramienta {

    param (
        [Parameter(Mandatory = $true)]
        [string]$Nombre
    )

    return $null -ne (Obtener-Herramienta $Nombre)
}

# ============================================================
# BUSCAR UN OBJETIVO DE UNA HERRAMIENTA
# ============================================================

function Obtener-Objetivo-Herramienta {

    param (
        [Parameter(Mandatory = $true)]
        [string]$Herramienta,

        [Parameter(Mandatory = $true)]
        [string]$Objetivo
    )

    $herramientaRegistrada = Obtener-Herramienta $Herramienta

    if ($null -eq $herramientaRegistrada) {

        return $null
    }

    foreach ($objetivoRegistrado in $herramientaRegistrada.Objetivos) {

        if ($objetivoRegistrado.Nombre -eq $Objetivo) {

            return $objetivoRegistrado
        }
    }

    return $null
}

# ============================================================
# COMPROBAR SI EXISTE UN OBJETIVO
# ============================================================

function Existe-Objetivo-Herramienta {

    param (
        [Parameter(Mandatory = $true)]
        [string]$Herramienta,

        [Parameter(Mandatory = $true)]
        [string]$Objetivo
    )

    return $null -ne (
        Obtener-Objetivo-Herramienta `
            $Herramienta `
            $Objetivo
    )
}

# ============================================================
# OBTENER ESQUEMA DE HERRAMIENTAS
# ============================================================

function Obtener-Esquema-Herramientas {

    $herramientas = Obtener-Herramientas

    return $herramientas
}
