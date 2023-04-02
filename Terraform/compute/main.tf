data "aws_instance" "compute" {
  instance_id = module.compute.id
}

data "aws_subnet_ids" "private" {
  vpc_id = var.vpc_id
  filter {
    name = "availability-zone"
    values = ["${var.region}a"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = var.key_pub
  tags       = var.tags
}

module "compute" {
  source   = "terraform-aws-modules/ec2-instance/aws"
  version  = "~> 3.0"

  name  = var.name
  ami  = var.ami
  instance_type  = var.instance_type
  subnet_id  = tolist(data.aws_subnet_ids.private.ids)[0]
  tags  = var.tags
  key_name  = aws_key_pair.deployer.key_name
  vpc_security_group_ids  = [aws_security_group.compute_sg.id]
  iam_instance_profile  = aws_iam_instance_profile.compute-iam-instance-profile.id
  volume_tags  = merge(
    var.tags,
    {
      "VolumeName" = "${var.name}-xvdb"
    },
  )
  monitoring  = true
  associate_public_ip_address  = false
  ebs_optimized  = false
  create  = true
  availability_zone  = null
  capacity_reservation_specification  = null
  cpu_credits  = null
  disable_api_termination  = null
  ebs_block_device  = []
  enclave_options_enabled  = null
  ephemeral_block_device  = []
  get_password_data  = null
  hibernation  = null
  host_id  = null
  instance_initiated_shutdown_behavior  = null
  ipv6_address_count  = null
  ipv6_addresses  = null
  launch_template  = null
  metadata_options  = {}
  network_interface  = []
  placement_group  = null
  private_ip  = null
  root_block_device  = []
  secondary_private_ips  = null
  source_dest_check  = true
  tenancy  = null
  user_data  = null
  user_data_base64  = null
  enable_volume_tags  = true
  timeouts  = {}
  cpu_core_count  = null
  cpu_threads_per_core  = null
  create_spot_instance  = false
  spot_price  = null
  spot_wait_for_fulfillment  = null
  spot_type  = null
  spot_launch_group  = null
  spot_block_duration_minutes  = null
  spot_instance_interruption_behavior  = null
  spot_valid_until  = null
  spot_valid_from  = null
}

resource "aws_security_group" "compute_sg" {
  name  = "compute_sg-${var.region}"
  description = "Security Group For EC2 Compute Instances"
  vpc_id = var.vpc_id

  ingress {
    description = "Managed Devices to Compute"
    from_port  = 3978
    to_port  = 3978
    protocol  = "tcp"
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12"]
  }
  

  ingress {
    description = "Ping"
    from_port  = -1
    to_port  = -1
    protocol  = "icmp"
    cidr_blocks = ["10.0.0.0/8"]
  }


  ingress {
    description = "HTTPS"
    from_port  = 443
    to_port  = 443
    protocol  = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    description = "SSH"
    from_port  = 22
    to_port  = 22
    protocol  = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port  = 0
    to_port  = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_ebs_volume" "compute_log_drive" {
  availability_zone = data.aws_instance.compute.availability_zone
  size  = "2048"
  encrypted  = false
  tags  = merge(
    var.tags,
    {
      "VolumeName" = "${var.name}-xvdb",
      "Name" = "${var.name}"
    },
  )
  lifecycle {
    ignore_changes = [availability_zone]
  }
}

resource "aws_volume_attachment" "compute_log_drive_attach" {
  device_name  = "/dev/xvdb"
  volume_id  = aws_ebs_volume.compute_log_drive.id
  instance_id  = module.compute.id
  lifecycle {
    ignore_changes = [instance_id]
  }
}
resource "aws_iam_role" "compute-iam-role" {
  name = "${var.name}-compute-iam-role-${var.region}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}


# FW IAM Policy
resource "aws_iam_policy" "compute-iam-policy" {
  name = "${var.name}-compute-iam-policy-${var.region}"
  description = "IAM Policy for VM-Series Firewall"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
        {
            "Action": [
                "ec2:AttachNetworkInterface",
                "ec2:DetachNetworkInterface",
                "ec2:DescribeInstances",
                "ec2:DescribeNetworkInterfaces"
            ],
            "Resource": [
                "*"
            ],
            "Effect": "Allow"
        },
        {
            "Action": [
                "cloudwatch:PutMetricData"
            ],
            "Resource": [
                "*"
            ],
            "Effect": "Allow"
        }
    ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "policy-attachment" {
  role       = aws_iam_role.compute-iam-role.name
  policy_arn = aws_iam_policy.compute-iam-policy.arn
}

resource "aws_iam_instance_profile" "compute-iam-instance-profile" {
  name = "${var.name}-iam-profile-${var.region}"
  role = aws_iam_role.compute-iam-role.name
}
