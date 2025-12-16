resource "aws_s3_bucket" "client_vpn_conf_files" {
  bucket        = "myvpn-client-conf"
  force_destroy = true

  tags = {
    Name = "MyVpn"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.client_vpn_conf_files.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}