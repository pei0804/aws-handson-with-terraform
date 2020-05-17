locals {
  name = "handson"
}

#####
# VPC
#####
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.handson.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
  map_public_ip_on_launch = true

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

##############
# EC2 Instance
##############
data aws_ssm_parameter amzn2_ami {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource aws_instance handson {
  ami = data.aws_ssm_parameter.amzn2_ami.value
  instance_type = "t2.micro"

  subnet_id = aws_subnet.public.id

  tags = {
    Name = local.name
  }
}
