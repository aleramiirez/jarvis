# ============================================================
# JARVIS - REGISTRO DE HERRAMIENTAS
# ============================================================

function Obtener-Herramientas {

    return @(
        @{
            Nombre = "abrir_aplicacion"
            Descripcion = "Abre una aplicacion permitida de Windows."
            Tipo = "accion"
            Prioridad = 30

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
            Nombre = "listar_carpeta"
            Descripcion = "Lista los archivos y carpetas de una ubicacion permitida."
            Tipo = "consulta"
            Prioridad = 10

            Capacidades = @(
                "listar archivos"
                "listar carpetas"
                "consultar el contenido de una carpeta"
            )

            RequiereConfirmacion = $false

            Parametros = @(
                @{
                    Nombre = "carpeta"
                    Tipo = "string"
                    Requerido = $true
                    Descripcion = "Identificador de la carpeta cuyo contenido se quiere consultar."
                }
            )

            Objetivos = @(
                @{
                    Nombre = "jarvis"
                    Descripcion = "Carpeta del proyecto JARVIS."
                    Alias = @(
                        "que archivos hay en mi proyecto"
                        "que archivos hay en el proyecto"
                        "archivos del proyecto de jarvis"
                        "archivos del proyecto jarvis"
                        "archivos de jarvis"
                        "contenido del proyecto de jarvis"
                        "contenido del proyecto jarvis"
                        "que hay en la carpeta de jarvis"
                        "que hay en la carpeta jarvis"
                        "ensename que hay en la carpeta de jarvis"
                        "ensename que hay en la carpeta jarvis"
                        "muestrame que hay en la carpeta de jarvis"
                        "muestrame que hay en la carpeta jarvis"
                    )
                    Respuesta = "Claro. Voy a consultar el contenido del proyecto JARVIS."
                }
            )
        }

        @{
            Nombre = "buscar_archivo"
            Descripcion = "Busca archivos por nombre dentro de una ubicacion permitida."
            Tipo = "consulta"
            Prioridad = 15

            Capacidades = @(
                "buscar archivos por nombre"
                "localizar un archivo"
                "encontrar un archivo dentro de una carpeta"
            )

            RequiereConfirmacion = $false

            Parametros = @(
                @{
                    Nombre = "consulta"
                    Tipo = "string"
                    Requerido = $true
                    Descripcion = "Nombre o parte del nombre del archivo que se quiere buscar."
                }
            )

            Objetivos = @(
                @{
                    Nombre = "jarvis"
                    Descripcion = "Buscar dentro del proyecto JARVIS."
                    Alias = @()
                    Respuesta = "Claro. Voy a buscar ese archivo en el proyecto JARVIS."
                }
            )
        }

        @{
            Nombre = "leer_archivo"
            Descripcion = "Lee el contenido de un archivo permitido del proyecto."
            Tipo = "consulta"
            Prioridad = 16

            Capacidades = @(
                "leer archivos"
                "consultar el contenido de un archivo"
                "mostrar el codigo de un archivo"
                "examinar un archivo"
            )

            RequiereConfirmacion = $false

            Parametros = @(
                @{
                    Nombre = "ruta"
                    Tipo = "string"
                    Requerido = $true
                    Descripcion = "Ruta relativa de un archivo existente dentro del proyecto JARVIS."
                }
            )

            Objetivos = @(
                @{
                    Nombre = "jarvis"
                    Descripcion = "Proyecto JARVIS."
                    Alias = @()
                    Respuesta = "Claro. Voy a leer ese archivo del proyecto JARVIS."
                }
            )
        }

        @{
            Nombre = "analizar_archivo"
            Descripcion = "Lee un archivo permitido y utiliza la IA para explicar su contenido."
            Tipo = "consulta"
            Prioridad = 17

            Capacidades = @(
                "analizar archivos"
                "explicar que hace un archivo"
                "explicar codigo"
                "entender un archivo"
                "analizar codigo"
            )

            RequiereConfirmacion = $false

            Parametros = @(
                @{
                    Nombre = "ruta"
                    Tipo = "string"
                    Requerido = $true
                    Descripcion = "Ruta relativa de un archivo existente dentro del proyecto JARVIS."
                }
            )

            Objetivos = @(
                @{
                    Nombre = "jarvis"
                    Descripcion = "Proyecto JARVIS."
                    Alias = @()
                    Respuesta = "Claro. Voy a analizar ese archivo del proyecto JARVIS."
                }
            )
        }

        @{
            Nombre = "buscar_contenido"
            Descripcion = "Busca texto o conceptos dentro del contenido de los archivos permitidos del proyecto."
            Tipo = "consulta"
            Prioridad = 18

            Capacidades = @(
                "buscar texto dentro de archivos"
                "buscar funciones"
                "buscar clases"
                "buscar variables"
                "localizar codigo"
                "encontrar donde se hace algo"
            )

            RequiereConfirmacion = $false

            Parametros = @(
                @{
                    Nombre = "consulta"
                    Tipo = "string"
                    Requerido = $true
                    Descripcion = "Texto o termino tecnico que se quiere localizar dentro del codigo."
                }
            )

            Objetivos = @(
                @{
                    Nombre = "jarvis"
                    Descripcion = "Buscar dentro del contenido del proyecto JARVIS."
                    Alias = @()
                    Respuesta = "Claro. Voy a buscar eso dentro del codigo del proyecto JARVIS."
                }
            )
        }

        @{
            Nombre = "abrir_carpeta"
            Descripcion = "Abre una carpeta permitida del sistema."
            Tipo = "accion"
            Prioridad = 20

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
                        "abrir la carpeta de jarvis"
                        "abre la carpeta de jarvis"
                        "abre la carpeta jarvis"
                        "abrir carpeta jarvis"
                    )
                    Respuesta = "Entendido. Voy a abrir el proyecto JARVIS."
                }
            )
        }

        @{
            Nombre = "informacion_sistema"
            Descripcion = "Obtiene informacion del ordenador y del sistema."
            Tipo = "consulta"
            Prioridad = 5

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

    foreach ($herramienta in (Obtener-Herramientas)) {

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

    return Obtener-Herramientas
}