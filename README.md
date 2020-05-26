# Gradient Installer

The Gradient installer is a module that you can run using Terraform that will provision a Gradient processing site cluster on various types of infrastructure. The installer can be configured to be run in different modes: there's an AWS-specific version that creates a Gradient cluster in Amazon's Elastic Kubernetes Service (EKS), and a more generic version that can configure bare metal servers or virtual machines in nearly any environment - including NVIDIA's DGX-1 and Google Cloud's Compute Engine.

The Gradient Installer is not a tool that you run directly as a package or install from source; instead, you can simply [follow the docs starting here](https://docs.paperspace.com/gradient/gradient-private-cloud/setup/pre-installation-steps), which will guide you to install a Gradient cluster by using Terraform in conjunction with the base Terraform configuration provided there. That Terraform configuration points to this repo and will thus automatically use this this repo's code as a Terraform module to install your Gradient cluster.

To that end, this repo has been open-sourced so that the inner-workings of the installation process are transparent to anyone who wants to install a Gradient cluster.

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
https://docs.paperspace.com/gradient/gradient-private-cloud/about
