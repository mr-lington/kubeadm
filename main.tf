resource "aws_default_vpc" "myApp" {

  tags = {
    Name = "myApp"
  }
}


# Declare the data source 172.31.0.0/16 pcx-00123ce19df5fd5f7
data "aws_availability_zones" "myApp" {
  state = "available"
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.myApp.names[0]

  tags = {
    Name = "Default subnet for eu-west-2a"
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.myApp.names[1]

  tags = {
    Name = "Default subnet for eu-west-2b"
  }
}

resource "aws_security_group" "myApp" {
  name        = "myAppSG"
  description = "Allow access on ports 0 to 60000"
  vpc_id      = aws_default_vpc.myApp.id

  ingress {
    description = "allow traffic from ports range from 0 to 60000"
    from_port   = 0
    to_port     = 60000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# RSA key of size 4096 bits
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "pk" {
  key_name   = "myKey"
  public_key = tls_private_key.pk.public_key_openssh
}

resource "local_file" "pk" {
  content  = tls_private_key.pk.private_key_pem
  filename = "${aws_key_pair.pk.key_name}.pem"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  # filter {
  #   name   = "name"
  #   values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  # }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# resource "aws_instance" "myAppTwo" {
#   ami                         = data.aws_ami.ubuntu.id
#   instance_type               = "t2.micro"
#   subnet_id                   = aws_default_subnet.default_az1.id
#   associate_public_ip_address = true
#   vpc_security_group_ids      = [aws_security_group.myApp.id]
#   key_name                    = aws_key_pair.pk.key_name
#   user_data                   = local.app_user_data
#   user_data_replace_on_change = true

#   tags = {
#     Name = "myAppTwo"
#   }
# }


resource "aws_instance" "master" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.medium"
  subnet_id                   = aws_default_subnet.default_az1.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.myApp.id]
  key_name                    = aws_key_pair.pk.key_name
  user_data                   = local.master_user_data
  user_data_replace_on_change = true

  tags = {
    Name = "myMasterApp"
  }
}

# resource "aws_instance" "worker1" {
#   ami                         = data.aws_ami.ubuntu.id
#   instance_type               = "t2.medium"
#   subnet_id                   = aws_default_subnet.default_az1.id
#   associate_public_ip_address = true
#   vpc_security_group_ids      = [aws_security_group.myApp.id]
#   key_name                    = aws_key_pair.pk.key_name
#   user_data                   = local.worker_user_data1
#   user_data_replace_on_change = true

#   tags = {
#     Name = "myAppOne"
#   }
# }


resource "aws_instance" "worker2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.medium"
  subnet_id                   = aws_default_subnet.default_az1.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.myApp.id]
  key_name                    = aws_key_pair.pk.key_name
  user_data                   = local.worker_user_data2
  user_data_replace_on_change = true

  tags = {
    Name = "myAppTwo"
  }
}


# #create db subnet group
# resource "aws_db_subnet_group" "rds_db_subnet_group" {
#   name       = "rds-subnet-group"
#   subnet_ids = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
# }

# # Created MYSQL RDS
# resource "aws_db_instance" "multi_az_rds" {
#   allocated_storage      = 10
#   db_subnet_group_name   = aws_db_subnet_group.rds_db_subnet_group.name
#   engine                 = "mysql"
#   engine_version         = "8.0.42"
#   identifier             = "rdsdb"
#   instance_class         = "db.t3.micro"
#   multi_az               = false
#   db_name                = "mydb"
#   username               = "petclinic"
#   password               = "secret123"
#   storage_type           = "gp2"
#   vpc_security_group_ids = [aws_security_group.myApp.id]
#   publicly_accessible    = true
#   apply_immediately      = true
#   skip_final_snapshot    = true
#   parameter_group_name   = "default.mysql8.0"
# }

# docker run --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:tag
