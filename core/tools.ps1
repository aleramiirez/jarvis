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
            Parametros = @(
                "aplicacion"
            )
        }

        @{
            Nombre = "abrir_carpeta"
            Descripcion = "Abre una carpeta permitida del sistema."
            Tipo = "accion"
            Parametros = @(
                "carpeta"
            )
        }

        @{
            Nombre = "informacion_sistema"
            Descripcion = "Obtiene informacion del ordenador y del sistema."
            Tipo = "consulta"
            Parametros = @()
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
