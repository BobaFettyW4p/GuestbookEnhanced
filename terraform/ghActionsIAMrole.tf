resource "aws_iam_role" "ghActionsrole" {
  name               = "GithubActionsRole"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "AWS": "881363103454"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ghActions" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"
  ])

  role       = aws_iam_role.ghActionsrole.name
  policy_arn = each.value
}

module "github-oidc" {
  source  = "terraform-module/github-oidc-provider/aws"
  version = "2.1.0"

  create_oidc_provider = true
  create_oidc_role     = true

  repositories = ["terraform-module/module-blueprint"]
  oidc_role_attach_policies = [
    "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"
  ]
  role_name        = "GithubActionsRoleOIDC"
  role_description = "Role for Github Actions"
}