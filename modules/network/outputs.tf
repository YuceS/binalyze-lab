output "vpc" {
  value = aws_vpc.main
}
output "public_subnet" {
  value = aws_subnet.public
}
output "flow_logs" {
  value = aws_s3_bucket.flow_logs
}
