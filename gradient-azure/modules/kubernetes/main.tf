locals {
    asg_max_size_default = 20
    root_volume_size_default = 256

    node_instance_types = merge({
        "services-small"="Standard_D4s_v3",
        "services-medium"="Standard_D16s_v3",
        "services-large"="Standard_D48s_v3",

        "experiment-cpu-small"="Standard_D4s_v3",
        "experiment-cpu-medium"="Standard_D16s_v3",
        "experiment-cpu-large"="Standard_D48s_v3",
        "experiment-gpu-small"="Standard_NC6_Promo",
        "experiment-gpu-medium"="Standard_NC6s_v2",
        "experiment-gpu-large"="Standard_NC6s_v3",

        "model-deployment-cpu-small"="Standard_D4s_v3",
        "model-deployment-cpu-medium"="Standard_D16s_v3",
        "model-deployment-cpu-large"="Standard_D48s_v3",
        "model-deployment-gpu-small"="Standard_NC6_Promo",
        "model-deployment-gpu-medium"="Standard_NC6s_v2",
        "model-deployment-gpu-large"="Standard_NC6s_v3",

        "notebook-cpu-small"="Standard_D4s_v3",
        "notebook-cpu-medium"="Standard_D16s_v3",
        "notebook-cpu-large"="Standard_D48s_v3",
        "notebook-gpu-small"="Standard_NC6_Promo",
        "notebook-gpu-medium"="Standard_NC6s_v2",
        "notebook-gpu-large"="Standard_NC6s_v3",

        "tensorboard-cpu-small"="Standard_D4s_v3",
        "tensorboard-cpu-medium"="Standard_D16s_v3",
        "tensorboard-cpu-large"="Standard_D48s_v3",
        "tensorboard-gpu-small"="Standard_NC6_Promo",
        "tensorboard-gpu-medium"="Standard_NC6s_v2",
        "tensorboard-gpu-large"="Standard_NC6s_v3",
    }, var.node_instance_types)

    node_asg_desired_sizes = {
        "services-small"=0,
        "services-medium"=0,
        "services-large"=0,

        "experiment-cpu-small"=0,
        "experiment-cpu-medium"=0,
        "experiment-cpu-large"=0,
        "experiment-gpu-small"=0,
        "experiment-gpu-medium"=0,
        "experiment-gpu-large"=0,

        "model-deployment-cpu-small"=0,
        "model-deployment-cpu-medium"=0,
        "model-deployment-cpu-large"=0,
        "model-deployment-gpu-small"=0,
        "model-deployment-gpu-medium"=0,
        "model-deployment-gpu-large"=0,

        "notebook-cpu-small"=0,
        "notebook-cpu-medium"=0,
        "notebook-cpu-large"=0,
        "notebook-gpu-small"=0,
        "notebook-gpu-medium"=0,
        "notebook-gpu-large"=0,

        "tensorboard-cpu-small"=0,
        "tensorboard-cpu-medium"=0,
        "tensorboard-cpu-large"=0,
        "tensorboard-gpu-small"=0,
        "tensorboard-gpu-medium"=0,
        "tensorboard-gpu-large"=0,
    }

    node_asg_min_sizes = merge({
        "services-small"=1,
        "services-medium"=0,
        "services-large"=0,

        "experiment-cpu-small"=0,
        "experiment-cpu-medium"=0,
        "experiment-cpu-large"=0,
        "experiment-gpu-small"=0,
        "experiment-gpu-medium"=0,
        "experiment-gpu-large"=0,

        "model-deployment-cpu-small"=0,
        "model-deployment-cpu-medium"=0,
        "model-deployment-cpu-large"=0,
        "model-deployment-gpu-small"=0,
        "model-deployment-gpu-medium"=0,
        "model-deployment-gpu-large"=0,

        "notebook-cpu-small"=0,
        "notebook-cpu-medium"=0,
        "notebook-cpu-large"=0,
        "notebook-gpu-small"=0,
        "notebook-gpu-medium"=0,
        "notebook-gpu-large"=0,

        "tensorboard-cpu-small"=0,
        "tensorboard-cpu-medium"=0,
        "tensorboard-cpu-large"=0,
        "tensorboard-gpu-small"=0,
        "tensorboard-gpu-medium"=0,
        "tensorboard-gpu-large"=0,
    }, var.node_asg_min_sizes)

    node_asg_max_sizes = merge({
        "services-small"=local.asg_max_size_default,
        "services-medium"=local.asg_max_size_default,
        "services-large"=local.asg_max_size_default,

        "experiment-cpu-small"=local.asg_max_size_default,
        "experiment-cpu-medium"=local.asg_max_size_default,
        "experiment-cpu-large"=local.asg_max_size_default,
        "experiment-gpu-small"=local.asg_max_size_default,
        "experiment-gpu-medium"=local.asg_max_size_default,
        "experiment-gpu-large"=local.asg_max_size_default,

        "model-deployment-cpu-small"=local.asg_max_size_default,
        "model-deployment-cpu-medium"=local.asg_max_size_default,
        "model-deployment-cpu-large"=local.asg_max_size_default,
        "model-deployment-gpu-small"=local.asg_max_size_default,
        "model-deployment-gpu-medium"=local.asg_max_size_default,
        "model-deployment-gpu-large"=local.asg_max_size_default,

        "notebook-cpu-small"=local.asg_max_size_default,
        "notebook-cpu-medium"=local.asg_max_size_default,
        "notebook-cpu-large"=local.asg_max_size_default,
        "notebook-gpu-small"=local.asg_max_size_default,
        "notebook-gpu-medium"=local.asg_max_size_default,
        "notebook-gpu-large"=local.asg_max_size_default,

        "tensorboard-cpu-small"=local.asg_max_size_default,
        "tensorboard-cpu-medium"=local.asg_max_size_default,
        "tensorboard-cpu-large"=local.asg_max_size_default,
        "tensorboard-gpu-small"=local.asg_max_size_default,
        "tensorboard-gpu-medium"=local.asg_max_size_default,
        "tensorboard-gpu-large"=local.asg_max_size_default,
    }, var.node_asg_max_sizes)

    node_types = [
        "services-small",
        "services-medium",
        "services-large",

        "experiment-cpu-small",
        "experiment-cpu-medium",
        "experiment-cpu-large",
        "experiment-gpu-small",
        "experiment-gpu-medium",
        "experiment-gpu-large",

        "model-deployment-cpu-small",
        "model-deployment-cpu-medium",
        "model-deployment-cpu-large",
        "model-deployment-gpu-small",
        "model-deployment-gpu-medium",
        "model-deployment-gpu-large",

        "notebook-cpu-small",
        "notebook-cpu-medium",
        "notebook-cpu-large",
        "notebook-gpu-small",
        "notebook-gpu-medium",
        "notebook-gpu-large",

        "tensorboard-cpu-small",
        "tensorboard-cpu-medium",
        "tensorboard-cpu-large",
        "tensorboard-gpu-small",
        "tensorboard-gpu-medium",
        "tensorboard-gpu-large",
    ]

    node_pool_types = {
        "services-small"="cpu",
        "services-medium"="cpu",
        "services-large"="cpu",
        "experiment-cpu-small"="cpu",
        "experiment-cpu-medium"="cpu",
        "experiment-cpu-large"="cpu",
        "experiment-gpu-small"="gpu",
        "experiment-gpu-medium"="gpu",
        "experiment-gpu-large"="gpu",
        "model-deployment-cpu-small"="cpu",
        "model-deployment-cpu-medium"="cpu",
        "model-deployment-cpu-large"="cpu",
        "model-deployment-gpu-small"="gpu",
        "model-deployment-gpu-medium"="gpu",
        "model-deployment-gpu-large"="gpu",
        "notebook-cpu-small"="cpu",
        "notebook-cpu-medium"="cpu",
        "notebook-cpu-large"="cpu",
        "notebook-gpu-small"="gpu",
        "notebook-gpu-medium"="gpu",
        "notebook-gpu-large"="gpu",
        "tensorboard-cpu-small"="cpu",
        "tensorboard-cpu-medium"="cpu",
        "tensorboard-cpu-large"="cpu",
        "tensorboard-gpu-small"="gpu",
        "tensorboard-gpu-medium"="gpu",
        "tensorboard-gpu-large"="gpu",
    }

    kubelet_extra_args = {
        "services-small"=[],
        "services-medium"=[],
        "services-large"=[],
        "experiment-cpu-small"=[],
        "experiment-cpu-medium"=[],
        "experiment-cpu-large"=[],
        "experiment-gpu-small"=[
            "cloud.google.com/gke-accelerator=nvidia-tesla-k80",
            "k8s.amazonaws.com/accelerator=nvidia-tesla-k80",
            "accelerator=nvidia-tesla-k80",
        ],
        "experiment-gpu-medium"=[
            "cloud.google.com/gke-accelerator=nvidia-tesla-p100",
            "k8s.amazonaws.com/accelerator=nvidia-tesla-p100",
            "accelerator=nvidia-tesla-p100",
        ],
        "experiment-gpu-large"=[
            "cloud.google.com/gke-accelerator=nvidia-tesla-v100",
            "k8s.amazonaws.com/accelerator=nvidia-tesla-v100",
            "accelerator=nvidia-tesla-v100",
        ],

        "model-deployment-cpu-small"=[],
        "model-deployment-cpu-medium"=[],
        "model-deployment-cpu-large"=[],
        "model-deployment-gpu-small"=[
            "cloud.google.com/gke-accelerator=nvidia-tesla-k80",
            "k8s.amazonaws.com/accelerator=nvidia-tesla-k80",
            "accelerator=nvidia-tesla-k80",
        ],
        "model-deployment-gpu-medium"=[
            "cloud.google.com/gke-accelerator=nvidia-tesla-p100",
            "k8s.amazonaws.com/accelerator=nvidia-tesla-p100",
            "accelerator=nvidia-tesla-p100",
        ],
        "model-deployment-gpu-large"=[
            "cloud.google.com/gke-accelerator=nvidia-tesla-v100",
            "k8s.amazonaws.com/accelerator=nvidia-tesla-v100",
            "accelerator=nvidia-tesla-v100",
        ],

        "notebook-cpu-small"=[],
        "notebook-cpu-medium"=[],
        "notebook-cpu-large"=[],
        "notebook-gpu-small"=[
            "cloud.google.com/gke-accelerator=nvidia-tesla-k80",
            "k8s.amazonaws.com/accelerator=nvidia-tesla-k80",
            "accelerator=nvidia-tesla-k80",
        ],
        "notebook-gpu-medium"=[
            "cloud.google.com/gke-accelerator=nvidia-tesla-p100",
            "k8s.amazonaws.com/accelerator=nvidia-tesla-p100",
            "accelerator=nvidia-tesla-p100",
        ],
        "notebook-gpu-large"=[
            "cloud.google.com/gke-accelerator=nvidia-tesla-v100",
            "k8s.amazonaws.com/accelerator=nvidia-tesla-v100",
            "accelerator=nvidia-tesla-v100",
        ],

        "tensorboard-cpu-small"=[],
        "tensorboard-cpu-medium"=[],
        "tensorboard-cpu-large"=[],
        "tensorboard-gpu-small"=[
            "cloud.google.com/gke-accelerator=nvidia-tesla-k80",
            "k8s.amazonaws.com/accelerator=nvidia-tesla-k80",
            "accelerator=nvidia-tesla-k80",
        ],
        "tensorboard-gpu-medium"=[
            "cloud.google.com/gke-accelerator=nvidia-tesla-p100",
            "k8s.amazonaws.com/accelerator=nvidia-tesla-p100",
            "accelerator=nvidia-tesla-p100",
        ],
        "tensorboard-gpu-large"=[
            "cloud.google.com/gke-accelerator=nvidia-tesla-v100",
            "k8s.amazonaws.com/accelerator=nvidia-tesla-v100",
            "accelerator=nvidia-tesla-v100",
        ],

    }

    node_volume_sizes = merge({
        "services-small"=local.root_volume_size_default,
        "services-medium"=local.root_volume_size_default,
        "services-large"=local.root_volume_size_default,

        "experiment-cpu-small"=local.root_volume_size_default,
        "experiment-cpu-medium"=local.root_volume_size_default,
        "experiment-cpu-large"=local.root_volume_size_default,
        "experiment-gpu-small"=local.root_volume_size_default,
        "experiment-gpu-medium"=local.root_volume_size_default,
        "experiment-gpu-large"=local.root_volume_size_default,

        "model-deployment-cpu-small"=local.root_volume_size_default,
        "model-deployment-cpu-medium"=local.root_volume_size_default,
        "model-deployment-cpu-large"=local.root_volume_size_default,
        "model-deployment-gpu-small"=local.root_volume_size_default,
        "model-deployment-gpu-medium"=local.root_volume_size_default,
        "model-deployment-gpu-large"=local.root_volume_size_default,

        "notebook-cpu-small"=local.root_volume_size_default,
        "notebook-cpu-medium"=local.root_volume_size_default,
        "notebook-cpu-large"=local.root_volume_size_default,
        "notebook-gpu-small"=local.root_volume_size_default,
        "notebook-gpu-medium"=local.root_volume_size_default,
        "notebook-gpu-large"=local.root_volume_size_default,

        "tensorboard-cpu-small"=local.root_volume_size_default,
        "tensorboard-cpu-medium"=local.root_volume_size_default,
        "tensorboard-cpu-large"=local.root_volume_size_default,
        "tensorboard-gpu-small"=local.root_volume_size_default,
        "tensorboard-gpu-medium"=local.root_volume_size_default,
        "tensorboard-gpu-large"=local.root_volume_size_default,
    }, var.node_asg_max_sizes)

    worker_groups = [for node_type in local.node_types : {
        asg_desired_capacity = local.node_asg_desired_sizes[node_type]
        asg_max_size = local.node_asg_max_sizes[node_type]
        asg_min_size = local.node_asg_min_sizes[node_type]
        instance_type = local.node_instance_types[node_type]

        kubelet_extra_args = "--node-labels=${join(",",
            concat([
                "paperspace.com/pool-name=${node_type}",
                "paperspace.com/pool-type=${local.node_pool_types[node_type]}",
                "node-role.kubernetes.io/node=",
                "node-role.kubernetes.io/worker=",
                "node-role.kubernetes.io/${node_type}",
            ], local.kubelet_extra_args[node_type])
        )}"

    }]
}

