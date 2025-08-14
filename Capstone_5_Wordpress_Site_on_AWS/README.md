# WordPress Site on AWS

## Project Scenario

A small to medium-sized digital marketing agency, **"DigitalBoost"**, wants to enhance its online presence by creating a hagh-performance **WordPress-based** website for their clients. The agency needs a scalable, secure, and cost -effective solution that can handle increasing traffic and seamlessly intergrate with their existing infrastructure. Yor task as an AWS solutions Architect is to design and implement a WordPress solution using various AWS services, such as Networking, Computue, Object Storage, and Databases.

## Pre-requisite

- Knowledge of TechOps Essentials
- Comletion of Core 2 Courses and Mini Projects

The project overview with necessary architecture have been provided as you help **DigitalBoost** with the WordPress Based website. 

## Project Deliverables

- **Documentation:**
    - Detailed documentation for each component setup
    - Explanation of security measures implemented

- **Demonstation:**
    - Live demonstation of the WordPress site.
    - Showcase auto-scaling by simulating increased traffic

## Project Overview
![Project Overview](img/1.a.Project_Overview.png)



1. **VPC** with public and private subnets in 2 availability zones

2. An **Internet Gateway** is used to allow communication between instances in VPC and the internet 

3. We are using 2 **availbility zones** for high availability and fault tolerance.

4. Resources such as Nat Gateway, Bastion Host, and Application Load Balancers uses public subnet

5. We will put the webservers and database server in the Private Subnets to protect them.

6. The **Nat Gateway** allows the instances in the private App subnets and private Data subnets to access the internet.

7. We are using an **MySQL RDS** database.

8. We are using Amazon EFS so that the webservers cn have access to shared files.

9. The **EFS Mount Targets** are in each Availability Zones in the VPC

10. We are using **EC2 Instances** to host our website

11. **Application Load Balancer** is used to distribute web traffic accross an Auto Scaling Group of EC2 Instances in multiple AZs

12. Using **Auto-scalling Group** to dynamically create our EC2 instances to make our website highly available scalable, fault tolerance, and elastic

13. We are using **Route 53** to register our domain name and create a record set

## Project Components 

### 1. VPC Setup

**VPC ARCHITECTURE**
![VPC Arcitecture](img/1.b.VPC_Architecture.png)

1. **VPC** with public and private subnets in 2 availability zones.

2. An **Internet Gateway** is used to allow communication between instances in VPC and the internet.

3. We are using 2 **Availability Zones** for high availability and fault tolerance.

4. Resources such as Nat Gateway, Bastion Host, and Application Load Balancer uses **Public Subnets**.

5. We will put the webserver and database server in the **Private Subnets** to protect them.

6. The **Public Route Table** us associated with the public subnets and routes traffic to the internet through the internet gateway.

7. The **Main Route Table** is associated with the private subnets

#### Objectives and Steps
- **Objective:** Create a Virtual Private Cloud (VPC) to isolate and secure the WordPress infrastructure.

- **Steps**
    - Define IP address range for the VPC.
    - Create VPC with public and private subnets.
    - Configure route tables for each subnet.



### 2. Public and Private Subnet with NAT Gateway
**NAT GATEWAY ARCHITECTURE**

![NAT GATEWAY ARCHITECTURE](img/1.c.Nat_Gateway_Architecture.png)

1. The **Nat Gateway** allows the instances in the private App subnets and private Data subnets to access the internet.

2. The **Private Route Table** is associated with the private subnets and routes traffic to the internet through the nat gateway.

#### Objectives and Steps

- **Objective:** Implement a secure network architecture with ublic and private subnets. Use a NAT Gateway for private subnet internet access.

- **Steps:**
    - Set up public subnet for resources accessible from the internet.
    - Create private subnet for resources with no direct internet access.
    - Configure a NAT Gateway for private subnet internet access



### 3. AWS MySQL RDS Setup

**SECURITY GROUP ARCHITECTURE**

![Security Group Architecture](img/1.d.Security_Group_Architecture.png)


1. **ALB Security Group**

    **Port**= 80 and 443       |     **Source**= 0.0.0.0/0

2. **SSH Security Group**

    **Port**=22   | **Source**= Your IP Address

3. **Webserver Security Group**

    **Port**= 80 and 443 | **Source**= ALB Security Group

    **Port**= 22 | **Source**= SSH Security Group

4. **Database Security Group**

    **Port**= 3306 | **Source**= Webserver Security Group

5. **EFS Security Group**

    **Port**=2049 | **Source**= Webserver Security Group,EFS Security Group

    **Port**=22 | **Source**= SSH Security Group

#### Objectives and Steps
- **Objectives:** Deploy a managed MySQL database using Amazon RDS for WordPress data storage.


- **Steps:**
    - Create an Amazon RDS instance with MySQL engine
    - Confugure security groups for RDS instances.
    - Connect WordPress to the RDS dab=tabase.

