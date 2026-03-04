# oci-frontend-app

Frontend statique déployé sur **GitHub Pages** – infrastructure **Oracle Cloud Infrastructure** définie avec **Terraform**.

## Stack

- **GitHub Pages** – hébergement de l'application frontend
- **OCI Object Storage** – bucket pour les fichiers statiques
- **OCI API Gateway** – exposition HTTPS publique avec CORS
- **Terraform** – infrastructure as code (VCN, subnet, IGW, security list, bucket, gateway)

## Structure

```
oci-frontend-app/
├── dist/                   # Fichiers de l'application frontend (déployés sur GitHub Pages)
│   ├── index.html
│   └── assets/
│       ├── app.js
│       └── style.css
├── .github/
│   └── workflows/
│       └── deploy.yml      # GitHub Actions – déploiement automatique sur push
├── main.tf                 # Ressources OCI (réseau + bucket + API Gateway)
├── variables.tf            # Variables Terraform
├── outputs.tf              # Sorties (URL, IDs)
├── provider.tf             # Provider OCI + version Terraform
├── terraform.tfvars.example# Modèle de configuration (à copier en terraform.tfvars)
├── scripts/
│   ├── 01_install_terraform.ps1
│   ├── 02_generate_oci_keys.ps1
│   ├── 03_setup_tfvars.ps1
│   ├── 04_deploy.ps1
│   └── 05_destroy.ps1
└── .gitignore
```

## Déploiement GitHub Pages

Chaque push sur `main` déclenche automatiquement le workflow GitHub Actions qui publie le dossier `dist/` sur GitHub Pages.

URL publique : `https://<votre-username>.github.io/oci-frontend-app/`

## Déploiement OCI avec Terraform

### Prérequis

- Compte Oracle Cloud Infrastructure (Free Tier suffisant)
- Terraform ≥ 1.3.0
- OpenSSL

### Étapes

```powershell
# 1. Générer les clés API OCI
.\scripts\02_generate_oci_keys.ps1

# 2. Renseigner vos OCIDs (crée terraform.tfvars + ~/.oci/config)
.\scripts\03_setup_tfvars.ps1

# 3. Déployer
.\scripts\04_deploy.ps1
```

### Ressources créées par Terraform

| Ressource | Nom |
|---|---|
| VCN | `<app_name>-vcn` |
| Internet Gateway | `<app_name>-igw` |
| Route Table | `<app_name>-route-table` |
| Security List | `<app_name>-security-list` |
| Subnet public | `<app_name>-public-subnet` |
| Bucket Object Storage | `<app_name>-bucket` |
| API Gateway | `<app_name>-gateway` |
| API Gateway Deployment | `<app_name>-deployment` |

### Nettoyage

```powershell
.\scripts\05_destroy.ps1
```

## Sécurité

- Ne jamais committer `terraform.tfvars` (contient vos OCIDs et clés)
- Le fichier est protégé par `.gitignore`
