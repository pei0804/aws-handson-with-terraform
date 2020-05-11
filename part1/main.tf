locals {
  name = "handson"
}

resource aws_vpc handson {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = local.name
  }
}

resource aws_subnet public {
  vpc_id     = aws_vpc.handson.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = local.name
  }
}

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

resource aws_instance handson {
  ami           = data.aws_ami.handson.id
  instance_type = "t2.micro"

  subnet_id = aws_subnet.public.id

  tags = {
    Name = local.name
  }
}
