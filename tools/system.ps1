# ============================================================
# JARVIS - HERRAMIENTAS DEL SISTEMA
# ============================================================

function Obtener-Hora {

    return Get-Date -Format "HH:mm:ss"
}


function Obtener-Fecha {

    return Get-Date -Format "dd/MM/yyyy"
}


function Obtener-NombreOrdenador {

    return $env:COMPUTERNAME
}


function Obtener-MemoriaRAM {

    try {

        $computerSystem = Get-CimInstance Win32_ComputerSystem

        $ramGB = [math]::Round(
            $computerSystem.TotalPhysicalMemory / 1GB,
            2
        )

        return "$ramGB GB"
    }
    catch {

        return $null
    }
}


function Obtener-Procesador {

    try {

        $procesador = Get-CimInstance Win32_Processor |
            Select-Object -First 1

        return $procesador.Name.Trim()
    }
    catch {

        return $null
    }
}


function Obtener-SistemaOperativo {

    try {

        $sistema = Get-CimInstance Win32_OperatingSystem

        return $sistema.Caption
    }
    catch {

        return $null
    }
}


function Obtener-ModeloOrdenador {

    try {

        $ordenador = Get-CimInstance Win32_ComputerSystem

        $fabricante = $ordenador.Manufacturer
        $modelo = $ordenador.Model

        if (
            -not [string]::IsNullOrWhiteSpace($fabricante) -and
            -not [string]::IsNullOrWhiteSpace($modelo)
        ) {

            return "$fabricante $modelo"
        }

        if (-not [string]::IsNullOrWhiteSpace($modelo)) {

            return $modelo
        }

        return $null
    }
    catch {

        return $null
    }
}


function Obtener-InformacionSistema {

    param (
        [Parameter(Mandatory = $true)]
        [string]$Mensaje
    )

    $texto = Normalizar-Texto $Mensaje

    # --------------------------------------------------------
    # HORA
    # --------------------------------------------------------

    if (
        $texto -match "que hora es" -or
        $texto -match "dime la hora" -or
        $texto -match "hora actual" -or
        $texto -match "hora tenemos"
    ) {

        $hora = Obtener-Hora

        return @{
            Tipo = "informacion"
            Texto = "Son las $hora."
        }
    }

    # --------------------------------------------------------
    # FECHA
    # --------------------------------------------------------

    if (
        $texto -match "que fecha es" -or
        $texto -match "que dia es" -or
        $texto -match "fecha de hoy" -or
        $texto -match "fecha actual"
    ) {

        $fecha = Obtener-Fecha

        return @{
            Tipo = "informacion"
            Texto = "Hoy es $fecha."
        }
    }

    # --------------------------------------------------------
    # NOMBRE DEL ORDENADOR
    # --------------------------------------------------------

    if (
        $texto -match "como se llama mi ordenador" -or
        $texto -match "como se llama mi pc" -or
        $texto -match "nombre de mi ordenador" -or
        $texto -match "nombre de mi pc" -or
        $texto -match "nombre del ordenador"
    ) {

        $nombre = Obtener-NombreOrdenador

        return @{
            Tipo = "informacion"
            Texto = "El nombre de tu ordenador es $nombre."
        }
    }

    # --------------------------------------------------------
    # RAM
    # --------------------------------------------------------

    if (
        $texto -match "cuanta ram tengo" -or
        $texto -match "cuanta memoria ram tengo" -or
        $texto -match "memoria ram" -or
        $texto -match "ram tengo" -or
        $texto -match "memoria tengo"
    ) {

        $ram = Obtener-MemoriaRAM

        if ($null -ne $ram) {

            return @{
                Tipo = "informacion"
                Texto = "Tu ordenador tiene $ram de memoria RAM."
            }
        }

        return @{
            Tipo = "informacion"
            Texto = "No he podido obtener la cantidad de RAM del sistema."
        }
    }

    # --------------------------------------------------------
    # PROCESADOR
    # --------------------------------------------------------

    if (
        $texto -match "que procesador tengo" -or
        $texto -match "que cpu tengo" -or
        $texto -match "procesador tengo" -or
        $texto -match "cpu tengo"
    ) {

        $procesador = Obtener-Procesador

        if ($null -ne $procesador) {

            return @{
                Tipo = "informacion"
                Texto = "Tu procesador es $procesador."
            }
        }

        return @{
            Tipo = "informacion"
            Texto = "No he podido obtener la informacion del procesador."
        }
    }

    # --------------------------------------------------------
    # SISTEMA OPERATIVO
    # --------------------------------------------------------

    if (
        $texto -match "que sistema operativo tengo" -or
        $texto -match "que windows tengo" -or
        $texto -match "que windows uso" -or
        $texto -match "sistema operativo tengo"
    ) {

        $sistema = Obtener-SistemaOperativo

        if ($null -ne $sistema) {

            return @{
                Tipo = "informacion"
                Texto = "Estas utilizando $sistema."
            }
        }

        return @{
            Tipo = "informacion"
            Texto = "No he podido obtener la informacion del sistema operativo."
        }
    }

    # --------------------------------------------------------
    # MODELO DEL ORDENADOR
    # --------------------------------------------------------

    if (
        $texto -match "que ordenador tengo" -or
        $texto -match "que pc tengo" -or
        $texto -match "modelo de mi ordenador" -or
        $texto -match "modelo de mi pc"
    ) {

        $modelo = Obtener-ModeloOrdenador

        if ($null -ne $modelo) {

            return @{
                Tipo = "informacion"
                Texto = "Tu ordenador es un $modelo."
            }
        }

        return @{
            Tipo = "informacion"
            Texto = "No he podido determinar el modelo de tu ordenador."
        }
    }

    return $null
}
