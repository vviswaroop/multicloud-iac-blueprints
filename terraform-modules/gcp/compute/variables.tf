variable "name" {
  description = "Name prefix for compute resources"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "zone" {
  description = "GCP zone"
  type        = string
}

variable "machine_type" {
  description = "Machine type"
  type        = string
  default     = "e2-micro"
}

variable "image" {
  description = "Boot disk image"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2004-lts"
}

variable "disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
  default     = 20
}

variable "disk_type" {
  description = "Boot disk type"
  type        = string
  default     = "pd-standard"
}

variable "network" {
  description = "Network to attach"
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "Subnetwork to attach"
  type        = string
  default     = ""
}

variable "external_ip" {
  description = "Enable external IP"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Network tags"
  type        = list(string)
  default     = []
}

variable "metadata" {
  description = "Instance metadata"
  type        = map(string)
  default     = {}
}

variable "startup_script" {
  description = "Startup script"
  type        = string
  default     = ""
}

variable "service_account" {
  description = "Service account configuration"
  type = object({
    email  = string
    scopes = list(string)
  })
  default = null
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}