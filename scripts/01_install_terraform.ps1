# ─────────────────────────────────────────────────────────────────────────────
# Script 1 : Installation de Terraform via winget
# ─────────────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "  ETAPE 1 – Installation de Terraform" -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host ""

# Vérifie si Terraform est déjà installé
if (Get-Command terraform -ErrorAction SilentlyContinue) {
    $version = terraform -v | Select-Object -First 1
    Write-Host "✅ Terraform est déjà installé : $version" -ForegroundColor Green
    Write-Host ""
    Write-Host "➡  Passez directement au script 02_generate_oci_keys.ps1" -ForegroundColor Yellow
    exit 0
}

Write-Host "⏳ Installation de Terraform via winget..." -ForegroundColor Yellow
winget install --id Hashicorp.Terraform --silent --accept-package-agreements --accept-source-agreements

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ Erreur lors de l'installation via winget." -ForegroundColor Red
    Write-Host "   Téléchargez Terraform manuellement : https://developer.hashicorp.com/terraform/downloads" -ForegroundColor Yellow
    exit 1
}

# Recharge le PATH pour la session courante
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path","User")

Write-Host ""
if (Get-Command terraform -ErrorAction SilentlyContinue) {
    $version = terraform -v | Select-Object -First 1
    Write-Host "✅ Terraform installé avec succès : $version" -ForegroundColor Green
} else {
    Write-Host "⚠  Terraform installé mais non détecté dans PATH." -ForegroundColor Yellow
    Write-Host "   Fermez et rouvrez PowerShell, puis relancez ce script pour vérifier." -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "➡  Continuez avec le script : 02_generate_oci_keys.ps1" -ForegroundColor Cyan
