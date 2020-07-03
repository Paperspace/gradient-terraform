terraform {
    backend "s3" {
        bucket = "gradient-managed-ps-cloud"
        key    = "gradient-processing-ps-cloud-managed"
        region = "us-east-1"
    }
}
