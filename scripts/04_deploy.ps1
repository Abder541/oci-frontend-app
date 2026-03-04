# ─────────────────────────────────────────────────────────────────────────────
# Script 4 : Déploiement Terraform (init + validate + plan + apply)
# ─────────────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "  ETAPE 4 – Déploiement sur OCI avec Terraform" -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host ""

$rootDir = Split-Path $PSScriptRoot -Parent
Set-Location $rootDir

# ── Pré-requis ────────────────────────────────────────────────────────────────
Write-Host "🔍 Vérification des prérequis..." -ForegroundColor Yellow

# Terraform
if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Terraform non trouvé. Exécutez d'abord : scripts\01_install_terraform.ps1" -ForegroundColor Red
    exit 1
}
$tfVersion = terraform version -json | ConvertFrom-Json
Write-Host "   ✅ Terraform $($tfVersion.terraform_version)" -ForegroundColor Green

# terraform.tfvars
if (-not (Test-Path "$rootDir\terraform.tfvars")) {
    Write-Host "❌ terraform.tfvars introuvable. Exécutez d'abord : scripts\03_setup_tfvars.ps1" -ForegroundColor Red
    exit 1
}
Write-Host "   ✅ terraform.tfvars présent" -ForegroundColor Green

# Dossier dist
if (-not (Test-Path "$rootDir\dist\index.html")) {
    Write-Host "❌ dist/index.html introuvable. Le dossier dist est requis." -ForegroundColor Red
    exit 1
}
$fileCount = (Get-ChildItem "$rootDir\dist" -Recurse -File).Count
Write-Host "   ✅ Dossier dist présent ($fileCount fichiers)" -ForegroundColor Green

Write-Host ""

# ── terraform init ─────────────────────────────────────────────────────────
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host " terraform init" -ForegroundColor White
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
terraform init
if ($LASTEXITCODE -ne 0) { Write-Host "`n❌ terraform init a échoué." -ForegroundColor Red; exit 1 }

Write-Host ""

# ── terraform validate ────────────────────────────────────────────────────
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host " terraform validate" -ForegroundColor White
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
terraform validate
if ($LASTEXITCODE -ne 0) { Write-Host "`n❌ terraform validate a échoué." -ForegroundColor Red; exit 1 }

Write-Host ""

# ── terraform plan ────────────────────────────────────────────────────────
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host " terraform plan" -ForegroundColor White
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
terraform plan -out=tfplan
if ($LASTEXITCODE -ne 0) { Write-Host "`n❌ terraform plan a échoué." -ForegroundColor Red; exit 1 }

Write-Host ""

# ── Confirmation avant apply ──────────────────────────────────────────────
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host " Revue du plan ci-dessus." -ForegroundColor Yellow
$confirm = Read-Host " Appliquer (déployer sur OCI) ? (oui/non)"
if ($confirm -notmatch "^(oui|o|yes|y)$") {
    Write-Host "⛔ Déploiement annulé." -ForegroundColor Red
    Remove-Item -Path "tfplan" -ErrorAction SilentlyContinue
    exit 0
}

Write-Host ""

# ── terraform apply ────────────────────────────────────────────────────────
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host " terraform apply (peut prendre 3-5 minutes)" -ForegroundColor White
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
terraform apply tfplan
if ($LASTEXITCODE -ne 0) { Write-Host "`n❌ terraform apply a échoué." -ForegroundColor Red; exit 1 }

Remove-Item -Path "tfplan" -ErrorAction SilentlyContinue

# ── Récupérer et afficher l'URL ────────────────────────────────────────────
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  ✅ DÉPLOIEMENT RÉUSSI !" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "  Outputs :" -ForegroundColor Cyan
terraform output
Write-Host ""
$appUrl = terraform output -raw app_url 2>$null
if ($appUrl) {
    Write-Host "  🌐 Votre application est accessible ici :" -ForegroundColor Green
    Write-Host "     $appUrl" -ForegroundColor White
    Write-Host ""
    Write-Host "  ℹ  Note : L'API Gateway peut prendre 1-2 minutes supplémentaires" -ForegroundColor Yellow
    Write-Host "     avant d'être pleinement opérationnelle." -ForegroundColor Yellow
}
Write-Host ""
Write-Host "  Pour supprimer toutes les ressources OCI :" -ForegroundColor DarkGray
Write-Host "  .\scripts\05_destroy.ps1" -ForegroundColor DarkGray
