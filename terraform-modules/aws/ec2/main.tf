data "aws_ami" "default" {
  count       = var.ami_id == "" ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_subnet" "selected" {
  id = var.subnet_id
}

locals {
  ami_id = var.ami_id != "" ? var.ami_id : data.aws_ami.default[0].id
  security_group_ids = var.create_security_group ? concat([aws_security_group.main[0].id], var.vpc_security_group_ids) : var.vpc_security_group_ids
}

resource "aws_security_group" "main" {
  count = var.create_security_group ? 1 : 0

  name        = "${var.name}-sg"
  description = "Security group for ${var.name} EC2 instance"
  vpc_id      = data.aws_subnet.selected.vpc_id

  dynamic "ingress" {
    for_each = [for rule in var.security_group_rules : rule if rule.type == "ingress"]
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  dynamic "egress" {
    for_each = [for rule in var.security_group_rules : rule if rule.type == "egress"]
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
      description = egress.value.description
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-sg"
    }
  )
}

resource "aws_instance" "main" {
  ami                         = local.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name != "" ? var.key_name : null
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = local.security_group_ids
  associate_public_ip_address = var.associate_public_ip_address
  user_data                   = var.user_data != "" ? var.user_data : null
  iam_instance_profile        = var.iam_instance_profile != "" ? var.iam_instance_profile : null
  monitoring                  = var.monitoring
  disable_api_termination     = var.disable_api_termination

  root_block_device {
    volume_type           = var.root_block_device.volume_type
    volume_size           = var.root_block_device.volume_size
    delete_on_termination = var.root_block_device.delete_on_termination
    encrypted             = var.root_block_device.encrypted
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_devices
    content {
      device_name           = ebs_block_device.value.device_name
      volume_type           = ebs_block_device.value.volume_type
      volume_size           = ebs_block_device.value.volume_size
      delete_on_termination = ebs_block_device.value.delete_on_termination
      encrypted             = ebs_block_device.value.encrypted
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )

  volume_tags = merge(
    var.tags,
    {
      Name = "${var.name}-volume"
    }
  )
}