### 4. EFC Setup for WordPress Files 

- **Objective:** Utilise amazon Elastic File System (EFS) to store WordPress files for scalable and shared access.

- **Steps:**
    - Create an EFS file system.
    - Mount the EFS file system on WordPress instances.
    - Configure Wordpress to use the shared file system.

### 5. Application Load Balancer
- **Objective:** Set up an Application Load Balancer to distribute incoming traffic among multiple instances, ensuring high availability and fault tolerance.

- **Steps**
    - Create an Application Load Balancer.
    - Configure listener rules for routing traffic to instances.
    - Integrate Load Balancer with Auto Scaling group.

### 6. Auto Scaling Group

- **Objective:** Implement Auto Scaling to automatically adjust the number of instances based on traffic load.

- **Steps:**
    - Create an Auto Scaling group
    - Define scaling policies based on metrics like CPU utilisation.
    - Configure launch configurations for instances.



## Core Architecture Summary
Here’s a simplified view of the major components and their roles:

| Component | Purpose | 

| VPC | Isolates resources into public/private subnets across 2 AZs |

| Internet Gateway | Enables internet access for public subnet resources | 

| NAT Gateway | Allows private subnet instances to access the internet securely | 

| EC2 Instances | Hosts the WordPress application | 

| Application Load Balancer | Distributes traffic across EC2 instances | 

| Auto Scaling Group | Dynamically adjusts EC2 count based on traffic | 

| Amazon RDS (MySQL) | Stores WordPress data in a managed DB | 

| Amazon EFS | Provides shared file storage for WordPress instances | 

| Route 53 | Manages domain name and DNS records | 

| Security Groups | Controls inbound/outbound traffic for each component | 

## WalkThrough

###  Create VPC

1. Navigate to VPC and create a new VPC

    ![Create a VPC](img/2.a.Create_VPC.png)

2. Set Up VPC

    ![Name_VPC](img/2.b.Name_VPC.png)

    - Gave it the name DigitalBoost-VPC
    - CIDR block= 10.0.0.0/16

3. Create VPC

### Create Subnets

1. Navigate to Subnet and create a new subnet

    ![Navigate_to_Subnet](img/3.a.Navigate_Subnet.png)

> We are going to create 6 subnets for each availability zones

2. Link to the VPC Created

    ![Link to VPC](img/3.b.Link_2_VPC.png)

3. Create Public Subnets
- (a). Public Subnet 1- (CIDR=10.0.1.0/24)
    ![Public Subnet 1](img/3.c.Public_Subnet_1.png)

- (b). Public Subnet 2- (CRDR=10.0.2.0/24)
    ![Public Subnet 2](img/3.d.Public_Subnet_2.png)

4. Create Private App Subnets
- (a). Private App Subnet 1- (CIDR=10.0.3.0/24)
    ![Private App Subnet 1](img/3.e.Private_App_Subnet_1.png)

- (b). Private App Subnet 2- (CIDR=10.0.4.0/24)
    ![Private App Subnet 2](img/3.f.Private_App_Subnet_2.png)

5. Create Private DB Subnets
- (a). Private DB Subnet 1- (CIDR=10.0.5.0/24)
    ![Private DB Subnet 1](img/3.g.Private_DB_Subnet_1.png)

- (b). Private DB Subnet 2- (CIDR=10.0.6.0/24)
    ![Private DB Subnet 2](img/3.h.Private_DB_Subnet_2.png)


> When creating subnets, make sure each pair is split across two distinct AZs (e.g., us-east-1a and us-east-1b for North Virginia region). This ensures high availability.

6. Create VPC

7. Verify all Subnet has been created
    ![Verify all created](img/3.i.Verify_All_Created.png)

### Create Internet Gateway
1. Navigate to Internet Gateway
    ![Navigate IGW](img/4.a.Navigate_IGW.png)

2. Create Internet Gateway
    ![Create_IGW](img/4.b.Create_IGW.png)

3. Attach it to VPC
    ![Attach VPC 1](img/4.c.Attach_VPC_1.png)

    ![Attach VPC 2](img/4.d.Attach_VPC_2.png)

4. Verify 
    ![Verify](img/4.e.Verify.png)


### Create Route Table 
1. Navigate to Route Table
    ![Navigate_Route_Table](img/5.a.Navigate_Route_Table.png)

2. Create Public Route Table
   ![Public_Route_Table](img/5.b.Public_Route_Table.png) 

3. Route to Internet Gateway
    ![Edit_Route](img/5.c.Edit_Route.png)

    ![Add_Route](img/5.d.Add_Route.png)

    ![Verify Public Route Table](img/5.e.Verify_pub_RT.png)

4. Create Private Route Table

Since I did not set the Public Route Table as the main, another route table has been created and is classed as the main

![Main Route Table](img/5.f.Main_RT.png)

We are going to rename the route table to Private Route Table.

