###

# Description

Infrastructure as code solution using Terraform for 2-Tiered web application.
The deployment uses public AMI with the application code and dependencies already available.
Database scheme of MySQL database is inhereted from the public snapshot of the DB.
Application is connecting to the DB hosted on Amazon RDS by using parameters retrieved from the Amazon Parameter Store.

### Download and Install the AWS CLI
- https://aws.amazon.com/cli/
### Download Terraform
- https://developer.hashicorp.com/terraform/downloads?product_intent=terraform
### Recommended IDE
- Cloud9 IDE 
- Download: https://aws.amazon.com/cloud9/
### How to set environment variables
- Linux or macOS
    ```
    $ export AWS_ACCESS_KEY_ID=##ExampleKeyID##
    $ export AWS_SECRET_ACCESS_KEY=##ExampleAccessKey##
    $ export AWS_DEFAULT_REGION=us-east-1
    $ export AWS_SESSION_TOKEN=##Example_SESSION_TOKEN##
- Windows Command Prompt for user current session
    ```
    C:\> set AWS_ACCESS_KEY_ID=###ExampleKeyID###
    C:\> set AWS_SECRET_ACCESS_KEY=###ExampleAccessKey##
    C:\> set AWS_DEFAULT_REGION=us-east-1
    C:\> set AWS_SESSION_TOKEN=##Example_SESSION_TOKEN##
- Windows PowerShell
    ```
    PS C:\> $Env:AWS_ACCESS_KEY_ID="###ExampleKeyID###"
    PS C:\> $Env:AWS_SECRET_ACCESS_KEY="###ExampleAccessKey##"
    PS C:\> $Env:AWS_DEFAULT_REGION="us-east-1"
    PS C:\> $Env:AWS_SESSION_TOKEN=##Example_SESSION_TOKEN##   

- Note: You should replace the values of **these environment variables**. 
### Pre-requisites

- Terraform version 1.4.x
- Network connectivity
- Valid credential for AWS account (not AWS academy account)
You can use the command below to allow terraform access to Amazon APIs  
    ```
    aws configure
    ```
- Configure the credentials file
    ```
    $aws configure --profile tf-user
    AWS Access Key ID [None]: ##ExampleKeyID##
    AWS Secret Access Key [None]:##ExampleAccessKey##
    Default region name [None]: us-ease-1
    Default output format [None]: json

### Deployment of  2-Tiered web application with Terraform

```
cd Terraform
terraform init
terraform plan
terraform apply 
```
If the 'terraform apply' was successful then you should the ALB as the output

Apply complete! Resources: 36 added, 0 changed, 0 destroyed.
```
Outputs:

alb_dns_name = "this-lb-########.us-east-1.elb.amazonaws.com"

```
Open your browser with to your ALB URL and confirm you can load the flask app 