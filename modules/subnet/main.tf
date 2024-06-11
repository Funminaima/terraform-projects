resource "aws_subnet" "myapp-subnet-1"{
    vpc_id = var.vpc_id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags={
        Name:"${var.env_prefix}-subnet-1"
    }
}

resource "aws_internet_gateway" "myapp-igw"{
    vpc_id = var.vpc_id
    tags={
        Name:"${var.env_prefix}-igw"
    }
}

resource "aws_route_table" "myapp-route-table"{
    vpc_id = var.vpc_id

    route{
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags={
        Name:"${var.env_prefix}-route-table"
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