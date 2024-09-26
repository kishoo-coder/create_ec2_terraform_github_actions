# Define the provider
provider "aws" {
  region = "eu-north-1"  # Change this to your desired region
}

# Create a new VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my_vpc"
  }
}

# Create a new subnet within the VPC
resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "my_subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "my_gw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create a route table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_gw.id
  }
}

# Associate route table with the subnet
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

# Security Group
resource "aws_security_group" "allow_ssh" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to all (Adjust as per your need)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

# EC2 Instance
resource "aws_instance" "my_ec2" {
  ami           = "ami-046822148e7ba2bdf"   # Replace with the correct AMI ID
  instance_type = "t3.micro"

  # Attach the EC2 instance to the subnet
  subnet_id                   = aws_subnet.my_subnet.id
  associate_public_ip_address = true

  key_name = "my-ec2-key-pair"  # Make sure you have your SSH key pair

  # Specify the security group
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "my_ec2_2"
  }
}
