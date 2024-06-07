provider "aws" {}

variable vpc_cidr_block{}
variable subnet_cidr_block{}
variable avail_zone{}
variable env_prefix{}
variable myip{}
variable ec2_instance_type{}
variable public_key{}

resource "aws_vpc" "myapp-vpc"{
    cidr_block = var.vpc_cidr_block
    tags={
        Name:"${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "myapp-subnet-1"{
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags={
        Name:"${var.env_prefix}-subnet-1"
    }
}

resource "aws_route_table" "myapp-route-table"{
    vpc_id = aws_vpc.myapp-vpc.id

    route{
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags={
        Name:"${var.env_prefix}-route-table"
    }
}

resource "aws_internet_gateway" "myapp-igw"{
    vpc_id = aws_vpc.myapp-vpc.id
    tags={
        Name:"${var.env_prefix}-igw"
    }
}

resource "aws_route_table_association" "my-rt-subnet"{
    subnet_id = aws_subnet.myapp-subnet-1.id
    route_table_id = aws_route_table.myapp-route-table.id
}

#rather than create a new route table for the vpc, 
#i can also use the main route table or the deafult, this way, i dont need to associate 
#any subnet with it, because the subnets are already associated to main

# resource "aws_default_route_table" "main-rtb" {
#   default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.myapp-igw.id
#   }

#   tags = {
#     Name = "${var.env_prefix}-main-rtb"
#   }
# }

resource "aws_security_group" "app-sg"{
    name="app-sg"
    description = "Allow all inbound and outbound rules"
    vpc_id = aws_vpc.myapp-vpc.id

    ingress {
        from_port =22
        to_port=22
        cidr_blocks= [var.myip]
        protocol = "tcp"
    }

     ingress {
        from_port =8080
        to_port=8080
        cidr_blocks= ["0.0.0.0/0"]
        protocol = "tcp"
    }

    egress {

        from_port =0
        to_port=0
        cidr_blocks= ["0.0.0.0/0"]
        protocol = "-1"
        prefix_list_ids=[]
    }

    tags={
        Name:"${var.env_prefix}-sg"
    }
}

data "aws_ami" "ami-image"{
    most_recent = true

    filter{
        name   = "virtualization-type"
        values = ["hvm"]
    }
    filter{
        name   = "name"
        values = ["al2023-ami-2023.4.20240528.0-kernel-6.1-x86_64"]
    }
    owners = ["amazon"]

}

#output helps validate the result of what you got from query
output "aws_ami" {
  value= data.aws_ami.ami-image.id
}
output "aws_instance_public_ip"{
    value=aws_instance.myapp-ec2.public_ip 
}

#create key pair for ec2
resource "aws_key_pair" "terraform-key-pair"{
    key_name = "terraform_key_pair"
    public_key = var.public_key
}

resource "aws_instance" "myapp-ec2"{
    #rather than hard code the ami, we get it from by querying the aws_ami
    ami=data.aws_ami.ami-image.id
    instance_type = var.ec2_instance_type

    subnet_id = aws_subnet.myapp-subnet-1.id
    vpc_security_group_ids = [aws_security_group.app-sg.id]
    availability_zone = var.avail_zone

    associate_public_ip_address = true 
    key_name = aws_key_pair.terraform-key-pair.key_name

  user_data = file("entry-script.sh")

    tags={
         Name:"${var.env_prefix}-terraformEc2"
    }
}


