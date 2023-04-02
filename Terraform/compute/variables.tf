variable "region" {
  type = string
  description = "Required : The AWS Region to deploy the VPC to"
}
variable "name" {
  description = "Required : Name to be used on EC2 instance created"
  type        = string
  default     = ""
}

variable "ami" {
  description = "Required : ID of AMI to use for the instance"
  type        = string
    validation {
        condition     = contains(["ami-0902d2129320aad21", "ami-00e36206d1e5257e7"], var.ami)
        error_message = "AMI ID must be approved AMIs."
    }
}

variable "instance_type" {
  description = "Optional : ID of AMI to use for the instance."
  type        = string
  default     = "c5.4xlarge"
}

variable "vpc_id" {
  description = "Required : The VPC ID to launch in."
  type        = string
  default     = null
}

variable "key_name" {
  description = "Required : Key name of the Key Pair to use for the instance; which is managed using the `aws_key_pair` resource."
  type        = string
  default     = null
}

variable "key_pub" {
  description = "Required : Public key used for the Key Pair."
  type        = string
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Optional : A map of tags to assign to the resource."
  default     = {}
}
