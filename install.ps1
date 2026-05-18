# install.ps1
# Instala o actualiza el MCP de DevExtreme y el skill vue3-devextreme en Claude Code.
# Ejecutar desde la raiz del proyecto donde se quiere usar el skill:
#   .\install.ps1

$MCP_NAME   = "dxdocs"
$MCP_URL    = "https://api.devexpress.com/mcp/docs"
$SKILL_NAME = "vue3-devextreme"
$SKILL_REPO = "JulioGastonPita/devextreme-vue-skill"
$SKILL_PATH = "vue3-devextreme/SKILL.md"

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

# ── Skill vue3-devextreme (scope proyecto — ejecutar desde la raiz del proyecto)

Write-Host ""
Write-Host "[2/2] Skill '$SKILL_NAME'..." -ForegroundColor Yellow

$skillList = claude skills list 2>&1
if ($skillList -match $SKILL_NAME) {
    Write-Host "      Ya instalado — actualizando..."
    claude skills update $SKILL_NAME 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "      Actualizado a la ultima version." -ForegroundColor Green
    } else {
        Write-Host "      Error al actualizar. Intentar manualmente:" -ForegroundColor Red
        Write-Host "      claude skills update $SKILL_NAME" -ForegroundColor Gray
    }
} else {
    Write-Host "      Instalando desde GitHub..."
    claude skills add $SKILL_REPO --skill-path $SKILL_PATH 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "      Instalado correctamente." -ForegroundColor Green
    } else {
        Write-Host "      Error al instalar. Intentar manualmente:" -ForegroundColor Red
        Write-Host "      claude skills add $SKILL_REPO --skill-path $SKILL_PATH" -ForegroundColor Gray
    }
}

# ── Resumen ───────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Listo. Reinicia Claude Code para que los"
Write-Host "  cambios tomen efecto."
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
