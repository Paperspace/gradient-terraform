# Gradient Installer

The Gradient installer will provision a Gradient processing site cluster on various types of infrastructure. The installer runs in different modes – there's an AWS-specific version that creates a Gradient cluster in Amazon's Elastic Kubernetes Service (EKS), and a more generic version that can configure bare metal servers or virtual machines in nearly any environment - including NVIDIA's DGX-1 and Google Cloud's Compute Engine.

### Supported target platforms

- AWS
- VM / Baremetal
- NVIDIA DGX-1

### General prerequisites

- Terraform 0.12 installed on your computer, or on a cloud instance that has network access to the environment where Gradient will run (not required for DGX installer mode)
- Technical familiarity with the cloud provider or private cloud environment where you will install and run Gradient
- SDK or CLI tools installed from your cloud provider, if necessary (e.g. aws-cli, aws-iam-authenticator)

### Installation

The installation process includes several pre-installation steps that apply to all installation modes. These include setting up an AWS S3 bucket for artifact storage, setting up a SSL certificate, and creating a place to store Terraform state files.

After that, each installation mode requires that a main.tf file is generated and applied via Terraform. The update and uninstall processes are also a little different for each install mode.

All of these steps are documented in detail here:
https://docs.paperspace.com/gradient/gradient-private-cloud (https://docs.paperspace.com/gradient/gradient-private-cloud/)
