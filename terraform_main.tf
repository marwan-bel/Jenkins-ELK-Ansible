#
# terraform to provision resources
#

#Setting up the Provider
provider "aws" {
  region = "us-east-1"

}

#Setting up the key pair 
variable "aws_key_pair" {

  default = "/home/marwan/default_ec2.pem"

}

#Getting Default VPC id
data "aws_subnet_ids" "default_subnets" {
  vpc_id = aws_default_vpc.default.id

}
#Getting Ubuntu lastest image id
data "aws_ami" "linux_lastest" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }


}
resource "aws_default_vpc" "default" {

}
#Creating and Setting AWS_Security_Groups
resource "aws_security_group" "my_sg" {
  name   = "http_sg"
  vpc_id = aws_default_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = -1
    to_port     = 0
  }






}
#Creating AWS_Instance_
resource "aws_instance" "server1" {
  count                  = 1
  ami                    = data.aws_ami.linux_lastest.id
  key_name               = "default_ec2"
  instance_type          = "t2.medium"
  subnet_id              = tolist(data.aws_subnet_ids.default_subnets.ids)[0]
  vpc_security_group_ids = [aws_security_group.my_sg.id]

  tags = {
    Owner           = var.owner
    Name            = "Jenkins-${count.index}"
    ansibleFilter   = var.ansibleFilter
    ansibleNodeType = "Jenkins01"
    ansibleNodeName = "Jenkins${count.index}"
  }
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.aws_key_pair)
  }
  provisioner "local-exec" {

 
    command = "echo server1_public_ip: ${aws_instance.server1[0].public_ip} >> /home/marwan/wevioo_pfe/servers_public_ip.txt"
    #command = "eval `ssh-agent -s`"
    #command = "ssh-add /home/marwan/default_ec2.pem"
    #exec "echo server1_public_ip: "${aws_instance.server1[0].public_ip}" >> /home/marwan/wevioo/ansible/group_vars/all/vars.yml"

  }

}
