terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

#Create a VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "weather-app-vpc"
  }
}

# Create public subnet
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "weather-app-public-1"
  }
}

# Create public subnet
resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "weather-app-public-2"
  }
}


resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "weather-app-private-1"
  }
}

# Create private subnet 2
resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "weather-app-private-2"
  }
}


#nat gateway for private subnets outbount traffic
# Create NAT Gateway EIP
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "weather-app-nat-eip"
  }
}

 #Create NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id  # Place NAT Gateway in first public subnet

  tags = {
    Name = "weather-app-nat"
  }
}

#Create private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "weather-app-private-rt"
  }
}



# Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "weather-app-igw"
  }
}


# Create Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "weather-app-public-rt"
  }
}


# Associate public subnet with route table
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

# Associate public subnet with route table
resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

 #Associate private subnets with private route table
resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}

# Call ECS module
#ecs module call references vpc from main, security group from alb, and the three
  #ecr repos from from ecr
module "ecs" {
  source = "./ecs"

  vpc_id                         = aws_vpc.main.id
  private_subnet_ids             = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  target_group_arn                 = aws_lb_target_group.api_gateway.arn
  alb_security_group_id         = aws_security_group.alb.id
  api_gateway_repository_url    = aws_ecr_repository.api_gateway.repository_url
  weather_fetcher_repository_url = aws_ecr_repository.weather_fetcher.repository_url
  weather_processor_repository_url = aws_ecr_repository.weather_processor.repository_url
}