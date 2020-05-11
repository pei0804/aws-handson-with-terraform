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

  tags = {
    Name = local.name
  }
}

#####
# AMI
#####
data aws_ami handson {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

##############
# EC2 Instance
##############
resource aws_instance handson {
  ami           = data.aws_ami.handson.id
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.handson.id

  subnet_id = aws_subnet.public.id

  tags = {
    Name = local.name
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
