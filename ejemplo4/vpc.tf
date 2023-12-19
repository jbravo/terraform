resource "aws_vpc" "VPC1_Virginia" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name: "VPC1_Virginia"
  }
}