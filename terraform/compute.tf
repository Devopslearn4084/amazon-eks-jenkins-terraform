# Define AMI's data
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = [
      "amzn2-ami-hvm-*-x86_64-gp2",
    ]
  }
  filter {
    name = "owner-alias"
    values = [
      "amazon",
    ]
  }
}

# Define Resorces to create ec2 instance
resource "aws_instance" "jenkins-instance" {
  ami             = "${data.aws_ami.amazon-linux-2.id}" # here we're calling AMI's data that we defined on top 
  instance_type   = "t2.medium" # select the instance type that number of cpu and memrory required
  key_name        = "${var.keyname}" # passing a keyname that we defined in terraform.tfvars
  #vpc_id          = "${aws_vpc.development-vpc.id}"
  vpc_security_group_ids = ["${aws_security_group.sg_allow_ssh_jenkins.id}"] #Passing "aws_security_group" "sg_allow_ssh_jenkins" where we defiend below 
  subnet_id          = "${aws_subnet.public-subnet-1.id}"  #Callimg it from network.tf / "aws_subnet" "public-subnet-1"
  #name            = "${var.name}"
  user_data = "${file("install_jenkins.sh")}" # It will configure jenkins in jenkis-instance 

  associate_public_ip_address = true
  tags = {
    Name = "Jenkins-Instance"
  }
}

resource "aws_security_group" "sg_allow_ssh_jenkins" {
  name        = "allow_ssh_jenkins"
  description = "Allow SSH and Jenkins inbound traffic"
  vpc_id      = "${aws_vpc.development-vpc.id}" #defined in network.tf, terraform.tfvars, and varibles.tf

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

output "jenkins_ip_address" {
  value = "${aws_instance.jenkins-instance.public_dns}"
}
