# ─── Project Variables (Required) ────────────────────────────────────

variable "project_name" {
  description = "Name of the OKS project (2-40 chars, lowercase alphanumeric and hyphens, must start with letter and end with letter or number)"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.project_name)) && length(var.project_name) >= 2 && length(var.project_name) <= 40
    error_message = "Project name must be 2-40 characters, lowercase alphanumeric and hyphens, start with a letter and end with a letter or number."
  }
}

variable "project_cidr" {
  description = "CIDR block to associate with the Net of the OKS project (e.g., '10.0.0.0/16')"
  type        = string

  validation {
    condition     = can(cidrhost(var.project_cidr, 0))
    error_message = "project_cidr must be a valid CIDR notation (e.g., '10.0.0.0/16')."
  }
}

variable "region" {
  description = "Outscale region for the OKS project deployment (e.g., 'eu-west-2', 'cloudgouv-eu-west-1')"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]+$", var.region))
    error_message = "Region must be a valid Outscale region identifier (e.g., 'eu-west-2')."
  }
}

# ─── Cluster Variables (Required) ────────────────────────────────────

variable "cluster_name" {
  description = "Name of the OKS cluster (2-40 chars, lowercase alphanumeric and hyphens, must start with letter and end with letter or number)"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.cluster_name)) && length(var.cluster_name) >= 2 && length(var.cluster_name) <= 40
    error_message = "Cluster name must be 2-40 characters, lowercase alphanumeric and hyphens, start with a letter and end with a letter or number."
  }
}

variable "kubernetes_version" {
  description = "Kubernetes version to deploy for the OKS cluster (e.g., '1.31'). Use outscale_oks_quotas data source to list available versions"
  type        = string

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+", var.kubernetes_version))
    error_message = "kubernetes_version must be a valid version string (e.g., '1.31')."
  }
}

variable "cidr_pods" {
  description = "CIDR block for the pod network (e.g., '10.91.0.0/16'). Must not overlap with project CIDR or service CIDR"
  type        = string

  validation {
    condition     = can(cidrhost(var.cidr_pods, 0))
    error_message = "cidr_pods must be a valid CIDR notation (e.g., '10.91.0.0/16')."
  }
}

variable "cidr_service" {
  description = "CIDR block for the service network (e.g., '10.92.0.0/16'). Must not overlap with project CIDR or pod CIDR"
  type        = string

  validation {
    condition     = can(cidrhost(var.cidr_service, 0))
    error_message = "cidr_service must be a valid CIDR notation (e.g., '10.92.0.0/16')."
  }
}

variable "admin_whitelist" {
  description = "List of CIDR blocks allowed to access the Kubernetes API server. Use specific ranges, never '0.0.0.0/0' in production"
  type        = list(string)

  validation {
    condition     = length(var.admin_whitelist) > 0
    error_message = "admin_whitelist must contain at least one CIDR block."
  }

  validation {
    condition     = alltrue([for cidr in var.admin_whitelist : can(cidrhost(cidr, 0))])
    error_message = "Each item in admin_whitelist must be a valid CIDR block (e.g., '203.0.113.0/24', '198.51.100.10/32')."
  }
}

# ─── Project Variables (Optional) ────────────────────────────────────

variable "project_description" {
  description = "Description of the OKS project (max 40 characters)"
  type        = string
  default     = null

  validation {
    condition     = var.project_description == null || length(var.project_description) <= 40
    error_message = "project_description must be 40 characters or fewer."
  }
}

variable "enable_project_api_termination_protection" {
  description = "Enable API termination protection for the OKS project. Set to true for production"
  type        = bool
  default     = false
}

# ─── Cluster Variables (Optional) ────────────────────────────────────

variable "cluster_description" {
  description = "Description of the OKS cluster"
  type        = string
  default     = null
}

variable "control_planes" {
  description = "Control plane sizing specification (e.g., 'cp.3.masters.small', 'cp.3.masters.medium')"
  type        = string
  default     = "cp.3.masters.small"
}

variable "enable_cp_multi_az" {
  description = "Enable multi-AZ deployment for the control plane. Recommended for production workloads"
  type        = bool
  default     = false
}

variable "enable_admin_lbu" {
  description = "Enable load balancer for Kubernetes API administration"
  type        = bool
  default     = false
}

variable "enable_cluster_api_termination_protection" {
  description = "Enable API termination protection for the OKS cluster. Set to true for production"
  type        = bool
  default     = false
}

# ─── Data Source Variables ────────────────────────────────────────────

variable "enable_kubeconfig" {
  description = "Enable retrieval of the kubeconfig data source for the cluster"
  type        = bool
  default     = true
}

variable "kubeconfig_user" {
  description = "User name for the kubeconfig credential"
  type        = string
  default     = null
}

variable "kubeconfig_group" {
  description = "Group for the kubeconfig credential"
  type        = string
  default     = null
}

variable "kubeconfig_ttl" {
  description = "Time-to-live for the kubeconfig token (e.g., '24h')"
  type        = string
  default     = null
}

variable "kubeconfig_x_encrypt_nacl" {
  description = "NaCl public key for encrypting the kubeconfig. When set, the kubeconfig is returned encrypted"
  type        = string
  default     = null
  sensitive   = true
}

variable "enable_quotas" {
  description = "Enable retrieval of OKS account quotas data source"
  type        = bool
  default     = false
}

# ─── Tag Variables ────────────────────────────────────────────────────

variable "tags" {
  description = "Tags to apply to all OKS resources. Merged with module-managed tags"
  type        = map(string)
  default     = {}
}

variable "project_tags" {
  description = "Additional tags to apply only to the OKS project. Merged with common tags"
  type        = map(string)
  default     = {}
}

variable "cluster_tags" {
  description = "Additional tags to apply only to the OKS cluster. Merged with common tags"
  type        = map(string)
  default     = {}
}
