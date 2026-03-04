# ─────────────────────────────────────────────────────────────────────────────
# Script 5 : Nettoyage – suppression de toutes les ressources OCI (terraform destroy)
# ─────────────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=======================================================" -ForegroundColor Red
Write-Host "  ETAPE 5 – Nettoyage des ressources OCI" -ForegroundColor Red
Write-Host "=======================================================" -ForegroundColor Red
Write-Host ""
Write-Host "⚠  ATTENTION : Cette commande supprime TOUTES les ressources" -ForegroundColor Yellow
Write-Host "   créées par Terraform :" -ForegroundColor Yellow
Write-Host "   • API Gateway + Deployment" -ForegroundColor White
Write-Host "   • Bucket Object Storage + tous les fichiers uploadés" -ForegroundColor White
Write-Host "   • Subnet, Security List, Route Table, Internet Gateway, VCN" -ForegroundColor White
Write-Host ""

$rootDir = Split-Path $PSScriptRoot -Parent
Set-Location $rootDir

# ── Pré-requis ────────────────────────────────────────────────────────────────
if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Terraform non trouvé." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path "$rootDir\terraform.tfvars")) {
    Write-Host "❌ terraform.tfvars introuvable. Impossible de détruire l'infrastructure." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path "$rootDir\.terraform")) {
    Write-Host "⏳ Initialisation Terraform requise avant destroy..." -ForegroundColor Yellow
    terraform init
    if ($LASTEXITCODE -ne 0) { exit 1 }
}

# ── Confirmation ──────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Red
$confirm = Read-Host " Confirmer la suppression de toutes les ressources ? (oui/non)"
if ($confirm -notmatch "^(oui|o|yes|y)$") {
    Write-Host "⛔ Nettoyage annulé. Aucune ressource supprimée." -ForegroundColor Green
    exit 0
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host " terraform destroy -auto-approve" -ForegroundColor White
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
terraform destroy -auto-approve
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ terraform destroy a rencontré une erreur." -ForegroundColor Red
    Write-Host "   Vérifiez la console OCI pour supprimer manuellement les ressources restantes." -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  ✅ Toutes les ressources OCI ont été supprimées." -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
