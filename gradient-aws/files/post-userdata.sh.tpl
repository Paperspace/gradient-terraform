%{ if enable_gcr_mirror }
cat << EOF > /etc/docker/daemon.json
{
  "bridge": "none",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "10"
  },
  "live-restore": true,
  "max-concurrent-downloads": 10,
  "registry-mirrors": ["https://mirror.gcr.io"]
}
EOF

service docker reload
%{ endif }