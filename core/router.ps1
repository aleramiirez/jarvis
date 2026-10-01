# ============================================================
# JARVIS - ROUTER DE PETICIONES RAPIDAS
# ============================================================

function Obtener-Ruta-Rapida {

    param (
        [Parameter(Mandatory = $true)]
        [string]$Mensaje
    )

    $texto = Normalizar-Texto $Mensaje
    $herramientas = Obtener-Herramientas

    # ========================================================
    # BUSCAR ENTRE LAS HERRAMIENTAS
    # ========================================================

    foreach ($herramienta in $herramientas) {

        if (
            $herramienta.Tipo -ne "accion" -or
            $null -eq $herramienta.Objetivos
        ) {

            continue
        }

        # ====================================================
        # BUSCAR ENTRE LOS OBJETIVOS
        # ====================================================

        foreach ($objetivo in $herramienta.Objetivos) {

            foreach ($alias in $objetivo.Alias) {

                if ($texto.Contains($alias)) {

                    return @{
                        Tipo = "accion"
                        Accion = $herramienta.Nombre
                        Objetivo = $objetivo.Nombre
                        Respuesta = $objetivo.Respuesta
                    }
                }
            }
        }
    }

    return $null
}
