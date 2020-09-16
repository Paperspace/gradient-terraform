module "gradient" {
    source = "../"

    name = "cluster-name"
    artifacts_access_key_id = "artifacts-access-key-id"
    artifacts_path = "s3://artifacts-bucket"
    artifacts_secret_access_key = "artifacts-secret-access-key"
    
    cluster_apikey = "cluster-apikey-from-paperspace-com"
    cluster_handle = "cluster-handle-from-paperspace-com"
    domain = "gradient.mycompany.com"

    tls_cert = ""
    tls_key = ""

    admin_email = "engineering@paperspace.com"
    admin_user_api_key = "test"
    rancher_api_url = "https://rancher.paperspace.io"
    rancher_access_key = "accesskey"
    rancher_secret_key = "secretkey"
    team_id = "teamhandle"
    team_id_integer = 23
}