// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

module "go_backend" {
  bucket_versioning_enabled  = true
  eks_cluster_name           = var.eks_cluster_name
  environment                = "use2"
  force_destroy              = true
  kubernetes_namespace       = "go-backend-kustomize"
  kubernetes_service_account = "go-backend"
  name                       = "go-backend"
  namespace                  = "ksk"
  source                     = "../../../../../../terraform/modules/services//go-backend"
  stage                      = "staging"
}
