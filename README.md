# Gradient Installer

Gradient Installer is a CLI used to manage and setup Gradient private clusters on various platforms. Terraform is used under the hood to setup all the infrastructure. The Terraform modules can also be used directly to integrate into an existing Terraform infrastructure.

Full docs: https://docs.paperspace.com/gradient/gradient-private-cloud/about

### Supported target platforms
- AWS EKS
- NVIDIA DGX-1
- VM / Baremetal

### Prerequisites
- A Paperspace account with appropriate billing plan and API key [https://www.paperspace.com]
- An AWS S3 bucket to store Terraform state [https://docs.aws.amazon.com/AmazonS3/latest/user-guide/create-bucket.html]

### Install Gradient CLI
```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/paperspace/gradient-installer/master/bin/install)"
```

### Updating Gradient Installer
```sh
gradient-installer update
```

### Profiles
The CLI support multiple profiles, which can be used for different teams. You can use profile by:
```sh
export PAPERSPACE_PROFILE=favorite-team
gradient-installer setup
```

### Setup a Gradient private cluster
```sh
gradient-installer clusters up
```

### Updating existing clusters
```sh
gradient-installer clusters up CLUSTER_HANDLE
```

### Terraform
To keep track of the state of your cluster, the CLI stores your state file in an S3 bucket.
Terraform modules can be used directory, here is a list of available modules
- gradient-aws
- gradient-metal
- gradient-ps-cloud