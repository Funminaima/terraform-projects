resource "aws_security_group" "app-sg"{
    name="app-sg"
    description = "Allow all inbound and outbound rules"
    vpc_id = var.vpc_id

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

#outbound
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

#create key pair for ec2
resource "aws_key_pair" "terraform-key-pair"{
    key_name = "terraform_key_pair"
    public_key = file(var.public_key)
}

resource "aws_instance" "myapp-ec2"{
    #rather than hard code the ami, we get it from by querying the aws_ami
    ami=data.aws_ami.ami-image.id
    instance_type = var.ec2_instance_type

    subnet_id = var.subnet_id
    vpc_security_group_ids = [aws_security_group.app-sg.id]
    availability_zone = var.avail_zone

    associate_public_ip_address = true 
    key_name = aws_key_pair.terraform-key-pair.key_name

  user_data = file("entry-script.sh")

    tags={
         Name:"${var.env_prefix}-terraformEc2"
    }
}