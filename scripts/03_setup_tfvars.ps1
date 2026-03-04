# ─────────────────────────────────────────────────────────────────────────────
# Script 3 : Collecte des OCIDs + création de terraform.tfvars + ~/.oci/config
# ─────────────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "  ETAPE 3 – Configuration des identifiants OCI" -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Où trouver chaque valeur :" -ForegroundColor Yellow
Write-Host "  • Tenancy OCID   → console OCI → Profil → Location/Tenancy details" -ForegroundColor White
Write-Host "  • User OCID      → console OCI → Profil → Paramètres utilisateur → Informations utilisateur" -ForegroundColor White
Write-Host "  • Fingerprint    → console OCI → Paramètres utilisateur → Clés API (ou fichier ~/.oci/fingerprint.txt)" -ForegroundColor White
Write-Host "  • Compartment    → console OCI → Identité & Sécurité → Compartiments → votre compartiment" -ForegroundColor White
Write-Host "  • Région         → exemple : eu-marseille-1  |  eu-paris-1  |  eu-frankfurt-1  |  us-ashburn-1" -ForegroundColor White
Write-Host ""

$ociDir      = "$env:USERPROFILE\.oci"
$privateKey  = "$ociDir\oci_api_key.pem"
$tmpFp       = "$ociDir\fingerprint.txt"
$rootDir     = Split-Path $PSScriptRoot -Parent

# ── Fingerprint : lire depuis fichier si disponible ──────────────────────────
$defaultFp = ""
if (Test-Path $tmpFp) {
    $defaultFp = (Get-Content $tmpFp).Trim()
    Write-Host "💡 Fingerprint détecté automatiquement : $defaultFp" -ForegroundColor Green
    Write-Host ""
}

# ── Collecter les valeurs interactivement ────────────────────────────────────
function Prompt-Value {
    param([string]$Label, [string]$Default = "", [string]$Hint = "")
    if ($Hint) { Write-Host "   ℹ  $Hint" -ForegroundColor DarkGray }
    if ($Default) {
        $val = Read-Host "$Label [défaut: $Default]"
        if ([string]::IsNullOrWhiteSpace($val)) { return $Default }
        return $val.Trim()
    } else {
        do {
            $val = Read-Host "$Label"
        } while ([string]::IsNullOrWhiteSpace($val))
        return $val.Trim()
    }
}

$tenancyOcid    = Prompt-Value "🔑 Tenancy OCID    " "" "ocid1.tenancy.oc1..aaaaaa..."
$userOcid       = Prompt-Value "🔑 User OCID       " "" "ocid1.user.oc1..aaaaaa..."
$fingerprint    = Prompt-Value "🔑 Fingerprint     " $defaultFp "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
$region         = Prompt-Value "🌍 Région          " "eu-marseille-1" "ex: eu-marseille-1"
$compartmentId  = Prompt-Value "📦 Compartment OCID" "" "ocid1.compartment.oc1..aaaaaa..."
$appName        = Prompt-Value "📛 Nom application " "my-frontend-app" "préfixe pour les ressources OCI"

# ── Chemin clé privée normalisé (slashes) ────────────────────────────────────
$privateKeyFwd  = $privateKey -replace "\\", "/"

# ── Écrire terraform.tfvars ──────────────────────────────────────────────────
$tfvarsPath = Join-Path $rootDir "terraform.tfvars"
$tfvarsContent = @"
# terraform.tfvars – généré automatiquement par 03_setup_tfvars.ps1
# ⚠  Ne jamais committer ce fichier dans un dépôt public !

tenancy_ocid     = "$tenancyOcid"
user_ocid        = "$userOcid"
fingerprint      = "$fingerprint"
private_key_path = "$privateKeyFwd"
region           = "$region"
compartment_ocid = "$compartmentId"
app_name         = "$appName"
source_path      = "./dist"
"@

$tfvarsContent | Out-File -FilePath $tfvarsPath -Encoding UTF8 -NoNewline
Write-Host ""
Write-Host "✅ terraform.tfvars créé : $tfvarsPath" -ForegroundColor Green

# ── Écrire ~/.oci/config ─────────────────────────────────────────────────────
$ociConfigPath = "$ociDir\config"
$ociConfigContent = @"
[DEFAULT]
user=$userOcid
fingerprint=$fingerprint
tenancy=$tenancyOcid
region=$region
key_file=$privateKeyFwd
"@

$ociConfigContent | Out-File -FilePath $ociConfigPath -Encoding ASCII -NoNewline
Write-Host "✅ ~/.oci/config créé : $ociConfigPath" -ForegroundColor Green

Write-Host ""
Write-Host "════════════════════════════════════════════════════════"
Write-Host "  Récapitulatif de votre configuration :" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════"
Write-Host "  Tenancy OCID    : $tenancyOcid"
Write-Host "  User OCID       : $userOcid"
Write-Host "  Fingerprint     : $fingerprint"
Write-Host "  Région          : $region"
Write-Host "  Compartiment    : $compartmentId"
Write-Host "  App Name        : $appName"
Write-Host "  Clé privée      : $privateKeyFwd"
Write-Host "════════════════════════════════════════════════════════"
Write-Host ""
Write-Host "➡  Continuez avec le script : 04_deploy.ps1" -ForegroundColor Cyan
