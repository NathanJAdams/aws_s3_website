resource "aws_iam_role" "role" {
  name               = var.oidc_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.tags
}

resource "aws_iam_policy" "role_access" {
  name   = "${var.oidc_role_name}-read-write-bucket"
  policy = data.aws_iam_policy_document.role_access.json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "role_access" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.role_access.arn
}
