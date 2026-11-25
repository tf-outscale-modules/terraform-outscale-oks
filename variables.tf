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
  description = "Map of OKS clusters to create. Keys are logical identifiers. Each cluster references a project via project_key. Optional auto_maintenances, cp_subregions, admission_flags and cluster_dns are only sent when set; changing cp_subregions or cluster_dns forces replacement of the cluster"
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
    # null = not sent, the server applies its defaults. Windows: week_day is Mon..Sun, start_hour 0..23.
    auto_maintenances = optional(object({
      minor_upgrade_maintenance = optional(object({
        enabled        = optional(bool)
        duration_hours = optional(number)
        start_hour     = optional(number)
        tz             = optional(string)
        week_day       = optional(string)
      }))
      patch_upgrade_maintenance = optional(object({
        enabled        = optional(bool)
        duration_hours = optional(number)
        start_hour     = optional(number)
        tz             = optional(string)
        week_day       = optional(string)
      }))
    }))
    # Subregions of the control plane, e.g. ["eu-west-2a", "eu-west-2b"]. Changing it forces replacement of the cluster.
    cp_subregions = optional(set(string))
    admission_flags = optional(object({
      enable_admission_plugins  = optional(set(string))
      disable_admission_plugins = optional(set(string))
    }))
    # IPv4 of the cluster DNS service. Changing it forces replacement of the cluster.
    cluster_dns = optional(string)
    tags        = optional(map(string), {})
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
    condition     = alltrue([for k, v in var.clusters : can(regex("^[0-9]+\\.[0-9]+(\\.[0-9]+)?$", v.kubernetes_version))])
    error_message = "Cluster kubernetes_version must be a valid version string (e.g., '1.31')."
  }

  validation {
    condition     = alltrue([for k, v in var.clusters : contains(keys(var.projects), v.project_key)])
    error_message = "Each cluster project_key must match a key of var.projects."
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

  validation {
    condition = alltrue([
      for w in flatten([
        for k, v in var.clusters : v.auto_maintenances == null ? [] : [
          for w in [v.auto_maintenances.minor_upgrade_maintenance, v.auto_maintenances.patch_upgrade_maintenance] : w if w != null
        ]
      ]) : w.week_day == null || contains(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], w.week_day)
    ])
    error_message = "Cluster auto_maintenances week_day must be one of: Mon, Tue, Wed, Thu, Fri, Sat, Sun."
  }

  validation {
    condition = alltrue([
      for w in flatten([
        for k, v in var.clusters : v.auto_maintenances == null ? [] : [
          for w in [v.auto_maintenances.minor_upgrade_maintenance, v.auto_maintenances.patch_upgrade_maintenance] : w if w != null
        ]
      ]) : w.start_hour == null || (w.start_hour >= 0 && w.start_hour <= 23 && w.start_hour == floor(w.start_hour))
    ])
    error_message = "Cluster auto_maintenances start_hour must be between 0 and 23."
  }

  validation {
    condition = alltrue([
      for w in flatten([
        for k, v in var.clusters : v.auto_maintenances == null ? [] : [
          for w in [v.auto_maintenances.minor_upgrade_maintenance, v.auto_maintenances.patch_upgrade_maintenance] : w if w != null
        ]
      ]) : w.duration_hours == null || (w.duration_hours >= 0 && w.duration_hours == floor(w.duration_hours))
    ])
    error_message = "Cluster auto_maintenances duration_hours must be 0 or more."
  }

  validation {
    condition = alltrue([
      for w in flatten([
        for k, v in var.clusters : v.auto_maintenances == null ? [] : [
          for w in [v.auto_maintenances.minor_upgrade_maintenance, v.auto_maintenances.patch_upgrade_maintenance] : w if w != null
        ]
      ]) : w.tz == null || length(w.tz) > 0
    ])
    error_message = "Cluster auto_maintenances tz must not be empty."
  }

  validation {
    condition = alltrue([
      for k, v in var.clusters :
      v.cp_subregions == null || (length(v.cp_subregions) > 0 && alltrue([for z in v.cp_subregions : can(regex("^[a-z][a-z0-9-]*[a-z]$", z))]))
    ])
    error_message = "Cluster cp_subregions must contain at least one Subregion name (e.g., 'eu-west-2a')."
  }

  validation {
    condition = alltrue([
      for k, v in var.clusters :
      v.cluster_dns == null || (can(regex("^[0-9]{1,3}(\\.[0-9]{1,3}){3}$", v.cluster_dns)) && can(cidrhost("${v.cluster_dns}/32", 0)))
    ])
    error_message = "Cluster cluster_dns must be a valid IPv4 address (e.g., '10.92.0.10')."
  }

  validation {
    condition = alltrue([
      for k, v in var.clusters : v.admission_flags == null || alltrue([
        for p in setunion(
          v.admission_flags.enable_admission_plugins == null ? toset([]) : v.admission_flags.enable_admission_plugins,
          v.admission_flags.disable_admission_plugins == null ? toset([]) : v.admission_flags.disable_admission_plugins,
        ) : length(p) > 0
      ])
    ])
    error_message = "Cluster admission_flags plugin names must not be empty."
  }

  validation {
    condition = alltrue([
      for k, v in var.clusters : v.admission_flags == null || length(setintersection(
        v.admission_flags.enable_admission_plugins == null ? toset([]) : v.admission_flags.enable_admission_plugins,
        v.admission_flags.disable_admission_plugins == null ? toset([]) : v.admission_flags.disable_admission_plugins,
      )) == 0
    ])
    error_message = "Cluster admission_flags must not enable and disable the same plugin."
  }
}

