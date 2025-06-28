variable "name" {
  description = "Name prefix for EC2 resources"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the AWS key pair"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "ID of the subnet to launch the instance in"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs to assign to the instance"
  type        = list(string)
  default     = []
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with the instance"
  type        = bool
  default     = false
}

variable "user_data" {
  description = "User data to provide when launching the instance"
  type        = string
  default     = ""
}

variable "iam_instance_profile" {
  description = "Name of the IAM instance profile to attach"
  type        = string
  default     = ""
}

variable "root_block_device" {
  description = "Configuration for the root block device"
  type = object({
    volume_type           = optional(string, "gp3")
    volume_size           = optional(number, 20)
    delete_on_termination = optional(bool, true)
    encrypted             = optional(bool, true)
  })
  default = {}
}

variable "ebs_block_devices" {
  description = "Additional EBS block devices to attach to the instance"
  type = list(object({
    device_name           = string
    volume_type           = optional(string, "gp3")
    volume_size           = number
    delete_on_termination = optional(bool, true)
    encrypted             = optional(bool, true)
  }))
  default = []
}

variable "monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false
}

variable "disable_api_termination" {
  description = "Enable instance termination protection"
  type        = bool
  default     = false
}

variable "create_security_group" {
  description = "Whether to create a default security group"
  type        = bool
  default     = true
}

variable "security_group_rules" {
  description = "Security group rules"
  type = list(object({
    type        = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string), [])
    description = optional(string, "")
  }))
  default = [
    {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "All outbound traffic"
    }
  ]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}