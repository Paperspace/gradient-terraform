global:
  amqpExchange: ${cluster_handle}

  artifactsPath: ${artifacts_path}
  cluster:
    handle: ${cluster_handle}
    name: ${name}
  %{ if elastic_search_enabled }
  elasticSearch:
    host: ${elastic_search_host}
    index: ${elastic_search_index}
    port: ${elastic_search_port}
    user: ${elastic_search_user}
  %{ endif }
  logsHost: ${logs_host}
  ingressHost: ${domain}
  serviceNodeSelector:
    paperspace.com/pool-name: ${service_pool_name}

  defaultStorageName: ${default_storage_name}
  sharedStorageName: ${shared_storage_name}
  storage:
    gradient-processing-local:
      class: gradient-processing-local
      path: ${local_storage_path}
      server: ${local_storage_server}
      type: ${local_storage_type}
    gradient-processing-shared:
      class: gradient-processing-shared
      path: ${shared_storage_path}
      server: ${shared_storage_server}
      type: ${shared_storage_type}

cluster-autoscaler:
  enabled: ${cluster_autoscaler_enabled}

  awsRegion: ${aws_region}
  autoDiscovery:
    clusterName: ${name}
  nodeSelector:
    paperspace.com/pool-name: ${service_pool_name}

efs-provisioner:
  enabled: ${efs_provisioner_enabled}
  efsProvisioner:
    awsRegion: ${aws_region}
    efsFileSystemId: "${split(".", shared_storage_server)[0]}"
    path: ${shared_storage_path}
  nodeSelector:
    paperspace.com/pool-name: ${service_pool_name}

fluent-bit:
  rawConfig: |-
    # used to trigger changes
    ${elastic_search_sha}

gradient-operator:
  config:
    ingressHost: ${domain}
    usePodAntiAffinity: ${use_pod_anti_affinity}
    %{ if label_selector_cpu != "" && label_selector_gpu != "" }
    modelDeploymentConfig:
      labelName: paperspace.com/pool-name
      cpu:
        small:
          label: ${label_selector_cpu}
        medium:
          label: ${label_selector_cpu}
        large:
          label: ${label_selector_cpu}
      gpu:
        small:
          label: ${label_selector_gpu}
          requests:
            memory: 5Gi
        medium:
          label: ${label_selector_gpu}
          requests:
            memory: 20Gi
        large:
          label: ${label_selector_gpu}
          requests:
            memory: 58Gi

    experimentConfig:
      labelName: paperspace.com/pool-name
      cpu:
        small:
          label: ${label_selector_cpu}
        medium:
          label: ${label_selector_cpu}
        large:
          label: ${label_selector_cpu}
      gpu:
        small:
          label: ${label_selector_gpu}
          requests:
            memory: 5Gi
        medium:
          label: ${label_selector_gpu}
          requests:
            memory: 20Gi
        large:
          label: ${label_selector_gpu}
          requests:
            memory: 58Gi
    notebookConfig:
      labelName: paperspace.com/pool-name
      cpu:
        small:
          label: ${label_selector_cpu}
        medium:
          label: ${label_selector_cpu}
        large:
          label: ${label_selector_cpu}
      gpu:
        small:
          label: ${label_selector_gpu}
          requests:
            memory: 5Gi
        medium:
          label: ${label_selector_gpu}
          requests:
            memory: 20Gi
        large:
          label: ${label_selector_gpu}
          requests:
            memory: 58Gi
    tensorboardConfig:
      labelName: paperspace.com/pool-name
      cpu:
        small:
          label: ${label_selector_cpu}
        medium:
          label: ${label_selector_cpu}
        large:
          label: ${label_selector_cpu}
      gpu:
        small:
          label: ${label_selector_gpu}
          requests:
            memory: 5Gi
        medium:
          label: ${label_selector_gpu}
          requests:
            memory: 20Gi
        large:
          label: ${label_selector_gpu}
          requests:
            memory: 58Gi
    %{ endif }

gradient-metrics:
  ingress:
    hostPath:
      ${domain}: /metrics

gradient-operator-dispatcher:
  config:
    sentryEnvironment: ${name}
    sentryDSN: ${sentry_dsn}

nfs-client-provisioner:
  enabled: ${nfs_client_provisioner_enabled}
  nfs:
    path: ${shared_storage_path}
    server: ${shared_storage_server}
  nodeSelector:
    paperspace.com/pool-name: ${service_pool_name}

prometheus:
  nodeSelector:
    paperspace.com/pool-name: ${service_pool_name}
  server:
    ingress:
      hosts:
        - ${domain}/prometheus
  kube-state-metrics:
    nodeSelector:
      paperspace.com/pool-name: ${service_pool_name}

prom-aggregation-gateway:
  ingress:
    hostPath:
      ${domain}: /gateway

traefik:
  replicas: 1
  nodeSelector:
    paperspace.com/pool-name: ${service_pool_name}

  %{ if label_selector_cpu != "" && label_selector_gpu != "" }
  serviceType: NodePort
  deploymentStrategy:
    type: Recreate
  deployment:
    hostNetwork: true
    hostPort:
      httpEnabled: true
      httpPort: 80
      httpsEnabled: true
      httpsPort: 443
  %{ endif }

  %{ if letsencrypt_enabled }
  acme:
    enabled: true
    email: "admin@${domain}"
    onHostRule: true
    staging: false
    logging: true
    domains:
      enabled: true
      domainsList:
        - main: "*.${domain}"
        - sans: 
          - ${domain}
    challengeType: dns-01
    resolvers:
      - 8.8.8.8:53
    persistence:
      storageClass: ${shared_storage_name}
  %{ endif }