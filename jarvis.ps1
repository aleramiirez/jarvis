# ============================================================
# JARVIS - ASISTENTE LOCAL
# ============================================================

$utf8 = [System.Text.UTF8Encoding]::new($false)

[Console]::InputEncoding = $utf8
[Console]::OutputEncoding = $utf8
$OutputEncoding = $utf8

# ============================================================
# CARGAR CONFIGURACION
# ============================================================

. "$PSScriptRoot\config\config.ps1"

# ============================================================
# CARGAR UTILIDADES
# ============================================================

. "$PSScriptRoot\core\text.ps1"
. "$PSScriptRoot\core\tools.ps1"
. "$PSScriptRoot\core\router.ps1"
. "$PSScriptRoot\core\memory.ps1"
. "$PSScriptRoot\core\memory-router.ps1"
. "$PSScriptRoot\core\ai-router.ps1"

# ============================================================
# CARGAR HERRAMIENTAS
# ============================================================

. "$PSScriptRoot\tools\apps.ps1"
. "$PSScriptRoot\tools\folders.ps1"
. "$PSScriptRoot\tools\files.ps1"
. "$PSScriptRoot\tools\system.ps1"

# ============================================================
# CARGAR EJECUTOR
# ============================================================

. "$PSScriptRoot\core\executor.ps1"

# ============================================================
# INICIALIZAR MEMORIA
# ============================================================

Inicializar-Memoria

# ============================================================
# CABECERA
# ============================================================

Clear-Host

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "        JARVIS - ASISTENTE LOCAL" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

$herramientas = Obtener-Herramientas

Write-Host "Herramientas cargadas: $($herramientas.Count)" `
    -ForegroundColor DarkGray

Write-Host ""
Write-Host "Memoria de conversacion: activa" `
    -ForegroundColor DarkGray

Write-Host "Memoria personal: activa" `
    -ForegroundColor DarkGray

Write-Host ""
Write-Host "Escribe '/salir' para terminar." -ForegroundColor DarkGray
Write-Host "Escribe '/limpiar' para borrar la conversacion." `
    -ForegroundColor DarkGray
Write-Host "Escribe '/memorias' para ver las memorias personales." `
    -ForegroundColor DarkGray
Write-Host "Escribe '/olvidar-memorias' para borrarlas." `
    -ForegroundColor DarkGray
Write-Host ""

# ============================================================
# BUCLE PRINCIPAL
# ============================================================

