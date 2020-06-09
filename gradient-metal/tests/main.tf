module "gradient_metal" {
    source = "../"

    name = "cluster-name"
    artifacts_access_key_id = "artifacts-access-key-id"
    artifacts_path = "s3://artifacts-bucket"
    artifacts_secret_access_key = "artifacts-secret-access-key"
    
    cluster_apikey = "cluster-apikey-from-paperspace-com"
    cluster_handle = "cluster-handle-from-paperspace-com"
    domain = "gradient.mycompany.com"

    k8s_master_node = {
        ip = "master_ip1"
        internal-address = "internal_master_ip1"
        pool-type = "cpu"
        pool-name = "metal-cpu"
    }

    k8s_workers = [
        {
            ip = "worker_ip1"
            internal-address = "internal_ip1"
            pool-type = "gpu"
            pool-name = "metal-gpu"
        },
        {
            ip = "worker_ip2"
            internal-address = "internal_ip2"
            pool-type = "cpu"
            pool-name = "metal-cpu"
        }
    ]

    shared_storage_path = "/srv/gradient"
    shared_storage_server = "shared-nfs-storage.com"
    ssh_key_path = "gradient_rsa"
    ssh_user = "ubuntu"

    tls_cert = ""
    tls_key = ""
}
