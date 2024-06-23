# VPC
resource "aws_vpc" "JOHN_VPC" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "JOHN_VPC" }
}

# PUBLIC SUBNETS
resource "aws_subnet" "JOHN_Pub_SN1" {
  vpc_id            = aws_vpc.JOHN_VPC.id
  cidr_block        = var.JOHN_Pub_SN1_cidr
  availability_zone = var.az2a
  tags = {
    Name = "JOHN_Pub_SN1"
  }
}
resource "aws_subnet" "JOHN_Pub_SN2" {
  vpc_id            = aws_vpc.JOHN_VPC.id
  cidr_block        = var.JOHN_Pub_SN2_cidr
  availability_zone = var.az2b
  tags = {
    Name = "JOHN_Pub_SN2"
  }
}
# PRIVATE SUBNETS
resource "aws_subnet" "JOHN_Pri_SN1" {
  vpc_id            = aws_vpc.JOHN_VPC.id
  cidr_block        = var.JOHN_Pri_SN1_cidr
  availability_zone = var.az2a
  tags = {
    Name = "JOHN_Pri_SN1"
  }
}
resource "aws_subnet" "JOHN_Pri_SN2" {
  vpc_id            = aws_vpc.JOHN_VPC.id
  cidr_block        = var.JOHN_Pri_SN2_cidr
  availability_zone = var.az2b
  tags = {
    Name = "JOHN_Pri_SN2"
  }
}

# INTERNET GATEWAY
resource "aws_internet_gateway" "JOHN-IGW" {
  vpc_id = aws_vpc.JOHN_VPC.id
  tags = {
    Name = "JOHN_T2_IGW"
  }
}

# NAT GATEWAY
resource "aws_nat_gateway" "JOHN-NAT-GW" {
  allocation_id = aws_eip.JOHN-EIP.id
  subnet_id     = aws_subnet.JOHN_Pub_SN1.id
  depends_on    = [aws_internet_gateway.JOHN-IGW]
  tags = {
    Name = "JOHN-NAT-GW"
  }
}

# ELASTIC IP ADDRESS
resource "aws_eip" "JOHN-EIP" {
  vpc = true
  tags = {
    Name = "JOHN-EIP"
  }
}

# PUBLIC ROUTE TABLE AND ROUTE TABLE ASSOCIATIONS WITH PUBLIC SUBNETS
resource "aws_route_table" "JOHN-Pub-RouteTable" {
  vpc_id = aws_vpc.JOHN_VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.JOHN-IGW.id
  }
  tags = {
    Name = "JOHN-Pub-RouteTable"
  }
}
resource "aws_route_table_association" "Pub-1" {
  subnet_id      = aws_subnet.JOHN_Pub_SN1.id
  route_table_id = aws_route_table.JOHN-Pub-RouteTable.id
}
resource "aws_route_table_association" "Pub-2" {
  subnet_id      = aws_subnet.JOHN_Pub_SN2.id
  route_table_id = aws_route_table.JOHN-Pub-RouteTable.id
}

# PRIVATE ROUTE TABLE AND ROUTE TABLE ASSOCIATIONS WITH PRIVATE SUBNETS
resource "aws_route_table" "JOHN-Pri-RouteTable" {
  vpc_id = aws_vpc.JOHN_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.JOHN-NAT-GW.id
  }
  tags = {
    Name = "JOHN-Pri-RouteTable"
  }
}
resource "aws_route_table_association" "Pri-1" {
  subnet_id      = aws_subnet.JOHN_Pri_SN1.id
  route_table_id = aws_route_table.JOHN-Pri-RouteTable.id
}
resource "aws_route_table_association" "Pri-2" {
  subnet_id      = aws_subnet.JOHN_Pri_SN2.id
  route_table_id = aws_route_table.JOHN-Pri-RouteTable.id
}

# SECURITY GROUP FOR JENKINS SERVER
resource "aws_security_group" "JENKINS_SG_EUT2" {
  name        = "JENKINS_SG_EUT2"
  description = "Allow 8080, ssh traffic"
  vpc_id      = aws_vpc.JOHN_VPC.id

  ingress {
    description = "Allow Port access"
    from_port   = var.proxy_port
    to_port     = var.proxy_port
    protocol    = "tcp"
    cidr_blocks = [var.all]
  }
  ingress {
    description = "Allow http access"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = [var.all]
  }
  ingress {
    description = "Allow access"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.all]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all]
  }
  tags = {
    Name = "JENKINS_SG_EUT2"
  }
}

