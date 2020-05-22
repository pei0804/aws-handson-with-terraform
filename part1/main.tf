locals {
  name = "handson"
}

######
# VPC
######
resource aws_vpc handson {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = local.name
  }
}

#########
# Subnet
#########
resource aws_subnet handson {
  vpc_id     = aws_vpc.handson.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = local.name
  }
}

data aws_ssm_parameter amzn_ami {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

######
# EC2
######
resource aws_instance handson {
  ami           = data.aws_ssm_parameter.amzn_ami.value
  instance_type = "t2.micro"

  tags = {
    Name = local.name
  }
}