# ─── Node Pools ──────────────────────────────────────────────────────

# DEVIATION(terraform-variables): `extra_spec` is `any`, the documented pass-through of provider-specific
# NodePool fields; typing it would break callers. Never put secrets in it (SECURITY.md).
variable "node_pools" {
  description = "Map of OKS node pools to create. Keys are logical identifiers. Each node pool references a cluster via cluster_key. Optional wait_for, enable_wait_on_delete, field_manager and skip_delete are only sent when set; skip_delete = true leaves the NodePool running in the cluster when the pool is removed (apply it before removal)"
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
    # null = not sent, the provider default applies.
    # wait_for: after apply, wait until every JSONPath field of the object matches its regex, e.g. { "status.progress.ready" = "1" }.
    wait_for = optional(object({
      fields  = map(string)
      timeout = optional(string)
    }))
    # Wait for the NodePool object to be deleted on destroy.
    enable_wait_on_delete = optional(bool)
    # Server-side apply field manager.
    field_manager = optional(object({
      name            = optional(string)
      force_conflicts = optional(bool)
    }))
    # true: destroying or removing the pool only drops it from the state; the NodePool and its nodes stay in the cluster (orphaned).
    # Apply skip_delete = true BEFORE removing the pool, otherwise the object is deleted.
    skip_delete = optional(bool)
    extra_spec  = optional(any, {})
  }))
  default = {}

  validation {
    condition     = alltrue([for k, v in var.node_pools : contains(keys(var.clusters), v.cluster_key)])
    error_message = "Each node pool cluster_key must match a key of var.clusters."
  }

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
      !v.enable_autoscaling || v.min_nodes == null || v.max_nodes == null || (v.min_nodes <= v.desired_nodes && v.desired_nodes <= v.max_nodes)
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

  validation {
    condition = alltrue([
      for k, v in var.node_pools :
      v.wait_for == null || (length(v.wait_for.fields) > 0 && alltrue([for f, _ in v.wait_for.fields : length(f) > 0]))
    ])
    error_message = "Node pool wait_for fields must contain at least one entry with a non-empty key."
  }

  validation {
    condition = alltrue([
      for k, v in var.node_pools :
      v.wait_for == null || v.wait_for.timeout == null || can(regex("^([0-9]+(\\.[0-9]+)?(ns|us|ms|s|m|h))+$", v.wait_for.timeout))
    ])
    error_message = "Node pool wait_for timeout must be a duration such as '15m' or '1h30m'."
  }

  validation {
    condition = alltrue([
      for k, v in var.node_pools :
      v.field_manager == null || v.field_manager.name == null || length(v.field_manager.name) > 0
    ])
    error_message = "Node pool field_manager name must not be empty."
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
