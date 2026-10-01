# ============================================================
# JARVIS - UTILIDADES DE TEXTO
# ============================================================

function Normalizar-Texto {

    param (
        [Parameter(Mandatory = $true)]
        [string]$Texto
    )

    if ([string]::IsNullOrWhiteSpace($Texto)) {
        return ""
    }

    $normalizado = $Texto.ToLower().Normalize(
        [System.Text.NormalizationForm]::FormD
    )

    $resultado = -join (
        $normalizado.ToCharArray() |
        Where-Object {
            [Globalization.CharUnicodeInfo]::GetUnicodeCategory($_) -ne
            [Globalization.UnicodeCategory]::NonSpacingMark
        }
    )

    return $resultado.Normalize(
        [System.Text.NormalizationForm]::FormC
    ).Trim()
}