# SECURITY GROUP FOR DOCKER HOST
resource "aws_security_group" "Dockerhost_SG_EUT2" {
  name        = "dockerhost_SG_EUT2"
  description = "Allow http, ssh traffic"
  vpc_id      = aws_vpc.JOHN_VPC.id

  ingress {
    description = "Allow http access"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = [var.all]
  }
  ingress {
    description = "Allow port access"
    from_port   = var.proxy_port
    to_port     = var.proxy_port
    protocol    = "tcp"
    cidr_blocks = [var.all]
  }
  ingress {
    description = "Allow ssh access"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.all]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all]
  }
  tags = {
    Name = "dockerhost_SG_EUT2"
  }
}

# SECURITY GROUP FOR ANSIBLE CONTROL NODE
resource "aws_security_group" "ANSIBLE_SG_EUT2" {
  name        = "ANSIBLE_SG_EUT2"
  description = "Allow ssh traffic"
  vpc_id      = aws_vpc.JOHN_VPC.id

  ingress {
    description = "Allow ssh access"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.all]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all]
  }
  tags = {
    Name = "ANSIBLE_SG_EUT2"
  }
}

# Creating security group for Bastion Server
resource "aws_security_group" "BASTION_HOST_SG_EUT2" {
  name        = "BASTION_SG_EUT2"
  description = "Allow ssh traffic"
  vpc_id      = aws_vpc.JOHN_VPC.id

  ingress {
    description = "Allow ssh access"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.all]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all]
  }
  tags = {
    Name = "Bastion_SG_EUT2"
  }
}
# RDS Security Group
resource "aws_security_group" "RDS_SG_EUT2" {
  name        = "RDS_SG_EUT2"
  description = "Allow mysql traffic"
  vpc_id      = aws_vpc.JOHN_VPC.id

  ingress {
    description = "Allow mysql access"
    from_port   = var.mysql
    to_port     = var.mysql
    protocol    = "tcp"
    cidr_blocks = [var.public_cidr_blocks]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all]
  }
  tags = {
    Name = "RDS_SG_EUT2"
  }
}
# Create an iam policy document to allow Ansible host access some actions on our
# aws account to discover instances created by autoscaling group without escalating privileges
data "aws_iam_policy_document" "ansible-host" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:Describe*",
      "autoscaling:Describe*",
      "ec2:DescribeTags*"
    ]
    resources = ["*"]
  }
}
resource "aws_iam_policy" "ansible_host" {
  name        = "ansible-cli-policy"
  path        = "/"
  description = "Access policy for Ansible_node to connect to aws account"
  policy      = data.aws_iam_policy_document.ansible-host.json
}

# Create iam policy document to allow Ansible host assume role
data "aws_iam_policy_document" "ansible_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "ansible_role" {
  name               = "ansible-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ansible_policy_document.json
}

# Here we attach the iam policy to the iam role created
resource "aws_iam_role_policy_attachment" "ansible_policy_attachment" {
  role       = aws_iam_role.ansible_role.name
  policy_arn = aws_iam_policy.ansible_host.arn
}

# Then we create an iam instance profile to attach to our Ansible host
resource "aws_iam_instance_profile" "ansible_aws_instance_profile" {
  name = "ansible_aws_instance_profile"
  role = aws_iam_role.ansible_role.name
}

# create KeyPair
# resource "aws_key_pair" "TEAM-key" {
# key_name = "TEAM-key" 
# public_key = file(var.TEAM-key)
# }



# Provisioning Bastion Host
resource "aws_instance" "Bastion_Host" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.JOHN_Pub_SN1.id
  vpc_security_group_ids      = [aws_security_group.BASTION_HOST_SG_EUT2.id]
  associate_public_ip_address = true

  provisioner "file" {
    source      = "~/Documents/keypairs/esho.pem"
    destination = "/home/ec2-user/esho"
  }


  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/Documents/keypairs/esho.pem")
    host        = self.public_ip
  }
  user_data = <<-EOF
#!/bin/bash
sudo hostnamectl set-hostname Bastion
EOF
  tags = {
    Name = "Bastion_Host"
  }
 }
 

