# variables.tf
# Définit toutes les variables d'entrée du projet Terraform.

variable "tenancy_ocid" {
  description = "The OCID of the tenancy."
  type        = string
}

variable "user_ocid" {
  description = "The OCID of the user."
  type        = string
}

variable "fingerprint" {
  description = "The fingerprint of the API key."
  type        = string
}

variable "private_key_path" {
  description = "The path to the private key file."
  type        = string
}

variable "region" {
  description = "The OCI region (e.g. eu-marseille-1)."
  type        = string
}

variable "compartment_ocid" {
  description = "The OCID of the compartment where resources will be created."
  type        = string
}

variable "app_name" {
  description = "Name of the frontend application (used as prefix for resource names)."
  type        = string
  default     = "my-frontend-app"
}

variable "source_path" {
  description = "Path to the compiled frontend application files (e.g. ./dist)."
  type        = string
  default     = "./dist"
}

