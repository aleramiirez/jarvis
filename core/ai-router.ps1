# ============================================================
# JARVIS - ROUTER DE INTELIGENCIA ARTIFICIAL
# ============================================================

function Obtener-Contexto-Herramientas-IA {

    $herramientas = Obtener-Esquema-Herramientas |
        Where-Object {
            $_.Nombre -ne "informacion_sistema"
        }

    $lineas = @()

    foreach ($herramienta in $herramientas) {

        $lineas += "HERRAMIENTA: $($herramienta.Nombre)"
        $lineas += "TIPO: $($herramienta.Tipo)"
        $lineas += "DESCRIPCION: $($herramienta.Descripcion)"
        $lineas += "CAPACIDADES:"

        foreach ($capacidad in $herramienta.Capacidades) {

            $lineas += "- $capacidad"
        }

        $lineas += "REQUIERE_CONFIRMACION: $($herramienta.RequiereConfirmacion)"
        $lineas += "PARAMETROS:"

        foreach ($parametro in $herramienta.Parametros) {

            $obligatorio = if ($parametro.Requerido) {
                "si"
            }
            else {
                "no"
            }

            $lineas += "- $($parametro.Nombre)"
            $lineas += "  TIPO: $($parametro.Tipo)"
            $lineas += "  REQUERIDO: $obligatorio"
            $lineas += "  DESCRIPCION: $($parametro.Descripcion)"
        }

        $lineas += "OBJETIVOS PERMITIDOS:"

        foreach ($objetivo in $herramienta.Objetivos) {

            $lineas += "- $($objetivo.Nombre)"
            $lineas += "  DESCRIPCION: $($objetivo.Descripcion)"
        }

        $lineas += ""
    }

    return $lineas -join "`n"
}

# ============================================================
# OBTENER CONTEXTO DE ARCHIVOS
# ============================================================

function Obtener-Contexto-Archivos-IA {

    $archivos = Obtener-Archivos-Proyecto

    if ($archivos.Count -eq 0) {

        return "No hay indice de archivos disponible."
    }

    $lineas = @()

    foreach ($archivo in $archivos) {

        $lineas += "- $archivo"
    }

    return $lineas -join "`n"
}

# ============================================================
# RESOLVER PETICION CON IA
# ============================================================

