locals {
  name = "handson"
}

#####
# VPC
#####
resource aws_vpc handson {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

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

##################
# Internet Gateway
##################
resource aws_internet_gateway handson {
  vpc_id = aws_vpc.handson.id
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
