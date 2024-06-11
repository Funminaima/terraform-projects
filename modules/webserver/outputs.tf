output "instance"{
    value=aws_instance.myapp-ec2
}
output "ami-image"{
    value=data.aws_ami.ami-image
}