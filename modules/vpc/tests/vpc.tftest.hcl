mock_provider "aws" {}

variables {
  environment = "test"
}

run "creates_default_vpc_topology" {
  command = plan

  assert {
    condition     = aws_vpc.main.cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR should use the default 10.0.0.0/16 network."
  }

  assert {
    condition     = length(aws_subnet.public) == 2
    error_message = "The default topology should create two public subnets."
  }

  assert {
    condition     = length(aws_subnet.private) == 2
    error_message = "The default topology should create two private subnets."
  }

  assert {
    condition = alltrue([
      for subnet in aws_subnet.public :
      subnet.map_public_ip_on_launch
    ])
    error_message = "All public subnets should enable public IP assignment."
  }

  assert {
    condition = (
      aws_subnet.public[0].availability_zone == "us-east-1a" &&
      aws_subnet.public[1].availability_zone == "us-east-1b"
    )
    error_message = "Public subnets should be distributed across the configured availability zones."
  }
}

run "supports_custom_three_az_topology" {
  command = plan

  variables {
    availability_zones = [
      "us-east-1a",
      "us-east-1b",
      "us-east-1c"
    ]

    public_subnets = [
      "10.0.1.0/24",
      "10.0.2.0/24",
      "10.0.3.0/24"
    ]

    private_subnets = [
      "10.0.11.0/24",
      "10.0.12.0/24",
      "10.0.13.0/24"
    ]
  }

  assert {
    condition     = length(aws_subnet.public) == 3
    error_message = "Three public subnet CIDRs should create three public subnets."
  }

  assert {
    condition     = length(aws_subnet.private) == 3
    error_message = "Three private subnet CIDRs should create three private subnets."
  }

  assert {
    condition     = aws_subnet.private[2].availability_zone == "us-east-1c"
    error_message = "The third private subnet should be created in us-east-1c."
  }
}
