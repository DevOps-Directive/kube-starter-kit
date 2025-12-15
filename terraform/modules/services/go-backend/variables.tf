# EKS cluster configuration
variable "eks_cluster_name" {
  description = "Name of the EKS cluster for pod identity association"
  type        = string
}

# Kubernetes configuration
variable "kubernetes_namespace" {
  description = "Kubernetes namespace where the go-backend service runs"
  type        = string
  default     = "go-backend-kustomize"
}

variable "kubernetes_service_account" {
  description = "Kubernetes service account name for the go-backend service"
  type        = string
  default     = "go-backend"
}

# S3 bucket configuration
variable "force_destroy" {
  description = "Whether to force destroy the S3 bucket (delete all objects) when the bucket is destroyed"
  type        = bool
  default     = false
}

variable "bucket_versioning_enabled" {
  description = "Whether to enable versioning on the S3 bucket"
  type        = bool
  default     = true
}
