locals {
  name = "handson"
}

#####
# VPC
#####
resource aws_vpc handson {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = local.name
  }
}

########
# Subnet
########
resource aws_subnet public {
  vpc_id     = aws_vpc.handson.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name}-public"
  }
}

resource aws_subnet private {
  vpc_id     = aws_vpc.handson.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "${local.name}-private"
  }
}

################
# Security Group
################

# public
resource aws_security_group handson {
  vpc_id      = aws_vpc.handson.id
  name        = local.name
}

resource "aws_security_group_rule" "out" {
  type              = "egress"
  from_port         = -1
  to_port           = -1
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.handson.id
}

resource "aws_security_group_rule" "in_icmp" {
  type = "ingress"
  from_port = -1
  to_port = -1
  cidr_blocks = ["0.0.0.0/0"]
  protocol = "icmp"
  security_group_id = aws_security_group.handson.id
}

##################
# Internet Gateway
##################
resource aws_internet_gateway handson {
  vpc_id = aws_vpc.handson.id
}

#############
# NAT Gateway
#############
resource aws_eip nat {}

resource aws_nat_gateway handson {
  subnet_id = aws_subnet.public.id
  allocation_id = aws_eip.nat.id
}

#############
# Route Table
#############

# public
resource aws_route_table handson_public {
  vpc_id = aws_vpc.handson.id
  tags = {
    Name = local.name
  }
}

resource aws_route igw {
  route_table_id = aws_route_table.handson_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.handson.id
}

resource aws_route_table_association handson_public {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.handson_public.id
}

# private
resource aws_route_table handson_private {
  vpc_id = aws_vpc.handson.id
  tags = {
    Name = local.name
  }
}

resource aws_route nat {
  route_table_id = aws_route_table.handson_private.id
  nat_gateway_id = aws_nat_gateway.handson.id
  destination_cidr_block = "0.0.0.0/0"
}

resource aws_route_table_association handson_private {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.handson_private.id
}

##############
# EC2 Instance
##############
data aws_ssm_parameter amzn2_ami {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource aws_instance handson {
  ami = data.aws_ssm_parameter.amzn2_ami.value
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.handson.id
  vpc_security_group_ids = [aws_security_group.handson.id]

  subnet_id = aws_subnet.public.id

  tags = {
    Name = local.name
  }
}

resource aws_instance private {
  ami = data.aws_ssm_parameter.amzn2_ami.value
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.handson.id
  vpc_security_group_ids = [aws_security_group.handson.id]

  subnet_id = aws_subnet.private.id

  tags = {
    Name = "${local.name}-private"
  }
}


######################
# IAM Instance Profile
######################
resource aws_iam_instance_profile handson {
  name = "Handson"
  role = aws_iam_role.handson.name
}

resource aws_iam_role handson {
  name = "Handson"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource aws_iam_role_policy_attachment ssm {
  role = aws_iam_role.handson.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
