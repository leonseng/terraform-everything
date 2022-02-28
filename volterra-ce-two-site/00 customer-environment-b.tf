module "vpc_b" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = "${random_id.id.dec}-b"
  cidr                 = "10.0.0.0/16"
  azs                  = [data.aws_availability_zones.local_az.names[0]]
  public_subnets       = ["10.0.1.0/24"]
  enable_nat_gateway   = true
  enable_dns_hostnames = true
}

resource "aws_key_pair" "ssh_access_b" {
  public_key = var.ssh_public_key
}

resource "aws_security_group" "client_sg_b" {
  name   = "${random_id.id.dec}-client-sg-b"
  vpc_id = module.vpc_b.vpc_id

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

resource "aws_instance" "client_b" {
  depends_on  = [
    aws_key_pair.ssh_access_b,
    aws_security_group.client_sg_b
  ]
  ami                    = var.ec2_ami
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.ssh_access_b.key_name
  subnet_id              = module.vpc_b.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.client_sg_b.id]

  tags = {
    Name = "${random_id.id.dec}-client-b"
  }
}

resource "aws_security_group" "server_sg_b" {
  name   = "${random_id.id.dec}-server-sg-b"
  vpc_id = module.vpc_b.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = module.vpc_b.public_subnets_cidr_blocks
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

resource "aws_instance" "server_b" {
  depends_on  = [
    aws_key_pair.ssh_access_b,
    aws_security_group.server_sg_b
  ]
  ami                    = var.ec2_ami
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.ssh_access_b.key_name
  subnet_id              = module.vpc_b.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.server_sg_b.id]
  user_data              = file("./files/server_b_user_data.sh")

  tags = {
    Name = "${random_id.id.dec}-server-b"
  }
}