data "aws_eks_cluster" "cluster" {
    count = var.enable ? 1 : 0
    name  = module.eks.cluster_id
}

provider "kubernetes" {
    host                   = element(concat(data.aws_eks_cluster.cluster[*].endpoint, list("")), 0)
    cluster_ca_certificate = base64decode(element(concat(data.aws_eks_cluster.cluster[*].certificate_authority.0.data, list("")), 0))
    token                  = element(concat(data.aws_eks_cluster_auth.cluster[*].token, list("")), 0)
    load_config_file       = false
    version = "1.11.1"
}

module "eks" {
    source          = "terraform-aws-modules/eks/aws"

    config_output_path = pathexpand(var.kubeconfig_path)
    create_eks = var.enable
    cluster_name    = var.name
    cluster_version = var.k8s_version
    vpc_id          = var.vpc_id

    wait_for_cluster_cmd = "until curl -k -s $ENDPOINT/healthz >/dev/null; do sleep 4; done"

    write_kubeconfig = var.write_kubeconfig
}

resource "null_resource" "cluster_status" {
  depends_on = [module.eks]

  provisioner "local-exec" {
    command     = "until curl -k -s $ENDPOINT/healthz >/dev/null; do sleep 4; done"
    environment = {
      ENDPOINT = element(concat(data.aws_eks_cluster.cluster[*].endpoint, list("")), 0)
    }
  }
}