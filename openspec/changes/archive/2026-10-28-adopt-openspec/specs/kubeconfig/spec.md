## ADDED Requirements

### Requirement: Kubeconfig retrieval per cluster
The module SHALL read one kubeconfig data source for each cluster whose `enable_kubeconfig` is `true`. `enable_kubeconfig` SHALL default to `true`. The optional `kubeconfig_user`, `kubeconfig_group`, `kubeconfig_ttl` and `kubeconfig_x_encrypt_nacl` (all default `null`) SHALL be passed to the data source as `user`, `group`, `ttl` and `x_encrypt_nacl`.

#### Scenario: Enabled by default
- **WHEN** a cluster does not set `enable_kubeconfig`
- **THEN** one kubeconfig data source is planned for that cluster

#### Scenario: Disabled
- **WHEN** a cluster sets `enable_kubeconfig = false`
- **THEN** no kubeconfig data source is planned for that cluster

#### Scenario: Custom user and TTL
- **WHEN** a cluster sets `kubeconfig_user = "admin"` and `kubeconfig_ttl = "24h"`
- **THEN** the data source is read with `user = "admin"` and `ttl = "24h"`

### Requirement: Kubeconfig outputs
The module SHALL expose `kubeconfigs` (cluster key to kubeconfig content) and `kubeconfig_attributes` (cluster key to the host, cluster CA certificate, client certificate and client key attributes, for configuring the kubernetes and helm providers). Both SHALL contain only clusters with `enable_kubeconfig = true` and SHALL be sensitive.

#### Scenario: Only enabled clusters
- **WHEN** cluster `dev` sets `enable_kubeconfig = false` and cluster `prod` keeps the default
- **THEN** `kubeconfigs` and `kubeconfig_attributes` contain the key `prod` and not `dev`

#### Scenario: All disabled
- **WHEN** every cluster sets `enable_kubeconfig = false`
- **THEN** `kubeconfigs` is an empty map
