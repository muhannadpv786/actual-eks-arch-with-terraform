# Launch an EC2 t2.micro instance using the latest Ubuntu 22.04 (Jammy Jellyfish)
# and tag it as "Bastion-Server"

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "bastion-host" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.bastion_instance_type
  key_name               = aws_key_pair.tf-key-pair.key_name
  subnet_id              = aws_subnet.public-subnet-1.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "Bastion-Server"
  }

  # Upload the script
  provisioner "file" {
    source      = "./myscript.sh"
    destination = "/tmp/myscript.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.rsa.private_key_pem
      host        = self.public_ip
    }
  }

  # Run the uploaded script
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/myscript.sh",
      "bash /tmp/myscript.sh"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.rsa.private_key_pem
      host        = self.public_ip
    }
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.eks-vpc.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