function Resolver-Peticion-Con-IA {

    param (
        [Parameter(Mandatory = $true)]
        [string]$Mensaje,

        [Parameter(Mandatory = $false)]
        [string]$Historial = "",

        [Parameter(Mandatory = $false)]
        [string]$MemoriasPersonales = ""
    )

    $contextoHerramientas = Obtener-Contexto-Herramientas-IA
    $contextoArchivos = Obtener-Contexto-Archivos-IA

    if ([string]::IsNullOrWhiteSpace($Historial)) {

        $Historial = "No hay historial de conversacion."
    }

    if ([string]::IsNullOrWhiteSpace($MemoriasPersonales)) {

        $MemoriasPersonales = "No hay memorias personales guardadas."
    }

    # ========================================================
    # PROMPT
    # ========================================================

    $prompt = @"
Eres el router inteligente de JARVIS.

Tu trabajo es interpretar la peticion actual del usuario y
decidir si quiere realizar una accion o consulta conocida.

No ejecutas ninguna accion.

El historial de conversacion sirve solamente como contexto
para entender referencias como "eso", "tambien", "ahora",
"lo anterior" o peticiones relacionadas.

Las memorias personales son datos que el usuario ha aprobado
previamente para que JARVIS los recuerde.

El indice de archivos contiene nombres reales del proyecto JARVIS.
Utilizalo solamente para escoger archivos existentes.

Solamente debes devolver un JSON valido con este formato:

{
  "respuesta": "respuesta breve para el usuario",
  "accion": "ninguna",
  "objetivo": "",
  "parametros": {},
  "memoria_candidata": false,
  "memoria_tipo": "",
  "memoria_clave": "",
  "memoria_valor": ""
}

HERRAMIENTAS DISPONIBLES:

$contextoHerramientas

ARCHIVOS REALES DEL PROYECTO JARVIS:

$contextoArchivos

HISTORIAL DE CONVERSACION:

$Historial

MEMORIAS PERSONALES APROBADAS:

$MemoriasPersonales

ACCIONES VALIDAS:

- abrir_aplicacion
- abrir_carpeta
- listar_carpeta
- buscar_archivo
- leer_archivo
- analizar_archivo
- ninguna

REGLAS IMPORTANTES:

- Responde siempre en espanol.
- Devuelve solamente JSON valido.
- No escribas Markdown.
- No escribas explicaciones fuera del JSON.
- No inventes herramientas.
- No inventes aplicaciones.
- No inventes carpetas.
- No inventes objetivos.
- Utiliza solamente las herramientas y objetivos definidos.
- Utiliza "parametros" solamente para proporcionar los datos que
  necesita una herramienta.
- Si una herramienta requiere un parametro, debes incluirlo.
- Nunca introduzcas una ruta del sistema dentro de un parametro
  cuando la herramienta ya define un objetivo permitido.

BUSQUEDA DE ARCHIVOS:

- Si el usuario pide buscar o encontrar un archivo dentro del
  proyecto JARVIS, utiliza:

  accion = "buscar_archivo"
  objetivo = "jarvis"

- "parametros.consulta" debe ser un termino adecuado para buscar
  nombres de archivo.

- El indice de archivos contiene los nombres reales existentes.
- Cuando el usuario describe un archivo de forma natural, busca
  en el indice el nombre tecnico que mejor represente esa descripcion.
- Prioriza un archivo cuyo nombre represente claramente el concepto
  solicitado.
- Si existe un archivo concreto que encaja con la descripcion,
  utiliza su nombre o una parte significativa de su nombre.
- Puedes utilizar la extension si aparece en el indice.
- No inventes nombres que no aparezcan en el indice.

LECTURA DE ARCHIVOS:

- Si el usuario pide leer, mostrar, examinar o enseñarle el
  contenido de un archivo, utiliza:

  accion = "leer_archivo"
  objetivo = "jarvis"

- "parametros.ruta" debe ser una ruta relativa REAL que aparezca
  en el indice de archivos.

- No inventes rutas.
- No utilices rutas absolutas.
- No utilices "..".
- No utilices archivos dentro de ".git".
- No utilices archivos dentro de "data".

ANALISIS DE ARCHIVOS:

- Si el usuario pide explicar, analizar, entender o decir que hace
  un archivo, utiliza:

  accion = "analizar_archivo"
  objetivo = "jarvis"

- "parametros.ruta" debe ser una ruta relativa REAL que aparezca
  en el indice de archivos.

- El analisis implica leer primero el archivo real y despues pasar
  su contenido a otro proceso de IA para generar una explicacion.

- Si el usuario solamente pide ver el codigo, utiliza "leer_archivo".
- Si pide entender que hace, utiliza "analizar_archivo".

EJEMPLO:

Usuario:
lee el archivo de la memoria

Respuesta:

{
  "respuesta": "Claro. Voy a leer ese archivo del proyecto JARVIS.",
  "accion": "leer_archivo",
  "objetivo": "jarvis",
  "parametros": {
    "ruta": "core\\memory.ps1"
  },
  "memoria_candidata": false,
  "memoria_tipo": "",
  "memoria_clave": "",
  "memoria_valor": ""
}

EJEMPLO:

Usuario:
lee el archivo de la memoria y dime que hace

Respuesta:

{
  "respuesta": "Claro. Voy a analizar ese archivo del proyecto JARVIS.",
  "accion": "analizar_archivo",
  "objetivo": "jarvis",
  "parametros": {
    "ruta": "core\\memory.ps1"
  },
  "memoria_candidata": false,
  "memoria_tipo": "",
  "memoria_clave": "",
  "memoria_valor": ""
}

EJEMPLO:

Usuario:
explicame el router de inteligencia artificial

Respuesta:

{
  "respuesta": "Claro. Voy a analizar ese archivo del proyecto JARVIS.",
  "accion": "analizar_archivo",
  "objetivo": "jarvis",
  "parametros": {
    "ruta": "core\\ai-router.ps1"
  },
  "memoria_candidata": false,
  "memoria_tipo": "",
  "memoria_clave": "",
  "memoria_valor": ""
}

- Si la peticion corresponde a consultar el contenido del
  proyecto JARVIS, utiliza:

  accion = "listar_carpeta"
  objetivo = "jarvis"

- Si la peticion no corresponde claramente a una herramienta
  disponible, utiliza "ninguna".

- Si el usuario esta haciendo una pregunta general, una conversacion
  o una peticion que no requiere una accion o consulta del ordenador,
  utiliza "ninguna".

- No intentes ejecutar comandos.
- No devuelvas comandos de PowerShell.
- No utilices rutas inventadas.
- No utilices "informacion_sistema" como accion.
- La informacion del sistema se obtiene directamente desde Windows.
- Respeta siempre los parametros definidos por cada herramienta.
- Nunca inventes valores para parametros.
- Las herramientas de consulta pueden devolver datos reales del sistema.
- No afirmes el resultado de una consulta hasta que la herramienta
  haya sido ejecutada.

MEMORIA PERSONAL:

- Detecta una memoria candidata solamente cuando el usuario
  comparta voluntariamente un dato personal que pueda ser util
  en conversaciones futuras.
- Ejemplos: nombre, preferencia, proyecto habitual o una forma
  de trabajar que el usuario haya expresado claramente.
- No guardes automaticamente ninguna memoria.
- Solo informa de que existe una posible memoria candidata.
- Nunca propongas guardar contrasenas, tokens, claves, secretos,
  numeros de tarjetas, PIN, credenciales, documentos de identidad
  ni otros datos sensibles.
- Si no existe una memoria candidata:
  "memoria_candidata" debe ser false.
- Si existe una memoria candidata:
  "memoria_candidata" debe ser true.
- "memoria_tipo", "memoria_clave" y "memoria_valor" deben contener
  solamente el dato que el usuario acaba de proporcionar.
- No copies informacion sensible de las memorias anteriores.
- Una memoria candidata no modifica las memorias aprobadas.

EJEMPLO 1:

Usuario:
puedes abrirme el bloc de notas

Respuesta:

{
  "respuesta": "Claro. Voy a abrir el Bloc de notas.",
  "accion": "abrir_aplicacion",
  "objetivo": "notepad",
  "parametros": {},
  "memoria_candidata": false,
  "memoria_tipo": "",
  "memoria_clave": "",
  "memoria_valor": ""
}

EJEMPLO 2:

Usuario:
que archivos hay en mi proyecto

Respuesta:

{
  "respuesta": "Claro. Voy a consultar el contenido del proyecto JARVIS.",
  "accion": "listar_carpeta",
  "objetivo": "jarvis",
  "parametros": {},
  "memoria_candidata": false,
  "memoria_tipo": "",
  "memoria_clave": "",
  "memoria_valor": ""
}

EJEMPLO 3:

Usuario:
necesito encontrar el fichero de la memoria

Respuesta:

{
  "respuesta": "Claro. Voy a buscar ese archivo en el proyecto JARVIS.",
  "accion": "buscar_archivo",
  "objetivo": "jarvis",
  "parametros": {
    "consulta": "memory.ps1"
  },
  "memoria_candidata": false,
  "memoria_tipo": "",
  "memoria_clave": "",
  "memoria_valor": ""
}

EJEMPLO 4:

Usuario:
buscame el router de inteligencia artificial

Respuesta:

{
  "respuesta": "Claro. Voy a buscar ese archivo en el proyecto JARVIS.",
  "accion": "buscar_archivo",
  "objetivo": "jarvis",
  "parametros": {
    "consulta": "ai-router.ps1"
  },
  "memoria_candidata": false,
  "memoria_tipo": "",
  "memoria_clave": "",
  "memoria_valor": ""
}

EJEMPLO 5:

Usuario:
lee el archivo de la memoria

Respuesta:

{
  "respuesta": "Claro. Voy a leer ese archivo del proyecto JARVIS.",
  "accion": "leer_archivo",
  "objetivo": "jarvis",
  "parametros": {
    "ruta": "core\\memory.ps1"
  },
  "memoria_candidata": false,
  "memoria_tipo": "",
  "memoria_clave": "",
  "memoria_valor": ""
}

EJEMPLO 6:

Usuario:
lee el archivo de la memoria y dime que hace

Respuesta:

{
  "respuesta": "Claro. Voy a analizar ese archivo del proyecto JARVIS.",
  "accion": "analizar_archivo",
  "objetivo": "jarvis",
  "parametros": {
    "ruta": "core\\memory.ps1"
  },
  "memoria_candidata": false,
  "memoria_tipo": "",
  "memoria_clave": "",
  "memoria_valor": ""
}

EJEMPLO 7:

Usuario:
explicame el router de inteligencia artificial

Respuesta:

{
  "respuesta": "Claro. Voy a analizar ese archivo del proyecto JARVIS.",
  "accion": "analizar_archivo",
  "objetivo": "jarvis",
  "parametros": {
    "ruta": "core\\ai-router.ps1"
  },
  "memoria_candidata": false,
  "memoria_tipo": "",
  "memoria_clave": "",
  "memoria_valor": ""
}

EJEMPLO 8:

Usuario:
hola JARVIS

Respuesta:

{
  "respuesta": "Hola. ¿En qué puedo ayudarte?",
  "accion": "ninguna",
  "objetivo": "",
  "parametros": {},
  "memoria_candidata": false,
  "memoria_tipo": "",
  "memoria_clave": "",
  "memoria_valor": ""
}

PETICION ACTUAL DEL USUARIO:

$Mensaje
"@

    # ========================================================
    # BODY
    # ========================================================

    $body = @{
        model = $JARVIS_MODEL
        prompt = $prompt
        stream = $false
        think = $false
        format = "json"
    } | ConvertTo-Json -Compress

    # ========================================================
    # PETICION A OLLAMA
    # ========================================================

    try {

        $resultado = Invoke-RestMethod `
            -Uri $OLLAMA_GENERATE_URL `
            -Method Post `
            -ContentType "application/json; charset=utf-8" `
            -Body ([System.Text.Encoding]::UTF8.GetBytes($body))
    }
    catch {

        return @{
            Exito = $false
            Error = "No puedo conectar con Ollama. $($_.Exception.Message)"
        }
    }

    # ========================================================
    # PARSEAR JSON
    # ========================================================

    try {

        $respuestaIA = $resultado.response | ConvertFrom-Json
    }
    catch {

        return @{
            Exito = $false
            Error = "La respuesta de Ollama no tiene un formato JSON valido."
        }
    }

    # ========================================================
    # EXTRAER DATOS
    # ========================================================

    $respuesta = [string]$respuestaIA.respuesta
    $accion = [string]$respuestaIA.accion
    $objetivo = [string]$respuestaIA.objetivo

    $memoriaCandidata = [bool]$respuestaIA.memoria_candidata
    $memoriaTipo = [string]$respuestaIA.memoria_tipo
    $memoriaClave = [string]$respuestaIA.memoria_clave
    $memoriaValor = [string]$respuestaIA.memoria_valor

    # ========================================================
    # EXTRAER PARAMETROS
    # ========================================================

    $parametros = @{}

    if ($null -ne $respuestaIA.parametros) {

        foreach ($propiedad in $respuestaIA.parametros.PSObject.Properties) {

            $parametros[$propiedad.Name] = [string]$propiedad.Value
        }
    }

    if ([string]::IsNullOrWhiteSpace($accion)) {

        $accion = "ninguna"
    }

    # ========================================================
    # RESULTADO BASE
    # ========================================================

    $resultado = @{
        Exito = $true
        Respuesta = $respuesta
        Accion = $accion
        Objetivo = $objetivo
        Parametros = $parametros

        MemoriaCandidata = $false
        MemoriaTipo = ""
        MemoriaClave = ""
        MemoriaValor = ""
    }

    # ========================================================
    # VALIDAR MEMORIA CANDIDATA
    # ========================================================

    if ($memoriaCandidata) {

        if (
            Puede-Guardar-Memoria-Personal `
                $memoriaClave `
                $memoriaValor
        ) {

            $resultado.MemoriaCandidata = $true
            $resultado.MemoriaTipo = $memoriaTipo
            $resultado.MemoriaClave = $memoriaClave
            $resultado.MemoriaValor = $memoriaValor
        }
    }

    # ========================================================
    # SI NO HAY ACCION
    # ========================================================

    if ($accion -eq "ninguna") {

        return $resultado
    }

    # ========================================================
    # VALIDAR HERRAMIENTA
    # ========================================================

    if (-not (Existe-Herramienta $accion)) {

        return @{
            Exito = $false
            Error = "Ollama ha devuelto una herramienta no permitida: $accion"
        }
    }

    # ========================================================
    # VALIDAR OBJETIVO
    # ========================================================

    if (-not (Existe-Objetivo-Herramienta $accion $objetivo)) {

        return @{
            Exito = $false
            Error = "Ollama ha devuelto un objetivo no permitido: $objetivo"
        }
    }

    # ========================================================
    # VALIDAR PARAMETROS
    # ========================================================

    $herramienta = Obtener-Herramienta $accion

    foreach ($parametro in $herramienta.Parametros) {

        if ($parametro.Requerido) {

            if (
                -not $parametros.ContainsKey($parametro.Nombre) -or
                [string]::IsNullOrWhiteSpace(
                    [string]$parametros[$parametro.Nombre]
                )
            ) {

                return @{
                    Exito = $false
                    Error = "La herramienta '$accion' necesita el parametro '$($parametro.Nombre)'."
                }
            }
        }
    }

    return $resultado
}
