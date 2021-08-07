terraform{
  required_version= ">= 1.0.0"

### uploading file to bucket
  backend "s3" {
    bucket = "mybucket-terraform-s3"
    key    = "terraform.tfstate"
    region = "eu-central-1"
  }
}


#0. using the credentials from our local machine- more secure.
provider "aws" {
    region                  = var.my_region
    shared_credentials_file = "~/.aws/credentials"
}


#1. Create a VPC, important- enabling dns host name

resource "aws_vpc" "default_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.is_enable_dns_hostname
  
  tags = {
    Name = var.vpc_name
  }
}

#2. Create Internet Gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.default_vpc.id

  tags = {
    Name = var.igw_name
  }
}

#3. Create custom route table- mention the vpc & connect it to IGW

resource "aws_route_table" "route-table-igw" {
  vpc_id = aws_vpc.default_vpc.id

  route {
    cidr_block = var.rt_igw_cidr_block
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = var.raute_table_name
  }
}

#4.Create 1 Subnets- in order to place 2 instances into them- take care diffrent cidr IP's.

resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.default_vpc.id
  cidr_block        = var.subnet_1_cidr_block
  availability_zone = var.az_subnet_1

  tags = {
    Name = var.subnet_1_name
  }
}

#5. Associate the route table with IGW (instead of two subnets).
resource "aws_main_route_table_association" "app-igw-route" {
  vpc_id         = aws_vpc.default_vpc.id
  route_table_id = aws_route_table.route-table-igw.id
}
#6. Create Security group to allow port 22,80,3000

resource "aws_security_group" "allow_web" {
  name          = "allow_web_traffic"
  description   = "Allow web traffic inbound traffic"
  vpc_id        = aws_vpc.default_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 81
    to_port     = 81
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #better to use my private ip
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #better to use my private ip
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" #means i can take outside anywhere
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.security_group_name
  }
}


#7.1 Create amazon linux srv install docker, and run the "hostname-docker" image, in subnet-1
# make sure connect subnet id, vpc and have public ip address
resource "aws_instance" "wb_server1" {
  ami                         = var.image_aws
  instance_type               = var.my_instance_type
  key_name                    = var.my_key_name
  subnet_id                   = aws_subnet.subnet-1.id
  vpc_security_group_ids      = [aws_security_group.allow_web.id]
  iam_instance_profile        = var.iam_instance_profile
  associate_public_ip_address = true
#adding docker to machine
  user_data = <<-EOF
            #!/bin/bash
            yum update
            yum install docker -y
            yum install docker.io -y
            chmod 666 /var/run/docker.sock 
            usermod -aG docker ec2-user
            EOF
  
  tags = {
    Name = var.first_instance_name
  }

  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("./260621.pem")
    host     = self.public_ip
    timeout  = "1m"
  }

  provisioner "file" {
  source      = "./docker-compose.yml"
  destination = "/home/ec2-user/docker-compose.yml"
  }

  provisioner "file" {
  source      = "./nginx.conf"
  destination = "/home/ec2-user/nginx.conf"
  }

  provisioner "file" {
  source      = "./src"
  destination = "/home/ec2-user/src"
  }

  provisioner "file" {
  source      = "./Dockerfile"
  destination = "/home/ec2-user/Dockerfile"
  }

  provisioner "file" {
  source      = "./application.properties"
  destination = "/home/ec2-user/application.properties"
  }

  provisioner "file" {
  source      = "./target"
  destination = "/home/ec2-user/target"
  }
  
  provisioner "file" {
  source      = "./260621.pem"
  destination = "/home/ec2-user/260621.pem"
  }

}

# resource "aws_key_pair" "deployer-key" {
#   key_name   = "deployer-key"
#   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJ463tU2q7xZtrTiMGOVZZ28kELljTCRFKf1belb9x9TROZnuuKK0KFnyKyXryQTRnQmLKqmYflBoY8nemWtfW1dvTk0XJWeLu5iFIlWVL6tV5RuFGWrZAOqXf5p95fXflg1KYonBrJSyQnY1HiYifwQFzW/7VGNVFitFTstM5BmaaBNOtpwfiUmo3D0U9ZbV2Rvec9e7uOviGp3ZE8nh8xmWaMTAPKo9Z8I7+PUWeVnXHXzDNT95XZJdSIRc2Q0zu1GGBi9kgx3IIOl+ijuyt79X31DXUwLZrGL2+8+Q+Rl8fPguo/XiGjRK/uvcaotPktdjpzvV+iCevwAEmPRUn jenkins@jenkins-2"
# }


resource "null_resource" "my_files_ready" {
    depends_on = [aws_instance.wb_server1]
    #wait for my_files
    connection {
        type = "ssh"
        user = "ec2-user"
        private_key = file("./260621.pem")
        host = aws_instance.wb_server1.public_ip
    }
    # run commands on remote null resource
    provisioner "remote-exec" {
      inline = [
          "sudo yum install -y docker",
          "sudo service docker start",
          "sudo $(aws ecr get-login --region eu-central-1 | sed 's/-e none//g')",
          
          "sudo docker pull 305738231455.dkr.ecr.eu-central-1.amazonaws.com/ted-search:latest",
          
          "sudo docker tag 305738231455.dkr.ecr.eu-central-1.amazonaws.com/ted-search:latest ted-search:latest",
          "sudo curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-`uname -s`-`uname -m` | sudo tee /usr/local/bin/docker-compose > /dev/null",
          "sudo chmod +x /usr/local/bin/docker-compose",
          "sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose",
          
          "sudo docker-compose up -d"
      ]
    }
}

