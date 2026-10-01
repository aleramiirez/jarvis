# ============================================================
# JARVIS - MEMORIA DE CONVERSACION
# ============================================================

$script:JARVIS_HISTORIAL = @()

$script:JARVIS_MAX_HISTORIAL = 8

# ============================================================
# INICIALIZAR MEMORIA
# ============================================================

function Inicializar-Memoria {

    $script:JARVIS_HISTORIAL = @()
}

# ============================================================
# LIMPIAR MEMORIA
# ============================================================

function Limpiar-Memoria {

    $script:JARVIS_HISTORIAL = @()
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
    # LIMITAR TAMAÑO DEL HISTORIAL
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
