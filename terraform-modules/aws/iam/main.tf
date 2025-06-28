data "aws_iam_policy_document" "assume_role" {
  count = var.create_role ? 1 : 0

  dynamic "statement" {
    for_each = length(var.trusted_role_services) > 0 ? [1] : []
    content {
      effect = "Allow"
      
      principals {
        type        = "Service"
        identifiers = var.trusted_role_services
      }
      
      actions = ["sts:AssumeRole"]
    }
  }

  dynamic "statement" {
    for_each = length(var.trusted_role_arns) > 0 ? [1] : []
    content {
      effect = "Allow"
      
      principals {
        type        = "AWS"
        identifiers = var.trusted_role_arns
      }
      
      actions = ["sts:AssumeRole"]
    }
  }
}

resource "aws_iam_role" "main" {
  count = var.create_role ? 1 : 0

  name                 = "${var.name}-role"
  assume_role_policy   = data.aws_iam_policy_document.assume_role[0].json
  max_session_duration = var.max_session_duration
  force_detach_policies = var.force_detach_policies

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-role"
    }
  )
}

resource "aws_iam_instance_profile" "main" {
  count = var.create_instance_profile && var.create_role ? 1 : 0

  name = "${var.name}-instance-profile"
  role = aws_iam_role.main[0].name

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-instance-profile"
    }
  )
}

resource "aws_iam_role_policy_attachment" "custom" {
  count = var.create_role ? length(var.custom_role_policy_arns) : 0

  role       = aws_iam_role.main[0].name
  policy_arn = var.custom_role_policy_arns[count.index]
}

resource "aws_iam_role_policy_attachment" "aws_managed" {
  count = var.create_role ? length(var.aws_managed_policy_arns) : 0

  role       = aws_iam_role.main[0].name
  policy_arn = var.aws_managed_policy_arns[count.index]
}

resource "aws_iam_role_policy" "inline" {
  for_each = var.create_role ? var.inline_policies : {}

  name   = each.key
  role   = aws_iam_role.main[0].id
  policy = each.value
}

resource "aws_iam_policy" "custom" {
  for_each = var.policy_documents

  name        = "${var.name}-${each.key}"
  description = "Custom policy for ${var.name}"
  policy      = each.value

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-${each.key}"
    }
  )
}

resource "aws_iam_user" "main" {
  count = var.create_user ? 1 : 0

  name          = "${var.name}-user"
  force_destroy = true

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-user"
    }
  )
}

resource "aws_iam_access_key" "main" {
  count = var.create_user && var.create_access_key ? 1 : 0

  user = aws_iam_user.main[0].name
}

resource "aws_iam_group" "main" {
  count = var.create_group ? 1 : 0

  name = "${var.name}-group"
}

resource "aws_iam_group_membership" "main" {
  count = var.create_group && length(var.group_users) > 0 ? 1 : 0

  name  = "${var.name}-group-membership"
  group = aws_iam_group.main[0].name
  users = var.group_users
}

resource "aws_iam_user_policy_attachment" "custom" {
  count = var.create_user ? length(var.custom_role_policy_arns) : 0

  user       = aws_iam_user.main[0].name
  policy_arn = var.custom_role_policy_arns[count.index]
}

resource "aws_iam_group_policy_attachment" "custom" {
  count = var.create_group ? length(var.custom_role_policy_arns) : 0

  group      = aws_iam_group.main[0].name
  policy_arn = var.custom_role_policy_arns[count.index]
}