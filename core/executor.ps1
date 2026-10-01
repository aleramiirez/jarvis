# ============================================================
# JARVIS - EJECUTOR CENTRAL DE HERRAMIENTAS
# ============================================================

function Ejecutar-Herramienta {

    param (
        [Parameter(Mandatory = $true)]
        [string]$Nombre,

        [Parameter(Mandatory = $false)]
        [string]$Objetivo = ""
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
                Error = "La aplicacion '$Objetivo' no esta permitida."
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
                Error = "La carpeta '$Objetivo' no esta permitida."
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
