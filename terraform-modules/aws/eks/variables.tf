variable "name" {
  description = "Name prefix for EKS resources"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "endpoint_config" {
  description = "EKS cluster endpoint configuration"
  type = object({
    private_access = optional(bool, true)
    public_access  = optional(bool, true)
    public_access_cidrs = optional(list(string), ["0.0.0.0/0"])
  })
  default = {}
}

variable "enabled_cluster_log_types" {
  description = "List of control plane log types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cluster_encryption_config" {
  description = "Cluster encryption configuration"
  type = list(object({
    provider_key_arn = string
    resources        = list(string)
  }))
  default = []
}

variable "cluster_service_ipv4_cidr" {
  description = "Service IPv4 CIDR for the cluster"
  type        = string
  default     = null
}

variable "cluster_ip_family" {
  description = "IP family for the cluster"
  type        = string
  default     = "ipv4"
}

variable "node_groups" {
  description = "Map of EKS node group configurations"
  type = map(object({
    instance_types = list(string)
    capacity_type  = optional(string, "ON_DEMAND")
    ami_type       = optional(string, "AL2_x86_64")
    
    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number
    })
    
    update_config = optional(object({
      max_unavailable_percentage = optional(number, 25)
    }), {})
    
    subnet_ids = optional(list(string), [])
    
    remote_access = optional(object({
      ec2_ssh_key               = optional(string)
      source_security_group_ids = optional(list(string), [])
    }))
    
    labels = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
    
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "fargate_profiles" {
  description = "Map of EKS Fargate profile configurations"
  type = map(object({
    subnet_ids = list(string)
    
    selectors = list(object({
      namespace = string
      labels    = optional(map(string), {})
    }))
    
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "cluster_addons" {
  description = "Map of cluster addon configurations"
  type = map(object({
    addon_version               = optional(string)
    resolve_conflicts_on_create = optional(string, "OVERWRITE")
    resolve_conflicts_on_update = optional(string, "OVERWRITE")
    service_account_role_arn    = optional(string)
    configuration_values       = optional(string)
    tags                       = optional(map(string), {})
  }))
  default = {
    coredns = {
      addon_version = "v1.10.1-eksbuild.5"
    }
    kube-proxy = {
      addon_version = "v1.28.2-eksbuild.2"
    }
    vpc-cni = {
      addon_version = "v1.15.1-eksbuild.1"
    }
  }
}

variable "enable_irsa" {
  description = "Enable IAM Roles for Service Accounts"
  type        = bool
  default     = true
}

variable "openid_connect_audiences" {
  description = "List of audiences for the OpenID Connect identity provider"
  type        = list(string)
  default     = []
}

variable "cluster_security_group_additional_rules" {
  description = "Additional security group rules for the cluster security group"
  type = map(object({
    description              = string
    protocol                 = string
    from_port                = number
    to_port                  = number
    type                     = string
    cidr_blocks              = optional(list(string))
    source_security_group_id = optional(string)
  }))
  default = {}
}

variable "node_security_group_additional_rules" {
  description = "Additional security group rules for the node security group"
  type = map(object({
    description              = string
    protocol                 = string
    from_port                = number
    to_port                  = number
    type                     = string
    cidr_blocks              = optional(list(string))
    source_security_group_id = optional(string)
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}