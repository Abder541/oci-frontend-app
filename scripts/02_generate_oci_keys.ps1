# ─────────────────────────────────────────────────────────────────────────────
# Script 2 : Génération des clés API OCI + création de ~/.oci/config
# ─────────────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "  ETAPE 2 – Génération des clés API OCI" -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host ""

$ociDir = "$env:USERPROFILE\.oci"
$privateKey = "$ociDir\oci_api_key.pem"
$publicKey  = "$ociDir\oci_api_key_public.pem"

# ── Créer le dossier ~/.oci s'il n'existe pas ────────────────────────────────
if (-not (Test-Path $ociDir)) {
    New-Item -ItemType Directory -Path $ociDir | Out-Null
    Write-Host "📁 Dossier créé : $ociDir" -ForegroundColor Green
} else {
    Write-Host "📁 Dossier existant : $ociDir" -ForegroundColor Green
}

# ── Générer la clé privée RSA 2048 ──────────────────────────────────────────
if (Test-Path $privateKey) {
    Write-Host ""
    $resp = Read-Host "⚠  La clé privée existe déjà ($privateKey). Régénérer ? (o/N)"
    if ($resp -notmatch "^[oO]$") {
        Write-Host "   Clé privée conservée." -ForegroundColor Yellow
    } else {
        openssl genrsa -out $privateKey 2048 2>&1 | Out-Null
        Write-Host "✅ Nouvelle clé privée générée : $privateKey" -ForegroundColor Green
    }
} else {
    Write-Host "⏳ Génération de la clé privée RSA 2048..." -ForegroundColor Yellow
    openssl genrsa -out $privateKey 2048 2>&1 | Out-Null
    Write-Host "✅ Clé privée générée : $privateKey" -ForegroundColor Green
}

# ── Extraire la clé publique ─────────────────────────────────────────────────
Write-Host "⏳ Extraction de la clé publique..." -ForegroundColor Yellow
openssl rsa -pubout -in $privateKey -out $publicKey 2>&1 | Out-Null
Write-Host "✅ Clé publique générée : $publicKey" -ForegroundColor Green

# ── Calculer le fingerprint ──────────────────────────────────────────────────
Write-Host ""
Write-Host "⏳ Calcul du fingerprint..." -ForegroundColor Yellow
$rawFingerprint = openssl rsa -pubout -outform DER -in $privateKey 2>$null | openssl md5 -c 2>$null
# Format attendu: "(stdin)= xx:xx:xx:..."
$fingerprint = ($rawFingerprint -replace ".*= ", "").Trim()
Write-Host "✅ Fingerprint : $fingerprint" -ForegroundColor Green

# ── Afficher la clé publique (à copier dans la console OCI) ─────────────────
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "  COPIEZ CE CONTENU DANS LA CONSOLE OCI :" -ForegroundColor Magenta
Write-Host "  Profil → Paramètres utilisateur → Clés API → Ajouter" -ForegroundColor Magenta
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""
Get-Content $publicKey
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Magenta

# ── Sauvegarder le fingerprint dans un fichier temporaire ───────────────────
$tmpFile = "$ociDir\fingerprint.txt"
$fingerprint | Out-File -FilePath $tmpFile -Encoding ASCII
Write-Host ""
Write-Host "💾 Fingerprint sauvegardé dans : $tmpFile" -ForegroundColor Green

Write-Host ""
Write-Host "────────────────────────────────────────────────────────"
Write-Host "ACTION REQUISE :" -ForegroundColor Yellow
Write-Host " 1. Allez sur : https://cloud.oracle.com" -ForegroundColor White
Write-Host " 2. Icône Profil (haut droite) → Paramètres utilisateur" -ForegroundColor White
Write-Host " 3. Ressources → Clés API → Ajouter une clé API" -ForegroundColor White
Write-Host " 4. Sélectionnez 'Coller la clé publique'" -ForegroundColor White
Write-Host " 5. Collez le contenu affiché ci-dessus" -ForegroundColor White
Write-Host " 6. Cliquez Ajouter" -ForegroundColor White
Write-Host "────────────────────────────────────────────────────────"
Write-Host ""
Write-Host "➡  Une fois la clé uploadée, continuez avec : 03_setup_tfvars.ps1" -ForegroundColor Cyan
