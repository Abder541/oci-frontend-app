# outputs.tf
# Affiche les informations utiles après le déploiement.

output "app_url" {
  description = "URL publique de l'application frontend déployée via l'API Gateway."
  value       = oci_apigateway_deployment.frontend_deployment.endpoint
}

output "bucket_name" {
  description = "Nom du bucket Object Storage contenant les fichiers frontend."
  value       = oci_objectstorage_bucket.frontend_bucket.name
}

output "bucket_namespace" {
  description = "Namespace Object Storage utilisé."
  value       = data.oci_objectstorage_namespace.this.namespace
}

output "object_storage_url" {
  description = "URL directe du bucket Object Storage (sans API Gateway)."
  value       = "https://${data.oci_objectstorage_namespace.this.namespace}.objectstorage.${var.region}.oci.customer-oci.com/n/${data.oci_objectstorage_namespace.this.namespace}/b/${oci_objectstorage_bucket.frontend_bucket.name}/o/index.html"
}

output "api_gateway_id" {
  description = "OCID de l'API Gateway créée."
  value       = oci_apigateway_gateway.frontend_api_gateway.id
}

output "vcn_id" {
  description = "OCID du VCN créé."
  value       = oci_core_vcn.frontend_vcn.id
}

output "subnet_id" {
  description = "OCID du subnet public créé."
  value       = oci_core_subnet.frontend_subnet.id
}

output "uploaded_files" {
  description = "Liste des fichiers uploadés dans le bucket."
  value       = keys(oci_objectstorage_object.app_files)
}
