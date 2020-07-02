terraform {
    backend "s3" {
        bucket = "managed-gradient-ps-cloud"
        key    = "gradient-processing-ps-cloud-managed"
        region = "us-east-1"
    }
}
