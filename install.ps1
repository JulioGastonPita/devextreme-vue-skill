# install.ps1
# Instala o actualiza el MCP de DevExtreme y el plugin vue3-devextreme en Claude Code.
# Ejecutar desde la raiz del proyecto donde se quiere usar el plugin:
#   .\install.ps1

$MCP_NAME    = "dxdocs"
$MCP_URL     = "https://api.devexpress.com/mcp/docs"
$PLUGIN_NAME = "vue3-devextreme"
$PLUGIN_REPO = "JulioGastonPita/devextreme-vue-skill"

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  DevExtreme Vue Skill — Setup" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# ── Verificar que claude CLI este disponible ──────────────────────────────────

if (-not (Get-Command "claude" -ErrorAction SilentlyContinue)) {
    Write-Host ""
    Write-Host "[ERROR] No se encontro el comando 'claude'." -ForegroundColor Red
    Write-Host "        Instala Claude Code desde: https://claude.ai/code" -ForegroundColor Yellow
    exit 1
}

# ── MCP de DevExtreme (scope global — disponible en todos los proyectos) ──────

Write-Host ""
Write-Host "[1/2] MCP de DevExtreme..." -ForegroundColor Yellow

$mcpList = claude mcp list 2>&1
if ($mcpList -match $MCP_NAME) {
    Write-Host "      Ya instalado — sin cambios." -ForegroundColor Green
} else {
    Write-Host "      Instalando '$MCP_NAME'..."
    claude mcp add --scope user --transport http $MCP_NAME $MCP_URL 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "      Instalado correctamente." -ForegroundColor Green
    } else {
        Write-Host "      Error al instalar el MCP. Verificar manualmente:" -ForegroundColor Red
        Write-Host "      claude mcp add --scope user --transport http $MCP_NAME $MCP_URL" -ForegroundColor Gray
    }
}

# ── Plugin vue3-devextreme ────────────────────────────────────────────────────

Write-Host ""
Write-Host "[2/2] Plugin '$PLUGIN_NAME'..." -ForegroundColor Yellow

$pluginList = claude plugin list 2>&1
if ($pluginList -match $PLUGIN_NAME) {
    Write-Host "      Ya instalado — actualizando..."
    claude plugin update $PLUGIN_NAME 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "      Actualizado a la ultima version." -ForegroundColor Green
    } else {
        Write-Host "      Error al actualizar. Intentar manualmente:" -ForegroundColor Red
        Write-Host "      claude plugin update $PLUGIN_NAME" -ForegroundColor Gray
    }
} else {
    Write-Host "      Registrando marketplace..."
    claude plugin marketplace add $PLUGIN_REPO 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "      Error al registrar marketplace. Verificar manualmente:" -ForegroundColor Red
        Write-Host "      claude plugin marketplace add $PLUGIN_REPO" -ForegroundColor Gray
        exit 1
    }
    Write-Host "      Instalando plugin..."
    claude plugin install $PLUGIN_NAME 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "      Instalado correctamente." -ForegroundColor Green
    } else {
        Write-Host "      Error al instalar. Intentar manualmente:" -ForegroundColor Red
        Write-Host "      claude plugin install $PLUGIN_NAME" -ForegroundColor Gray
    }
}

# ── Resumen ───────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Listo. Reinicia Claude Code para que los"
Write-Host "  cambios tomen efecto."
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
