#output helps validate the result of what you got from query
output "aws_instance_public_ip"{
    value=module.webserver_instance.instance.public_id
}