# Provision Ansible Host
resource "aws_instance" "ansible_host" {
  ami                    = var.ami
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.ansible_aws_instance_profile.id
  subnet_id              = aws_subnet.JOHN_Pri_SN1.id
  vpc_security_group_ids = [aws_security_group.ANSIBLE_SG_EUT2.id]
  user_data              = <<-EOF
#!/bin/bash
sudo yum update -y
sudo yum install python3 python3-pip -y
sudo alternatives --set python /usr/bin/python3
sudo pip3 install docker-py
sudo yum install ansible -y
sudo yum install -y yum-utils -y
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce -y
sudo systemctl start docker
sudo systemctl enable docker
cd /etc/ansible
sudo yum install unzip -y
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo ./aws/install
./aws/install -i /usr/local/aws-cli -b /usr/local/bin
sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
sudo ln -svf /usr/local/bin/aws /usr/bin/aws
sudo yum install vim -y 
touch MyPlaybook.yaml discovery.sh key.pem
sudo chmod 755 discovery.sh /etc/ansible
sudo chown -R ec2-user:ec2-user /etc/ansible
echo "license_key: eu01xx4fc443b5ef136bb617380505f93e08NRAL" | sudo tee -a /etc/newrelic-infra.yml
sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/amazonlinux/2/x86_64/newrelic-infra.repo
sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
sudo yum install newrelic-infra -y
sudo hostnamectl set-hostname Ansible
EOF
  tags = {
    Name = "Ansible_Node"
  }
}

# Provision Jenkins Server
resource "aws_instance" "Jenkins_Server" {
  ami                    = var.ami
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.JOHN_Pri_SN1.id
  vpc_security_group_ids = [aws_security_group.JENKINS_SG_EUT2.id]
  user_data              = <<-EOF
#!/bin/bash
sudo yum update -y
sudo yum install wget -y
sudo yum install git -y
sudo yum install maven -y
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum upgrade -y
sudo yum install jenkins java-11-openjdk-devel -y --nobest
sudo yum install epel-release java-11-openjdk-devel
sudo systemctl daemon-reload
sudo systemctl start jenkins
sudo systemctl enable jenkins
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum update -y
sudo yum install docker-ce docker-ce-cli containerd.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
sudo usermod -aG docker jenkins
echo "license_key: eu01xx4fc443b5ef136bb617380505f93e08NRAL" | sudo tee -a /etc/newrelic-infra.yml
sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/el/7/x86_64/newrelic-infra.repo
sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
sudo yum install newrelic-infra -y
sudo hostnamectl set-hostname Jenkins
EOF 
  tags = {
    Name = "Jenkins_Server"
  }
}

# Provision Docker Host
resource "aws_instance" "docker_host" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.JOHN_Pri_SN1.id
  vpc_security_group_ids = [aws_security_group.Dockerhost_SG_EUT2.id]
  user_data              = <<-EOF
#!/bin/bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum update -y
sudo yum install docker-ce docker-ce-cli containerd.io -y
sudo yum install python3 python3-pip -y
sudo alternatives --set python /usr/bin/python3
sudo pip3 install docker-py 
sudo systemctl start docker
sudo systemctl enable docker
echo "license_key: eu01xx4fc443b5ef136bb617380505f93e08NRAL" | sudo tee -a /etc/newrelic-infra.yml
sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/el/7/x86_64/newrelic-infra.repo
sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
sudo yum install newrelic-infra -y
sudo usermod -aG docker ec2-user
docker pull hello-world
sudo hostnamectl set-hostname Docker
EOF
  tags = {
    Name = "docker_host"
  }
} 


# RDS Subnet Group
# resource "aws_db_subnet_group" "db_subnet-group" {
#   name       = "db_subnet-group"
#   subnet_ids = [aws_subnet.JOHN_Pri_SN1.id, aws_subnet.PCDEU_T2_Pri_SN2.id]

#   tags = {
#     Name = "My DB subnet group"
#   }
# }


#  # Provision RDS Instance
# resource "aws_db_instance" "pcdeu_database" {
#   allocated_storage      = 10
#   db_subnet_group_name   = aws_db_subnet_group.db_subnet-group.id
#   vpc_security_group_ids = [aws_security_group.RDS_SG_EUT2.id]
#   engine                 = "mysql"
#   engine_version         = "5.7"
#   instance_class         = "db.t3.micro"
#   db_name                = "admin"
#   username               = var.db_username
#   password               = var.db_password
#   parameter_group_name   = "default.mysql5.7"
#   skip_final_snapshot    = true
# }