while ($true) {

    $mensaje = Read-Host "TU"

    if ([string]::IsNullOrWhiteSpace($mensaje)) {

        continue
    }

    $mensajeNormalizado = Normalizar-Texto $mensaje

    # ========================================================
    # SALIR
    # ========================================================

    if ($mensajeNormalizado -eq "/salir") {

        Write-Host ""
        Write-Host "JARVIS: Hasta luego, Ale." -ForegroundColor Cyan
        break
    }

    # ========================================================
    # LIMPIAR CONVERSACION
    # ========================================================

    if ($mensajeNormalizado -eq "/limpiar") {

        Limpiar-Memoria

        Write-Host ""
        Write-Host "JARVIS: He borrado la memoria de la conversacion." `
            -ForegroundColor Cyan
        Write-Host ""

        continue
    }

    # ========================================================
    # MOSTRAR MEMORIAS - COMANDO
    # ========================================================

    if ($mensajeNormalizado -eq "/memorias") {

        Write-Host ""
        Write-Host "JARVIS: Estas son mis memorias personales:" `
            -ForegroundColor Cyan

        Write-Host ""

        $memorias = Obtener-Memorias-Personales

        if ($memorias.Count -eq 0) {

            Write-Host "No hay memorias personales guardadas." `
                -ForegroundColor DarkGray
        }
        else {

            foreach ($memoria in $memorias) {

                Write-Host "- $($memoria.Clave): $($memoria.Valor)"
            }
        }

        Write-Host ""

        continue
    }

    # ========================================================
    # OLVIDAR MEMORIAS - COMANDO
    # ========================================================

    if ($mensajeNormalizado -eq "/olvidar-memorias") {

        Limpiar-Memorias-Personales

        Write-Host ""
        Write-Host "JARVIS: He borrado todas las memorias personales." `
            -ForegroundColor Cyan
        Write-Host ""

        continue
    }

    # ========================================================
    # ROUTER NATURAL DE MEMORIA
    # ========================================================

    $rutaMemoria = Obtener-Ruta-Memoria $mensaje

    if ($null -ne $rutaMemoria) {

        # ----------------------------------------------------
        # MOSTRAR MEMORIAS
        # ----------------------------------------------------

        if ($rutaMemoria.Tipo -eq "mostrar_memorias") {

            Write-Host ""
            Write-Host "JARVIS: Estas son mis memorias personales:" `
                -ForegroundColor Cyan

            Write-Host ""

            $memorias = Obtener-Memorias-Personales

            if ($memorias.Count -eq 0) {

                Write-Host "No hay memorias personales guardadas." `
                    -ForegroundColor DarkGray
            }
            else {

                foreach ($memoria in $memorias) {

                    Write-Host "- $($memoria.Clave): $($memoria.Valor)"
                }
            }

            Write-Host ""

            continue
        }

        # ----------------------------------------------------
        # LIMPIAR MEMORIAS
        # ----------------------------------------------------

        if ($rutaMemoria.Tipo -eq "limpiar_memorias") {

            Limpiar-Memorias-Personales

            Write-Host ""
            Write-Host "JARVIS: He borrado todas las memorias personales." `
                -ForegroundColor Cyan
            Write-Host ""

            continue
        }

        # ----------------------------------------------------
        # ELIMINAR MEMORIA CONCRETA
        # ----------------------------------------------------

        if ($rutaMemoria.Tipo -eq "eliminar_memoria") {

            $eliminada = Eliminar-Memoria-Personal `
                $rutaMemoria.Clave

            Write-Host ""

            if ($eliminada) {

                Write-Host "JARVIS: He olvidado la memoria '$($rutaMemoria.Clave)'." `
                    -ForegroundColor Cyan
            }
            else {

                Write-Host "JARVIS: No tengo ninguna memoria llamada '$($rutaMemoria.Clave)'." `
                    -ForegroundColor Yellow
            }

            Write-Host ""

            continue
        }
    }

    # ========================================================
    # 1. INFORMACION DEL SISTEMA
    # ========================================================

    $resultadoSistema = Obtener-InformacionSistema $mensaje

    if ($null -ne $resultadoSistema) {

        Write-Host ""
        Write-Host "JARVIS: " -ForegroundColor Cyan -NoNewline
        Write-Host $resultadoSistema.Texto
        Write-Host ""

        Agregar-Mensaje-Memoria `
            "usuario" `
            $mensaje

        Agregar-Mensaje-Memoria `
            "jarvis" `
            $resultadoSistema.Texto

        continue
    }

    # ========================================================
    # 2. ROUTER RAPIDO
    # ========================================================

    $rutaRapida = Obtener-Ruta-Rapida $mensaje

    if ($null -ne $rutaRapida) {

        Write-Host ""
        Write-Host "JARVIS: $($rutaRapida.Respuesta)" `
            -ForegroundColor Cyan

        $resultado = Ejecutar-Herramienta `
            $rutaRapida.Accion `
            $rutaRapida.Objetivo `
            @{}

        if (-not $resultado.Exito) {

            Write-Host ""
            Write-Host "JARVIS: $($resultado.Error)" `
                -ForegroundColor Yellow
        }

        Agregar-Mensaje-Memoria `
            "usuario" `
            $mensaje

        Agregar-Mensaje-Memoria `
            "jarvis" `
            $rutaRapida.Respuesta

        if ($resultado.Exito) {

            Agregar-Mensaje-Memoria `
                "herramienta" `
                "Accion ejecutada correctamente: $($rutaRapida.Accion) -> $($rutaRapida.Objetivo)"
        }
        else {

            Agregar-Mensaje-Memoria `
                "herramienta" `
                "La accion no se pudo ejecutar: $($resultado.Error)"
        }

        Write-Host ""

        continue
    }

    # ========================================================
    # 3. ROUTER IA
    # ========================================================

    Write-Host ""
    Write-Host "JARVIS: Estoy procesando tu peticion..." `
        -ForegroundColor Cyan
    Write-Host ""

    $historial = Obtener-Historial-Formateado
    $memoriasPersonales = Obtener-Memorias-Personales-Formateadas

    $resultadoIA = Resolver-Peticion-Con-IA `
        $mensaje `
        $historial `
        $memoriasPersonales

    if (-not $resultadoIA.Exito) {

        Write-Host ""
        Write-Host "JARVIS: $($resultadoIA.Error)" `
            -ForegroundColor Red
        Write-Host ""

        continue
    }

    # ========================================================
    # RESPUESTA DE IA
    # ========================================================

    if (
        -not [string]::IsNullOrWhiteSpace(
            [string]$resultadoIA.Respuesta
        )
    ) {

        Write-Host "JARVIS: " -ForegroundColor Cyan -NoNewline
        Write-Host $resultadoIA.Respuesta
    }

    # ========================================================
    # GUARDAR CONVERSACION
    # ========================================================

    Agregar-Mensaje-Memoria `
        "usuario" `
        $mensaje

    if (
        -not [string]::IsNullOrWhiteSpace(
            [string]$resultadoIA.Respuesta
        )
    ) {

        Agregar-Mensaje-Memoria `
            "jarvis" `
            $resultadoIA.Respuesta
    }

    # ========================================================
    # POSIBLE MEMORIA PERSONAL
    # ========================================================

    if ($resultadoIA.MemoriaCandidata) {

        Write-Host ""

        Write-Host "JARVIS: Parece que me has dado un dato que podría ser útil recordar:" `
            -ForegroundColor Yellow

        Write-Host ""
        Write-Host "  $($resultadoIA.MemoriaClave): $($resultadoIA.MemoriaValor)" `
            -ForegroundColor Yellow

        Write-Host ""

        $confirmacion = Read-Host "¿Quieres que lo recuerde durante esta sesion? (s/n)"

        if (
            $confirmacion -eq "s" -or
            $confirmacion -eq "si"
        ) {

            $guardada = Agregar-Memoria-Personal `
                $resultadoIA.MemoriaTipo `
                $resultadoIA.MemoriaClave `
                $resultadoIA.MemoriaValor

            if ($guardada) {

                Write-Host ""
                Write-Host "JARVIS: De acuerdo. Lo recordaré durante esta sesion." `
                    -ForegroundColor Cyan
            }
            else {

                Write-Host ""
                Write-Host "JARVIS: No puedo guardar ese dato." `
                    -ForegroundColor Yellow
            }
        }
        else {

            Write-Host ""
            Write-Host "JARVIS: De acuerdo. No lo recordaré." `
                -ForegroundColor Cyan
        }
    }

    # ========================================================
    # EJECUTAR ACCION DE IA
    # ========================================================

    if (
        $resultadoIA.Accion -ne "ninguna"
    ) {

        $resultadoHerramienta = Ejecutar-Herramienta `
            $resultadoIA.Accion `
            $resultadoIA.Objetivo `
            $resultadoIA.Parametros

        if (-not $resultadoHerramienta.Exito) {

            Write-Host ""
            Write-Host "JARVIS: $($resultadoHerramienta.Error)" `
                -ForegroundColor Yellow

            Agregar-Mensaje-Memoria `
                "herramienta" `
                "La accion no se pudo ejecutar: $($resultadoHerramienta.Error)"
        }
        else {

            Agregar-Mensaje-Memoria `
                "herramienta" `
                "Accion ejecutada correctamente: $($resultadoIA.Accion) -> $($resultadoIA.Objetivo)"

            # ------------------------------------------------
            # MOSTRAR RESULTADO DE CONSULTA
            # ------------------------------------------------

            if (
                (
                    $resultadoIA.Accion -eq "listar_carpeta" -or
                    $resultadoIA.Accion -eq "buscar_archivo"
                ) -and
                -not [string]::IsNullOrWhiteSpace(
                    [string]$resultadoHerramienta.Resultado
                )
            ) {

                Write-Host ""
                Write-Host "JARVIS: Resultado:" `
                    -ForegroundColor Cyan
                Write-Host ""

                Write-Host $resultadoHerramienta.Resultado

                Agregar-Mensaje-Memoria `
                    "herramienta" `
                    $resultadoHerramienta.Resultado
            }
        }
    }

    Write-Host ""
}
