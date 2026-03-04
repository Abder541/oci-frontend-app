# main.tf
# Ressources principales : Object Storage Bucket + API Gateway OCI.

# ─────────────────────────────────────────────────────────────────────────────
# DATA SOURCES
# ─────────────────────────────────────────────────────────────────────────────

# Récupère le namespace Object Storage de la tenancy
data "oci_objectstorage_namespace" "this" {
  compartment_id = var.tenancy_ocid
}

# ─────────────────────────────────────────────────────────────────────────────
# RÉSEAU (VCN, Internet Gateway, Route Table, Security List, Subnet)
# ─────────────────────────────────────────────────────────────────────────────

resource "oci_core_vcn" "frontend_vcn" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.app_name}-vcn"
  cidr_blocks    = ["10.0.0.0/16"]
  dns_label      = "frontend"

  freeform_tags = {
    "project" = var.app_name
    "managed" = "terraform"
  }
}

resource "oci_core_internet_gateway" "frontend_igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.frontend_vcn.id
  display_name   = "${var.app_name}-igw"
  enabled        = true

  freeform_tags = {
    "project" = var.app_name
    "managed" = "terraform"
  }
}

resource "oci_core_route_table" "frontend_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.frontend_vcn.id
  display_name   = "${var.app_name}-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.frontend_igw.id
  }

  freeform_tags = {
    "project" = var.app_name
    "managed" = "terraform"
  }
}

resource "oci_core_security_list" "frontend_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.frontend_vcn.id
  display_name   = "${var.app_name}-security-list"

  # Tout le trafic sortant autorisé
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    stateless   = false
  }

  # HTTPS entrant (port 443) – requis pour l'API Gateway public
  ingress_security_rules {
    protocol  = "6" # TCP
    source    = "0.0.0.0/0"
    stateless = false
    tcp_options {
      min = 443
      max = 443
    }
  }

  # HTTP entrant (port 80) – optionnel
  ingress_security_rules {
    protocol  = "6" # TCP
    source    = "0.0.0.0/0"
    stateless = false
    tcp_options {
      min = 80
      max = 80
    }
  }

  freeform_tags = {
    "project" = var.app_name
    "managed" = "terraform"
  }
}

resource "oci_core_subnet" "frontend_subnet" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.frontend_vcn.id
  display_name      = "${var.app_name}-public-subnet"
  cidr_block        = "10.0.1.0/24"
  route_table_id    = oci_core_route_table.frontend_rt.id
  security_list_ids = [oci_core_security_list.frontend_sl.id]
  dns_label         = "public"

  # Subnet public : les VNICs peuvent recevoir une IP publique
  prohibit_public_ip_on_vnic = false

  freeform_tags = {
    "project" = var.app_name
    "managed" = "terraform"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# OBJECT STORAGE BUCKET
# ─────────────────────────────────────────────────────────────────────────────

resource "oci_objectstorage_bucket" "frontend_bucket" {
  compartment_id = var.compartment_ocid
  name           = "${var.app_name}-bucket"
  namespace      = data.oci_objectstorage_namespace.this.namespace

  # Accès en lecture publique pour que l'API Gateway puisse servir les objets
  access_type = "ObjectRead"

  # Optionnel : versioning désactivé pour l'hébergement statique
  versioning = "Disabled"

  freeform_tags = {
    "project" = var.app_name
    "managed" = "terraform"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# UPLOAD DES FICHIERS FRONTEND
# ─────────────────────────────────────────────────────────────────────────────

locals {
  mime_types = {
    "html" = "text/html"
    "css"  = "text/css"
    "js"   = "application/javascript"
    "json" = "application/json"
    "png"  = "image/png"
    "jpg"  = "image/jpeg"
    "jpeg" = "image/jpeg"
    "gif"  = "image/gif"
    "svg"  = "image/svg+xml"
    "ico"  = "image/x-icon"
    "txt"  = "text/plain"
    "map"  = "application/json"
    "woff" = "font/woff"
    "woff2" = "font/woff2"
  }
}

resource "oci_objectstorage_object" "app_files" {
  for_each = fileset(var.source_path, "**/*")

  bucket_name = oci_objectstorage_bucket.frontend_bucket.name
  namespace   = data.oci_objectstorage_namespace.this.namespace

  # Conserve l'arborescence de répertoires dans le bucket
  name    = each.value
  content = file("${var.source_path}/${each.value}")

  # Détermine le Content-Type à partir de l'extension du fichier
  content_type = lookup(
    local.mime_types,
    try(regex(".*\\.(.*)$", each.value)[0], ""),
    "application/octet-stream"
  )

  # Cache-Control pour améliorer les performances côté navigateur
  cache_control = contains(["html"], try(regex(".*\\.(.*)$", each.value)[0], "")) ? "no-cache, no-store, must-revalidate" : "public, max-age=31536000, immutable"
}

# ─────────────────────────────────────────────────────────────────────────────
# API GATEWAY
# ─────────────────────────────────────────────────────────────────────────────

resource "oci_apigateway_gateway" "frontend_api_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.app_name}-gateway"
  endpoint_type  = "PUBLIC"
  subnet_id      = oci_core_subnet.frontend_subnet.id

  freeform_tags = {
    "project" = var.app_name
    "managed" = "terraform"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# API GATEWAY DEPLOYMENT
# ─────────────────────────────────────────────────────────────────────────────

resource "oci_apigateway_deployment" "frontend_deployment" {
  compartment_id = var.compartment_ocid
  gateway_id     = oci_apigateway_gateway.frontend_api_gateway.id
  display_name   = "${var.app_name}-deployment"
  path_prefix    = "/"

  specification {
    # ── Politiques globales ─────────────────────────────────────────────────
    request_policies {
      cors {
        allowed_origins    = ["*"]
        allowed_methods    = ["GET"]
        allowed_headers    = ["*"]
        expose_headers     = ["*"]
        max_age_in_seconds = 300
      }
    }

    # ── Route principale : tous les chemins → Object Storage ────────────────
    routes {
      path    = "/{path*}"
      methods = ["GET"]

      backend {
        type = "HTTP_BACKEND"
        # URL de base de l'Object Storage ; l'API Gateway transmet le chemin demandé
        url = "https://${data.oci_objectstorage_namespace.this.namespace}.objectstorage.${var.region}.oci.customer-oci.com/n/${data.oci_objectstorage_namespace.this.namespace}/b/${oci_objectstorage_bucket.frontend_bucket.name}/o/$${request.path[path]}"
      }
    }

    # ── Route pour la racine → index.html ───────────────────────────────────
    routes {
      path    = "/"
      methods = ["GET"]

      backend {
        type = "HTTP_BACKEND"
        url  = "https://${data.oci_objectstorage_namespace.this.namespace}.objectstorage.${var.region}.oci.customer-oci.com/n/${data.oci_objectstorage_namespace.this.namespace}/b/${oci_objectstorage_bucket.frontend_bucket.name}/o/index.html"
      }
    }
  }

  freeform_tags = {
    "project" = var.app_name
    "managed" = "terraform"
  }
}