![Manage Tag](img/5.g.Manage_Tag.png)

![Name Route Table](img/5.h.Name_RT.png)

![Verify Name Change](img/5.i.Verify_Name_Change.png)

### Associate Route Table

1. Public subnets → Public Route Table
    ![Subnet_Association](img/6.a.subnet_association.png)

    ![Associate_Public_subnet](img/6.b.Associate_Public.png)

2. Private subnets → Private Route Table

    ![Subnet_Association_Private](img/6.c.subnet_association_private.png)

    ![Associate_Private_subnet](img/6.d.associate_Private_sub.png)


----

### Create an Elastic IP

This is needed for NAT Gateway

1. Navigate to Elastic IP
    ![Navigate to Elastic IP](img/7.a.Navigate_Elastic_IP.png)

2. Allocate Elastic IP
    ![Allocate](img/7.b.Allocate.png)

### Create NAT Gateway

1. Navigate to NAT Gateway
    ![Navigate to NAT Gateway](img/8.a.Navigate_NAT_Gateway.png)

2. Create NAT Gateway
    ![Create NAT Gateway](img/8.b.Create_NAT_Gateway.png)
 - Place it in one of the public subnet
 - Associate it with the elastic IP created

### Update Private Route Table

1. Edit Route 
    ![Edit Private Route](img/8.c.Edit_Private_Route.png)

2. Add NAT Gateway

    ![Add Route Private](img/8.d.Add_Route_Private.png)

3. Verify Changes

    ![Verify Change](img/8.e.Verify_Change.png)

### Create Bastion Host 
1. Launch an EC2 instance in a public subnet.
    ![Bastion Host](img/9.a.Bastion_Host.png)

    ![Public_Subnet](img/9.b.Public_Subnet.png)

2. Assign a security group that allows SSH (port 22) only from trusted IPs.

    ![Bastion Host Security Group](img/9.c.Bastion_Host_SG.png)

> I set the source type as My IP as I am working by myself.

3. Launch Instance

    ![Launch_Instance](img/9.d.Launch_Instance.png)

4. Verify EC2 Creation
    ![Verify EC2 Creation](img/9.e.Verify_EC2_Creation.png)

----


### Create Launch Template

1. Navigate to Launch Template
    ![Navigate_Launch_Template](img.1/1.a.Navigate_Launch_Template.png)

2. Name Template
    ![Name Template](img.1/1.b.Name_Template.png)

3. Link AMIs
    ![Link AMI](img.1/1.c.Link_AMI.png)
    - I used Amazon Linux AMI but it is also possible to use Ubuntu

4. User Data

Input this code into the user data

~~~
#1. create the html directory and mount the efs to it
sudo su
yum update -y
mkdir -p /var/www/html
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-03c9b3354880b36a6.efs.us-east-1.amazonaws.com:/ /var/www/html


#2. install apache 
sudo yum install -y httpd httpd-tools mod_ssl
sudo systemctl enable httpd 
sudo systemctl start httpd


#3. install php 7.4
sudo amazon-linux-extras enable php7.4
sudo yum clean metadata
sudo yum install php php-common php-pear -y
sudo yum install php-{cgi,curl,mbstring,gd,mysqlnd,gettext,json,xml,fpm,intl,zip} -y


#4. install mysql5.7
sudo rpm -Uvh https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
sudo yum install mysql-community-server -y
sudo systemctl enable mysqld
sudo systemctl start mysqld


#5. set permissions
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
sudo find /var/www -type f -exec sudo chmod 0664 {} \;
chown apache:apache -R /var/www/html 


#6. download wordpress files
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* /var/www/html/


#7. create the wp-config.php file
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php


#8. edit the wp-config.php file
nano /var/www/html/wp-config.php


#9. restart the webserver
service httpd restart
~~~

5. Create Launch Template
    ![Create Launch Template](img.1/1.d.Create_Launch_Template.png)

### Create Auto Scaling Group

1. Navigate to AutoScaling Group
    ![Navigate Auto Scaling Group](img.1/2.a.Navigate_ASG.png)

2. Use Launch Template
    ![Use Launch Template](img.1/2.b.Use_Launch_Template.png)

3. Assign two Availability Zones

For best practice, the wordpress EC2 instance should not be directly exposed to the internet. Instead, they receive traffic via the application Load balancers, which lives in the public subnet. This setup enhances security, scalability, and fault tolerance.

- **Network**: Select your VPC
    ![Select VPC for ASG](img.1/2.c.VPC_ASG.png)

- **Subnets**: Choose the private app subnets
    ![Subnets for ASG](img.1/2.d.Subnet_ASG.png)

4. Create **Auto Scaling Group**


5. Attach to target group for ALB

- Target type: Instances 
- Name: Something like wordpress-asg-tg
- Protocol/Port: HTTP on port 80
- VPC: Select the one where your EC2 instances will live
- Health checks: Use / or /wp-login.php for WordPress