##############
resource "aws_ami_from_instance" "docker_host_AMI" {
  name               = var.ami-name
  source_instance_id = aws_instance.docker_host.id
  depends_on = [aws_instance.docker_host]
} 
###Creating autoscaling
resource "aws_launch_configuration" "docker_host_ASG_LC" {
  name = var.launch-configname
  instance_type = var.instance-type
  image_id = aws_ami_from_instance.docker_host_AMI.id
  security_groups = [aws_security_group.Dockerhost_SG_EUT2.id]
  user_data = <<-EOF
#!/bin/bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum update -y
sudo yum install docker-ce docker-ce-cli containerd.io -y
sudo yum install python3 python3-pip -y
sudo alternatives --set python /usr/bin/python3
sudo pip3 install docker-py 
sudo systemctl start docker
sudo systemctl enable docker
echo "license_key: eu01xx4fc443b5ef136bb617380505f93e08NRAL" | sudo tee -a /etc/newrelic-infra.yml
sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/el/7/x86_64/newrelic-infra.repo
sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
sudo yum install newrelic-infra -y
sudo usermod -aG docker ec2-user
docker pull hello-world
sudo hostnamectl set-hostname Docker
EOF
}
resource "aws_autoscaling_group"  "Dockerhost_ASG" {
  name = var.asg-group-name 
  max_size = 4
  min_size = 2
  health_check_grace_period = 300
  health_check_type = "EC2"
  force_delete = true
  launch_configuration = aws_launch_configuration.docker_host_ASG_LC.name
  vpc_zone_identifier = [aws_subnet.JOHN_Pri_SN1.id, aws_subnet.JOHN_Pri_SN2.id]
  target_group_arns = [aws_lb_target_group.docker-tg.arn]
}
resource "aws_autoscaling_policy" "Docker_host_ASG_POLICY" {
  name = var.asg-docker-policy
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 60
  autoscaling_group_name = aws_autoscaling_group.Dockerhost_ASG.name
}

# Create a jenkins load balancer
resource "aws_elb" "jenkins_lb" {
  name            = var.elb_name
  subnets         = [aws_subnet.JOHN_Pub_SN1.id]
  security_groups = [aws_security_group.JENKINS_SG_EUT2.id]

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:8080"
    interval            = 30
  }

  instances                   = [aws_instance.Jenkins_Server.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = var.elb_tag
  }
}


#Create Docker Load Balancer

# Create a Target Group for Load Balancer
resource "aws_lb_target_group" "docker-tg" {
  name     = var.tg_name
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.JOHN_VPC.id
  health_check {
    healthy_threshold   = 5
    interval            = 30
    timeout             = 5
    unhealthy_threshold = 3
  }
}
resource "aws_lb_target_group_attachment" "JOHN-tg-att" {
  target_group_arn = aws_lb_target_group.docker-tg.arn
  target_id        = aws_instance.docker_host.id
  port             = 80
}
#Add an Application Load Balancer
resource "aws_lb" "docker-alb" {
  name                       = var.alb_name
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.Dockerhost_SG_EUT2.id]
  subnets                    = [aws_subnet.JOHN_Pub_SN1.id, aws_subnet.JOHN_Pub_SN2.id ]
  enable_deletion_protection = false
  tags = {
    name = var.docker_tag
  }
}
#Add a load balancer Listener
resource "aws_lb_listener" "JOHN-lb-listener" {
  load_balancer_arn = aws_lb.docker-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.docker-tg.arn
  }
}



# # Create Domain name using Route 53
 resource "aws_route53_zone" "JOHN" {
   name          = "akinolaesho.fun"
  force_destroy = true
}

#Create Route 53 A Record and Alias
resource "aws_route53_record" "PCDEU_record" {
  zone_id = aws_route53_zone.JOHN.zone_id
  name    = "akinolaesho.fun"
  type    = "A"

  alias {
    name                   = aws_lb.docker-alb.dns_name
    zone_id                = aws_lb.docker-alb.zone_id
    evaluate_target_health = true
  }
}




