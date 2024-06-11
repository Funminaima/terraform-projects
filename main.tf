provider "aws" {}

resource "aws_vpc" "myapp-vpc"{
    cidr_block = var.vpc_cidr_block
    tags={
        Name:"${var.env_prefix}-vpc"
    }
}

module "my-app-subnet" {
    source= "./modules/subnet"
    vpc_id= aws_vpc.myapp-vpc.id
    subnet_cidr_block=var.subnet_cidr_block
    avail_zone=var.avail_zone
    env_prefix=var.env_prefix
}

module "webserver_instance"{
    source= "./modules/webserver"
    myip=var.myip
    vpc_id=aws_vpc.myapp-vpc.id
    public_key=var.public_key
    avail_zone=var.avail_zone
    env_prefix=var.env_prefix
    subnet_id=module.my-app-subnet.subnet.id
    ec2_instance_type=var.ec2_instance_type
}


