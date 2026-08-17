mock_provider "aws" {}

variables {
  cluster_name = "test-cluster"

  subnet_ids = [
    "subnet-private-a",
    "subnet-private-b"
  ]
}

run "creates_default_eks_topology" {
  command = plan

  assert {
    condition     = aws_eks_cluster.main.name == "test-cluster"
    error_message = "EKS cluster should use the configured cluster name."
  }

  assert {
    condition     = length(aws_eks_cluster.main.vpc_config[0].subnet_ids) == 2
    error_message = "EKS cluster should use both configured private subnets."
  }

  assert {
    condition     = aws_eks_node_group.main.node_group_name == "test-cluster-nodes"
    error_message = "Node group name should be derived from the cluster name."
  }

  assert {
    condition     = aws_eks_node_group.main.scaling_config[0].desired_size == 2
    error_message = "Default desired node count should be 2."
  }

  assert {
    condition     = aws_eks_node_group.main.scaling_config[0].min_size == 1
    error_message = "Default minimum node count should be 1."
  }

  assert {
    condition     = aws_eks_node_group.main.scaling_config[0].max_size == 3
    error_message = "Default maximum node count should be 3."
  }

  assert {
    condition     = contains(aws_eks_node_group.main.instance_types, "t3.medium")
    error_message = "Default node group should use t3.medium instances."
  }
}

run "supports_custom_node_group_configuration" {
  command = plan

  variables {
    desired_nodes = 3
    min_nodes     = 2
    max_nodes     = 5

    instance_types = [
      "t3.large",
      "t3a.large"
    ]
  }

  assert {
    condition     = aws_eks_node_group.main.scaling_config[0].desired_size == 3
    error_message = "Custom desired node count should be propagated to the node group."
  }

  assert {
    condition     = aws_eks_node_group.main.scaling_config[0].min_size == 2
    error_message = "Custom minimum node count should be propagated to the node group."
  }

  assert {
    condition     = aws_eks_node_group.main.scaling_config[0].max_size == 5
    error_message = "Custom maximum node count should be propagated to the node group."
  }

  assert {
    condition = (
      contains(aws_eks_node_group.main.instance_types, "t3.large") &&
      contains(aws_eks_node_group.main.instance_types, "t3a.large")
    )
    error_message = "Custom instance types should be propagated to the node group."
  }
}

run "attaches_required_managed_policies" {
  command = plan

  assert {
    condition = (
      aws_iam_role_policy_attachment.cluster_policy.policy_arn ==
      "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    )
    error_message = "Cluster role should include AmazonEKSClusterPolicy."
  }

  assert {
    condition = (
      aws_iam_role_policy_attachment.node_worker_policy.policy_arn ==
      "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    )
    error_message = "Node role should include AmazonEKSWorkerNodePolicy."
  }

  assert {
    condition = (
      aws_iam_role_policy_attachment.node_cni_policy.policy_arn ==
      "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    )
    error_message = "Node role should include AmazonEKS_CNI_Policy."
  }

  assert {
    condition = (
      aws_iam_role_policy_attachment.node_registry_policy.policy_arn ==
      "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    )
    error_message = "Node role should include AmazonEC2ContainerRegistryReadOnly."
  }
}
