# ─── Projects ────────────────────────────────────────────────────────

variable "projects" {
  description = "Map of OKS projects to create. Keys are logical identifiers used to reference projects from clusters"
  type = map(object({
    name                              = string
    cidr                              = string
    region                            = string
    description                       = optional(string)
    enable_api_termination_protection = optional(bool, false)
    tags                              = optional(map(string), {})
  }))

  validation {
    condition     = length(var.projects) > 0
    error_message = "At least one project must be defined."
  }

  validation {
    condition = alltrue([
      for k, v in var.projects :
      can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", v.name)) && length(v.name) >= 2 && length(v.name) <= 40
    ])
    error_message = "Project names must be 2-40 characters, lowercase alphanumeric and hyphens, start with a letter and end with a letter or number."
  }

  validation {
    condition     = alltrue([for k, v in var.projects : can(cidrhost(v.cidr, 0))])
    error_message = "Project CIDRs must be valid CIDR notation (e.g., '10.0.0.0/16')."
  }

  validation {
    condition     = alltrue([for k, v in var.projects : can(regex("^[a-z][a-z0-9-]+$", v.region))])
    error_message = "Project regions must be valid Outscale region identifiers (e.g., 'eu-west-2')."
  }

  validation {
    condition     = alltrue([for k, v in var.projects : v.description == null || length(v.description) <= 40])
    error_message = "Project descriptions must be 40 characters or fewer."
  }
}

# ─── Clusters ────────────────────────────────────────────────────────

variable "clusters" {
  description = "Map of OKS clusters to create. Keys are logical identifiers. Each cluster references a project via project_key"
  type = map(object({
    name                              = string
    project_key                       = string
    kubernetes_version                = string
    cidr_pods                         = string
    cidr_service                      = string
    admin_whitelist                   = list(string)
    control_planes                    = optional(string, "cp.3.masters.small")
    description                       = optional(string)
    enable_cp_multi_az                = optional(bool, false)
    enable_admin_lbu                  = optional(bool, false)
    enable_api_termination_protection = optional(bool, false)
    enable_kubeconfig                 = optional(bool, true)
    kubeconfig_user                   = optional(string)
    kubeconfig_group                  = optional(string)
    kubeconfig_ttl                    = optional(string)
    kubeconfig_x_encrypt_nacl         = optional(string)
    tags                              = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.clusters :
      can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", v.name)) && length(v.name) >= 2 && length(v.name) <= 40
    ])
    error_message = "Cluster names must be 2-40 characters, lowercase alphanumeric and hyphens, start with a letter and end with a letter or number."
  }

  validation {
    condition     = alltrue([for k, v in var.clusters : can(regex("^[0-9]+\\.[0-9]+", v.kubernetes_version))])
    error_message = "Cluster kubernetes_version must be a valid version string (e.g., '1.31')."
  }

  validation {
    condition     = alltrue([for k, v in var.clusters : can(cidrhost(v.cidr_pods, 0))])
    error_message = "Cluster cidr_pods must be valid CIDR notation (e.g., '10.91.0.0/16')."
  }

  validation {
    condition     = alltrue([for k, v in var.clusters : can(cidrhost(v.cidr_service, 0))])
    error_message = "Cluster cidr_service must be valid CIDR notation (e.g., '10.92.0.0/16')."
  }

  validation {
    condition     = alltrue([for k, v in var.clusters : length(v.admin_whitelist) > 0])
    error_message = "Cluster admin_whitelist must contain at least one CIDR block."
  }

  validation {
    condition = alltrue([
      for k, v in var.clusters :
      alltrue([for entry in v.admin_whitelist : can(cidrhost(entry, 0)) || can(cidrhost("${entry}/32", 0))])
    ])
    error_message = "Each item in cluster admin_whitelist must be an IP address or a CIDR block (e.g., '203.0.113.10' or '203.0.113.0/24')."
  }
}

# ─── Node Pools ──────────────────────────────────────────────────────

variable "node_pools" {
  description = "Map of OKS node pools to create. Keys are logical identifiers. Each node pool references a cluster via cluster_key"
  type = map(object({
    name                = string
    cluster_key         = string
    node_type           = string
    desired_nodes       = number
    zones               = list(string)
    min_nodes           = optional(number)
    max_nodes           = optional(number)
    enable_autoscaling  = optional(bool, false)
    enable_auto_healing = optional(bool, false)
    volumes = optional(list(object({
      device = string
      type   = string
      size   = number
      iops   = optional(number)
      dir    = optional(string)
    })), [])
    extra_spec = optional(any, {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.node_pools :
      can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", v.name)) && length(v.name) >= 2 && length(v.name) <= 40
    ])
    error_message = "Node pool names must be 2-40 characters, lowercase alphanumeric and hyphens, start with a letter and end with a letter or number."
  }

  validation {
    condition     = alltrue([for k, v in var.node_pools : v.desired_nodes >= 1])
    error_message = "Node pool desired_nodes must be at least 1."
  }

  validation {
    condition     = alltrue([for k, v in var.node_pools : length(v.zones) > 0])
    error_message = "Node pool zones must contain at least one availability zone."
  }

  validation {
    condition = alltrue([
      for k, v in var.node_pools :
      !v.enable_autoscaling || (v.min_nodes != null && v.max_nodes != null)
    ])
    error_message = "Node pool min_nodes and max_nodes are required when enable_autoscaling is true."
  }

  validation {
    condition = alltrue([
      for k, v in var.node_pools :
      !v.enable_autoscaling || (v.min_nodes != null && v.max_nodes != null && v.min_nodes <= v.desired_nodes && v.desired_nodes <= v.max_nodes)
    ])
    error_message = "Node pool autoscaling requires min_nodes <= desired_nodes <= max_nodes."
  }

  validation {
    condition = alltrue([
      for k, v in var.node_pools :
      alltrue([for vol in v.volumes : contains(["standard", "gp2", "io1"], vol.type)])
    ])
    error_message = "Node pool volume type must be one of: standard, gp2, io1."
  }

  validation {
    condition = alltrue([
      for k, v in var.node_pools :
      alltrue([for vol in v.volumes : vol.type != "io1" || vol.iops != null])
    ])
    error_message = "Node pool volume iops is required when volume type is io1."
  }
}

# ─── Data Source Variables ───────────────────────────────────────────

variable "enable_quotas" {
  description = "Enable retrieval of OKS account quotas data source"
  type        = bool
  default     = false
}

# ─── Tag Variables ───────────────────────────────────────────────────

variable "tags" {
  description = "Tags to apply to all OKS resources. Merged with module-managed tags"
  type        = map(string)
  default     = {}
}
