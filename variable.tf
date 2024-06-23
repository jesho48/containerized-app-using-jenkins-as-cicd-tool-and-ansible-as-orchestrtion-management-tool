##### Var
variable "region" {
  default = "ca-central-1"
}
variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "JOHN_VPC_T2"
}
variable "JOHN_Pub_SN1_cidr" {
  default     = "10.0.0.0/24"
  description = "JOHN_Pub_SN1"
}
variable "JOHN_Pub_SN2_cidr" {
  default     = "10.0.1.0/24"
  description = "JOHN_Pub_SN1"
}
variable "JOHN_Pri_SN1_cidr" {
  default     = "10.0.2.0/24"
  description = "JOHN_Pri_SN1"
}
variable "JOHN_Pri_SN2_cidr" {
  default     = "10.0.3.0/24"
  description = "JOHN_Pri_SN2"
}
variable "az2a" {
  default = "ca-central-1a"
}
variable "az2b" {
  default = "ca-central-1b"
}
variable "proxy_port" {
  default = 8080
}
variable "ssh_port" {
  default = 22
}
variable "http_port" {
  default = 80
}
variable "mysql" {
  default = 3306
}
variable "all" {
  default = "0.0.0.0/0"
}
variable "public_cidr_blocks" {
  description = "The IP blocks for the public subnet"
  type        = string
  default     = "10.0.0.0/24"
}
variable "instance_type" {
  default = "t2.micro"
}
variable "ami" {
  default = "ami-0e7e134863fac4946"
}


variable "db_password" {
  default = "admin123"
}

variable "ami-name" {
  default = "docker_host_AMI"
}
variable "target-instance" {
  default = "docker_host"
}
variable "launch-configname" {
  default = "docker_host_ASG_LC"
}
variable "instance-type" {
  default = "t2.micro"
}
variable "sg1" {
  default = ""
}
variable "key-id" {
    default = ""  
}
variable "asg-group-name" {
    default = "Dockerhost_ASG"  
}
variable "vpc-zone-identifier" {
    default = ""  
}
variable "docker-target-group-arn" {
    default = ""  
}
variable "asg-docker-policy" {
    default = "Docker_host_ASG_POLICY"  
}

# Jenkins ELB related variables 
variable "elb_name" {
  default = "jenkins-lb"
}
variable "elb_tag" {
  default = ""
}
variable "subnet-id" {
  default = ""
}
variable "jenkins-sg1" {
  default = "JENKINS_SG_EUT2"
}
variable "jenkins-instance" {
  default = "Jenkins_Server"
}

#Docker Load Balancer Variables
variable "tg_name" {
  default = "docker-tg"
}
variable "vpc-id" {
  default = ""
}
variable "docker_instance" {
  default = ""
}
variable "alb_name" {
  default = "docker-alb"
}
variable "docker_sg1" {
  default = "Dockerhost_SG_EUT2"
}
variable "subnet_id_docker" {
  default = "PCDEU_T2_Pri_SN1"
}
variable "docker_tag" {
  default = ""
}