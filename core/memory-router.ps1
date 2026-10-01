# ============================================================
# JARVIS - ROUTER DE MEMORIA
# ============================================================

function Obtener-Ruta-Memoria {

    param (
        [Parameter(Mandatory = $true)]
        [string]$Mensaje
    )

    $texto = Normalizar-Texto $Mensaje

    # ========================================================
    # MOSTRAR MEMORIAS
    # ========================================================

    if (
        $texto -match "que recuerdas de mi" -or
        $texto -match "que recuerdas sobre mi" -or
        $texto -match "que recuerdas" -or
        $texto -match "que sabes de mi"
    ) {

        return @{
            Tipo = "mostrar_memorias"
        }
    }

    # ========================================================
    # BORRAR TODAS LAS MEMORIAS
    # ========================================================

    if (
        $texto -match "olvida todo lo que recuerdas" -or
        $texto -match "olvida todo lo que sabes de mi" -or
        $texto -match "borra todas mis memorias" -or
        $texto -match "borra todas las memorias"
    ) {

        return @{
            Tipo = "limpiar_memorias"
        }
    }

    # ========================================================
    # BORRAR NOMBRE
    # ========================================================

    if (
        $texto -match "olvida mi nombre" -or
        $texto -match "olvida el nombre" -or
        $texto -match "borra mi nombre"
    ) {

        return @{
            Tipo = "eliminar_memoria"
            Clave = "nombre"
        }
    }

    # ========================================================
    # BORRAR UNA MEMORIA CONCRETA
    # ========================================================

    if (
        $texto -match "^olvida la memoria de (.+)$"
    ) {

        $clave = $Matches[1].Trim()

        return @{
            Tipo = "eliminar_memoria"
            Clave = $clave
        }
    }

    if (
        $texto -match "^olvida la memoria sobre (.+)$"
    ) {

        $clave = $Matches[1].Trim()

        return @{
            Tipo = "eliminar_memoria"
            Clave = $clave
        }
    }

    return $null
}
