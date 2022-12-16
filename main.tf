data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}

resource "aws_vpc" "prod-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = "true" #gives you an internal domain name
    enable_dns_hostnames = "true" #gives you an internal host name
    enable_classiclink = "false"
    instance_tenancy = "default"    
    
    tags = {
        Name = "prod-vpc"
    }
}

resource "aws_subnet" "prod-subnet" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_instance" "blog" {
  ami                    = data.aws_ami.app_ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [module.blog_sg.security_group_id]
  subnet_id 		 = aws_subnet.prod-subnet.id  
  
  tags = {
    Name = "blog-tf"
  }

}

module "blog_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.16.2"
 
  vpc_id = aws_vpc.prod-vpc.id
  name	 = "blog"

  ingress_rules 	= ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks 	= ["0.0.0.0/0"]

  egress_rules 		= ["all-all"]
  egress_cidr_blocks 	= ["0.0.0.0/0"]
  
}

