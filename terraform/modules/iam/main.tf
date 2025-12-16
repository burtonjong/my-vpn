data "aws_caller_identity" "current" {}

resource "aws_iam_role" "ssm_role" {
  name = "ec2_ssm_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "MyVpn"
  }
}
# this is something that confused me, since AmazonSSMManagedInstanceCore is pre made permission, thus its a policy attachment
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# don't use this anymore because we aren't using parameter store to store the client config
# resource "aws_iam_role_policy" "ssm_parameter_store" {
#   name = "ssm-parameter-store-access"
#   role = aws_iam_role.ssm_role.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "ssm:PutParameter",
#           "ssm:GetParameter",
#           "ssm:DeleteParameter"
#         ]
#         Resource = "arn:aws:ssm:*:*:parameter/wireguard/*"
#       }
#     ]
#   })
# }

resource "aws_iam_role_policy" "s3_vpn_bucket" {
  name = "myvpn-client-configuration-bucket-access"
  role = aws_iam_role.ssm_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
        ]
        Resource = [
          "${var.bucket_arn}/*",
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ec2_ssm_instance_profile"
  role = aws_iam_role.ssm_role.name

  tags = {
    Name = "MyVpn"
  }
}