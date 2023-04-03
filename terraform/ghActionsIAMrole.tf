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