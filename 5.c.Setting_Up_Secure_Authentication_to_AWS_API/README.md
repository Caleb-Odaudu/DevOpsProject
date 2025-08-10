# Secure Authentication to AWS API via Shell Script

## Overview
This project guides you through setting up secure authentication to the AWS API using IAM roles, policies, and the AWS CLI. The goal is to enable programmatic access for automation tasks such as creating EC2 instances and S3 buckets.

---

## Objectives
- Create and configure IAM roles, policies, and users.
- Install and configure the AWS CLI.
- Authenticate using programmatic credentials.
- Understand API interactions with AWS services.

---

##  Setup Steps

### Step 1: IAM Configuration

1. **Create IAM Role**
   - Define permissions needed for EC2 and S3 operations.

2. **Create IAM Policy**
   - Grant full access to EC2 and S3 services.

3. **Create IAM User**
   - Name: `automation_user`

4. **Assign Role to User**
   - Link `automation_user` to the IAM role.

5. **Attach Policy to User**
   - Ensure the user inherits permissions directly.

6. **Generate Programmatic Credentials**
   - Access Key ID
   - Secret Access Key

---

###  Step 2: Install AWS CLI

#### On Linux
~~~
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
~~~

#### On Windows
- Download the MSI installer from AWS CLI v2 page.
- Run the installer and follow instructions.
- Verify with: aws --version

#### On macOS
- Download the .pkg installer.
- Run and follow instructions.
- Verify with: aws --version

### Step 3: Configure AWS CLI
~~~
aws configure
Enter:

Access Key ID

Secret Access Key

Default region (e.g., us-east-1)

Output format (e.g., json)
~~~
###Step 4: Test Configuration
~~~
aws ec2 describe-regions --output table
Confirms CLI is authenticated and can query AWS services.
~~~

### Understanding APIs
An API (Application Programming Interface) allows software to communicate with AWS services. The AWS CLI uses these APIs to send structured requests, enabling automation of resource creation and management.

## Summary

This project demonstrates how to securely authenticate to the AWS API using IAM roles, policies, and the AWS CLI. By following the step-by-step guide, you learn to create and configure IAM users, roles, and policies, generate programmatic credentials, and set up the AWS CLI for automation tasks. The project also explains how APIs enable programmatic interaction with AWS services, allowing you to automate resource creation and management efficiently and securely.