resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name}"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet
  availability_zone = var.az

  tags = {
    Name = "${var.name}-public"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet
  availability_zone = var.az

  tags = {
    Name = "${var.name}-private"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-igw"
  }
}

resource "aws_route" "default" {
  route_table_id         = aws_vpc.this.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "tls_private_key" "workload_access" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion_ssh_access" {
  public_key = var.ssh_public_key
}

resource "aws_security_group" "bastion_sg" {
  name   = "${var.name}-bastion-sg"
  vpc_id = aws_vpc.this.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ping"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_instance" "bastion" {
  depends_on = [
    aws_key_pair.bastion_ssh_access,
    aws_security_group.bastion_sg
  ]
  ami                         = var.ec2_ami
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.bastion_ssh_access.key_name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  user_data = templatefile(
    "${path.module}/files/bastion.sh.tpl",
    { host_private_key : tls_private_key.workload_access.private_key_pem }
  )

  tags = {
    Name = "${var.name}-bastion"
  }
}

resource "aws_key_pair" "workload_ssh_access" {
  public_key = tls_private_key.workload_access.public_key_openssh
}

resource "aws_security_group" "workload_sg" {
  name   = "${var.name}-workload-sg"
  vpc_id = aws_vpc.this.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.public_subnet]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.ingress_allowed_cidrs
  }


  ingress {
    description = "ping"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = var.ingress_allowed_cidrs
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_instance" "workload" {
  depends_on = [
    aws_route.default,
    aws_key_pair.workload_ssh_access,
    aws_security_group.workload_sg
  ]
  ami                         = var.ec2_ami
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.workload_ssh_access.key_name
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.workload_sg.id]
  associate_public_ip_address = true # XC forces inside subnet to share route table with outside subnet. So aws instances in inside subnet will have default route via Internet Gateway, which requires instances to have public IP to get internet access
  user_data = templatefile(
    "${path.module}/files/user_data.sh.tpl",
    { node_name : var.name }
  )

  tags = {
    Name = "${var.name}-workload"
  }
}
