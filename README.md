# Gradient Terraform

Installer for Paperspace Gradient processing site

### Requirements
- Terraform >= 0.12 (https://www.terraform.io)
- aws-iam-authenticator, if using an EKS cluster (https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)

### Supported target platforms
- AWS
- VM / Baremetal

## Pre-install
### 1. Register your processing site with Paperspace.com
You can register a processing site with Paperspace at: https://www.paperspace.com/console/clusters

Copy the cluster API key and cluster handle to be used for later

### 2. Setup an artifacts bucket
Gradient requires an S3 compatible bucket to store artifacts, this will need to be setup before running the installer. You will also have to add your credentials to Paperspace with write access at: https://www.paperspace.com/console/teams/[team_id]/s3

#### Setup AWS S3 credentials
Create an IAM user / role with the following policy and get an ACCESS_KEY and SECRET_ACCESS_KEY:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowGeneratedUrls",
            "Effect": "Allow",
            "Action": "sts:GetFederationToken",
            "Resource": "*"
        },
        {
            "Sid": "AllowListbucket",
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::[bucket_name]"
        },
        {
            "Sid": "AllowBucketAccess",
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::[bucket]/*"
        }
    ]
}
```
#### Add CORS permissions to your bucket
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
<CORSRule>
    <AllowedOrigin>https://www.paperspace.com</AllowedOrigin>
    <AllowedMethod>GET</AllowedMethod>
    <AllowedMethod>PUT</AllowedMethod>
    <MaxAgeSeconds>3000</MaxAgeSeconds>
    <AllowedHeader>*</AllowedHeader>
</CORSRule>
</CORSConfiguration>
```

### 3. Setup shared file storage
A shared file server is used to share files across workers. The AWS version of this installer will take care of this for you, but if you're using the VM/bare metal version you will need to set this up on your own.

Currently supported: 
- efs
- nfs (ensure export has proper permissions nobody:nogroup)

### 4. Setup a wildcard SSL certificate
Gradient uses a wildcard SSL certificate to secure HTTP traffic into your processing site.

Example:
- *.gradient.mycompany.com

### 5. Setup gradient-terraform
```
git clone git@github.com:Paperspace/gradient-terraform.git gradient-terraform
gradient-terraform/bin/setup
mkdir gradient-cluster
cd gradient-cluster
```

### 6. Create terraform provider file in S3 (optional)
Create a file called in gradient-cluster folder called: backend.tf
```
terraform {
    backend "s3" {
        bucket = "artifacts-bucket"
        key    = "gradient-processing"
        region = "us-east-1"
        session_name = "gradient-processing-terraform"
    }
}
```

## Installing Gradient on AWS

### Create a main.tf file in the gradient-cluster folder
```
module "gradient_aws" {
    source = "../gradient-terraform/gradient-aws"

    // name should only have letters, numbers, and dashes
    name = "cluster-name"
    aws_region = "us-east-1"

    artifacts_access_key_id = "artifacts-access-key-id"
    artifacts_path = "s3://artifacts-bucket"
    artifacts_secret_access_key = "artifacts-secret-access-key"
    
    cluster_apikey = "cluster-apikey-from-paperspace-com"
    cluster_handle = "cluster-handle-from-paperspace-com"
    domain = "gradient.mycompany.com"

    tls_cert = replace(file("./certs/ssl-bundle.crt"), "\n", "\\n")
    tls_key = replace(file("./certs/ssl.key"), "\n", "\\n")
}

output "ELB_HOSTNAME" {
    value = module.gradient_aws.elb_hostname
}
```

### Install and run Gradient
This will provision infrastructure on AWS using your system's configured AWS credentials. You can use your default credentials or a configured profile (https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html)
```sh
terraform init
terraform apply
```

### DNS
Gradient requires two DNS records to make external services accessible. A dynamic ELB will created and a hostname will be shown after install that you can create records on your DNS provider (Cloudflare, Route 53, )
Example:
- CNAME RECORD *.gradient.mycompany.com [ELB_HOSTNAME]
- CNAME RECORD gradient.mycompany.com [ELB_HOSTNAME]

### KUBECONFIG
For using the generated KUBECONFIG, EKS requires aws-iam-authenticator to be installed: https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html

Do not remove the cluster creater user or by default you won't have access to kubernetes and you will need to SSH in to add new IAM users.

### Hot nodes
By default, hot nodes are set up for experiments, model deployments, notebooks, and tensorboards. Hot nodes can be configured by setting k8s_node_asg_min_sizes.

Here are the current defaults:
```
  k8s_node_asg_min_sizes = {
        "experiment-cpu-small"=1,
        "experiment-cpu-medium"=0,
        "experiment-gpu-small"=0,
        "experiment-gpu-medium"=0,
        "experiment-gpu-large"=0

        "model-deployment-cpu-small"=1,
        "model-deployment-cpu-medium"=0,
        "model-deployment-gpu-small"=0,
        "model-deployment-gpu-medium"=0,
        "model-deployment-gpu-large"=0

        "notebook-cpu-small"=1,
        "notebook-cpu-medium"=0,
        "notebook-gpu-small"=0,
        "notebook-gpu-medium"=0,
        "notebook-gpu-large"=0,

        "tensorboard-cpu-small"=1,
        "tensorboard-cpu-medium"=0,
        "tensorboard-gpu-small"=0,
        "tensorboard-gpu-medium"=0,
        "tensorboard-gpu-large"=0
  }
```

## Installing Gradient on VM / baremetal
Requirements
- Ubuntu 18.04, Docker installed on all hosts (use "setup_docker = true" to have hosts setup with docker)
- Set default docker runtime to nvidia in /etc/docker/daemon.json (this is automatically done if using "setup_nvidia = true":
```
The following is an example of how the added line appears in the JSON file. Do not remove any pre-existing content when making this change.
{
    "default-runtime": "nvidia",
    "runtimes": {
        "nvidia": {
            "path": "/usr/bin/nvidia-container-runtime",
            "runtimeArgs": []
        }
    }
}
```
- Ensure your SSH user has access to the docker group in /etc/group:
```
docker:x:999:ubuntu
```
- Ensure your SSH public key is installed on each host
- Ensure sudo is enabled for the account you're logging into
- Ensure /etc/sshd/sshd_config has the following setting (and reload: service ssh reload)
```
AllowTcpForwarding yes
```

### Create a main.tf file in the gradient-cluster folder
```
module "gradient_metal" {
    source = "../gradient-terraform/gradient-metal"

    // name should only have letters, numbers, and dashes
    name = "cluster-name"
    artifacts_access_key_id = "artifacts-access-key-id"
    artifacts_path = "s3://artifacts-bucket"
    artifacts_secret_access_key = "artifacts-secret-access-key"
    
    cluster_apikey = "cluster-apikey-from-paperspace-com"
    cluster_handle = "cluster-handle-from-paperspace-com"
    domain = "gradient.mycompany.com"
    global_selector = "metal"

    k8s_master_ips = [
        "master_ip1",
    ]
    k8s_workers = [
        {
            ip = "worker_ip1"
            pool-type = "gpu"
            pool-name = "metal-gpu"
        },
        {
            ip = "worker_ip2"
            pool-type = "cpu"
            pool-name = "metal-cpu"
        }
    ]

    // Uncomment to setup docker
    // setup_docker = true 

    shared_storage_path = "/srv/gradient"
    shared_storage_server = "shared-nfs-storage.com"
    ssh_key_path = "~/.ssh/gradient_rsa"
    ssh_user = "ubuntu"

    tls_cert = replace(file("./certs/ssl-bundle.crt"), "\n", "\\n")
    tls_key = replace(file("./certs/ssl.key"), "\n", "\\n")
}
```

### Install and run Gradient
This will configure your VM instances or bare metal machines and install and run Gradient
```sh
terraform init
terraform apply
```
If NVIDIA Cuda drivers were selected to be installed a reboot of all GPU workers is required

### DNS
Gradient requires two DNS records to make external services accessible
Example:
- A RECORD *.gradient.mycompany.com [master_ip]
- A RECORD gradient.mycompany.com [master_ip]


## Installing via Docker
- Create a directory with a main.tf in a gradient-cluster directory as described above
- Run
```sh
docker run -ti --rm -v $(pwd)/gradient-cluster:/home/paperspace/gradient-cluster paperspace/gradient-terraform

```

## Managing your cluster
### Kubeconfig
A kubeconfig will be written to the directory of main.tf, the default is: gradient-kubeconfig

### Terraform state file
Terraform state is written to the same directory as your main.tf file. This manages the state of your cluster and is required to manage the ongoing state of your cluster.

### Upgrading
By default, the latest version of Gradient Processing is installed every time you run: terraform-apply

### Uninstalling Gradient
```sh
terraform destroy
```
