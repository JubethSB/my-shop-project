provider "aws" {
  region = "us-east-1"
}

# --- 1. NETWORK ---
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "FoodShopVPC" }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# --- 2. SECURITY GROUPS ---
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }
}

# --- 3. DATABASE (Tier 2) ---
resource "aws_db_subnet_group" "db_group" {
  name       = "main_db_group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

resource "aws_db_instance" "food_db" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = "food_db"
  username               = "admin"
  password               = "password123"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db_group.name
}

# --- 4. WEB SERVER (Tier 1) ---
resource "aws_instance" "web_server" {
  ami           = "ami-04b4f1a9cf54c11d0" # Ubuntu 24.04 (us-east-1)
  instance_type = "t3.micro"              # <--- CHANGED TO t3.micro (FIXED)
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  
  # MAGIC SCRIPT: Installs everything automatically
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y apache2 php php-mysql git
              rm /var/www/html/index.html
              cd /var/www/html
              git clone https://github.com/JubethSB/my-shop-project.git .
              systemctl restart apache2
              EOF

  tags = { Name = "FoodWebServer" }
}

output "website_ip" { value = aws_instance.web_server.public_ip }
output "db_endpoint" { value = aws_db_instance.food_db.endpoint }