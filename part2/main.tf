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
  map_public_ip_on_launch = true

  tags = {
    Name = local.name
  }
}

################
# Security Group
################

resource aws_security_group handson {
  vpc_id      = aws_vpc.handson.id
  name        = local.name
}

resource aws_security_group_rule out {
  security_group_id = aws_security_group.handson.id
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
  protocol = "-1"
  from_port = -1
  to_port = -1
}

resource aws_security_group_rule icmp {
  security_group_id = aws_security_group.handson.id
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
  protocol  = "icmp"
  from_port = -1
  to_port   = -1
}

##################
# Internet Gateway
##################
resource aws_internet_gateway handson {
  vpc_id = aws_vpc.handson.id
}

#############
# Route Table
#############
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
  security_groups = [aws_security_group.handson.id]

  subnet_id = aws_subnet.public.id

  tags = {
    Name = local.name
  }

  depends_on = [aws_internet_gateway.handson]
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
