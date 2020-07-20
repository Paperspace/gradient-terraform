# Gradient Installer

![GitHub release (latest by date)](https://img.shields.io/github/v/release/stripe/stripe-cli)

Gradient Installer is a CLI to manage and setup Gradient private clusters on AWS, NVIDIA DGX-1, and any VM / Baremetal. 

Terraform is used under the hood to setup all the infrastructure. Terraform modules can also be used directly to integrate Gradient into an existing Terraform setup.

### Supported target platforms
- AWS EKS
- NVIDIA DGX-1
- VM / Baremetal

## Prerequisites
- A Paperspace account with appropriate billing plan and API key [https://www.paperspace.com]
- An AWS S3 bucket to store Terraform state [https://docs.aws.amazon.com/AmazonS3/latest/user-guide/create-bucket.html]

## Install / Update
```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/paperspace/gradient-installer/master/bin/install)"
```

### Updating Gradient Installer
```sh
gradient-installer update
```

## Usage

### Setup a Gradient private cluster
```sh
gradient-installer clusters up
```

### Updating existing clusters
```sh
gradient-installer clusters up CLUSTER_HANDLE
```

### Profiles
The CLI support multiple profiles, which can be used for different teams. You can use profile by:
```sh
export PAPERSPACE_PROFILE=favorite-team
gradient-installer setup
```

## Terraform
To keep track of the state of your cluster, the CLI stores your state file in an S3 bucket.
Terraform modules can be used directory, here is a list of available modules
- gradient-aws
- gradient-metal
- gradient-ps-cloud

## Documentation
Full docs: https://docs.paperspace.com/gradient/gradient-private-cloud/about