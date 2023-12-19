data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "vpc_a_ec2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_vpc_a.id]
  subnet_id                   = aws_subnet.vpc_a_subnet_public_1a.id
  tags = {
    Name = "vpc_a_ec2"
  }
}

resource "aws_instance" "vpc_b_ec2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_vpc_b.id]
  subnet_id                   = aws_subnet.vpc_b_subnet_private_1a.id
  tags = {
    Name = "vpc_b_ec2"
  }
}