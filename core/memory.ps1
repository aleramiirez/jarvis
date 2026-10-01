# ============================================================
# JARVIS - MEMORIA
# ============================================================

# ============================================================
# MEMORIA DE CONVERSACION
# ============================================================

$script:JARVIS_HISTORIAL = @()

$script:JARVIS_MAX_HISTORIAL = 8

# ============================================================
# MEMORIA PERSONAL DE SESION
# ============================================================

$script:JARVIS_MEMORIAS_PERSONALES = @()

# ============================================================
# INICIALIZAR MEMORIA
# ============================================================

function Inicializar-Memoria {

    $script:JARVIS_HISTORIAL = @()
    $script:JARVIS_MEMORIAS_PERSONALES = @()
}

# ============================================================
# LIMPIAR CONVERSACION
# ============================================================

function Limpiar-Memoria {

    $script:JARVIS_HISTORIAL = @()
}

# ============================================================
# LIMPIAR MEMORIA PERSONAL
# ============================================================

function Limpiar-Memorias-Personales {

    $script:JARVIS_MEMORIAS_PERSONALES = @()
}

# ============================================================
# AÑADIR MENSAJE
# ============================================================

function Agregar-Mensaje-Memoria {

    param (
        [Parameter(Mandatory = $true)]
        [string]$Rol,

        [Parameter(Mandatory = $true)]
        [string]$Mensaje
    )

    if ([string]::IsNullOrWhiteSpace($Mensaje)) {

        return
    }

    $script:JARVIS_HISTORIAL += [PSCustomObject]@{
        Rol = $Rol
        Mensaje = $Mensaje
    }

    # ========================================================
    # LIMITAR HISTORIAL
    # ========================================================

    if (
        $script:JARVIS_HISTORIAL.Count -gt
        $script:JARVIS_MAX_HISTORIAL
    ) {

        $inicio = (
            $script:JARVIS_HISTORIAL.Count -
            $script:JARVIS_MAX_HISTORIAL
        )

        $script:JARVIS_HISTORIAL =
            @(
                $script:JARVIS_HISTORIAL[
                    $inicio..(
                        $script:JARVIS_HISTORIAL.Count - 1
                    )
                ]
            )
    }
}

# ============================================================
# OBTENER HISTORIAL
# ============================================================

function Obtener-Historial-Memoria {

    return @($script:JARVIS_HISTORIAL)
}

# ============================================================
# OBTENER HISTORIAL FORMATEADO
# ============================================================

function Obtener-Historial-Formateado {

    if ($script:JARVIS_HISTORIAL.Count -eq 0) {

        return "No hay historial de conversacion."
    }

    $lineas = @()

    foreach ($mensaje in $script:JARVIS_HISTORIAL) {

        switch ($mensaje.Rol) {

            "usuario" {

                $lineas += "USUARIO: $($mensaje.Mensaje)"
            }

            "jarvis" {

                $lineas += "JARVIS: $($mensaje.Mensaje)"
            }

            "herramienta" {

                $lineas += "RESULTADO DE HERRAMIENTA: $($mensaje.Mensaje)"
            }

            default {

                $lineas += "$($mensaje.Rol.ToUpper()): $($mensaje.Mensaje)"
            }
        }
    }

    return $lineas -join "`n"
}

# ============================================================
# COMPROBAR SI UNA MEMORIA ES SEGURA PARA GUARDAR
# ============================================================

function Puede-Guardar-Memoria-Personal {

    param (
        [Parameter(Mandatory = $true)]
        [string]$Clave,

        [Parameter(Mandatory = $true)]
        [string]$Valor
    )

    if (
        [string]::IsNullOrWhiteSpace($Clave) -or
        [string]::IsNullOrWhiteSpace($Valor)
    ) {

        return $false
    }

    $texto = Normalizar-Texto "$Clave $Valor"

    $terminosSensibles = @(
        "contrasena"
        "password"
        "passwd"
        "token"
        "api key"
        "apikey"
        "clave privada"
        "secret"
        "secreto"
        "tarjeta bancaria"
        "numero de tarjeta"
        "cvv"
        "pin"
        "dni"
        "pasaporte"
    )

    foreach ($termino in $terminosSensibles) {

        if ($texto.Contains($termino)) {

            return $false
        }
    }

    return $true
}

# ============================================================
# AÑADIR MEMORIA PERSONAL
# ============================================================

function Agregar-Memoria-Personal {

    param (
        [Parameter(Mandatory = $true)]
        [string]$Tipo,

        [Parameter(Mandatory = $true)]
        [string]$Clave,

        [Parameter(Mandatory = $true)]
        [string]$Valor
    )

    if (-not (Puede-Guardar-Memoria-Personal $Clave $Valor)) {

        return $false
    }

    $existente = $script:JARVIS_MEMORIAS_PERSONALES |
        Where-Object {
            $_.Clave -eq $Clave
        } |
        Select-Object -First 1

    if ($null -ne $existente) {

        $existente.Tipo = $Tipo
        $existente.Valor = $Valor

        return $true
    }

    $script:JARVIS_MEMORIAS_PERSONALES += [PSCustomObject]@{
        Tipo = $Tipo
        Clave = $Clave
        Valor = $Valor
    }

    return $true
}

# ============================================================
# OBTENER MEMORIAS PERSONALES
# ============================================================

function Obtener-Memorias-Personales {

    return @($script:JARVIS_MEMORIAS_PERSONALES)
}

# ============================================================
# OBTENER MEMORIAS PERSONALES FORMATEADAS
# ============================================================

function Obtener-Memorias-Personales-Formateadas {

    if ($script:JARVIS_MEMORIAS_PERSONALES.Count -eq 0) {

        return "No hay memorias personales guardadas."
    }

    $lineas = @()

    foreach ($memoria in $script:JARVIS_MEMORIAS_PERSONALES) {

        $lineas += "$($memoria.Tipo): $($memoria.Clave) = $($memoria.Valor)"
    }

    return $lineas -join "`n"
}
