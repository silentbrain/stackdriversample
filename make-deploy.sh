#!/bin/bash
echo "Generating deploy.yaml"
echo "======================"
cat <<EOF > /deploy/deploy.yaml
steps:
- name: 'gcr.io/cloud-builders/gcloud'
  entrypoint: 'bash'
  args:
    - '-c'
    - |
      mkdir /builder/home/.ssh
      ssh-keygen -t rsa -f /builder/home/.ssh/google_compute_engine
  id: 'init-ssh'
EOF

while IFS=',' read INSTANCE_NAME ZONE STATUS; 
do
 cat <<EOF >> /deploy/deploy.yaml

- name: 'gcr.io/cloud-builders/gcloud'
  args: ['compute', 'ssh', 'pping@${INSTANCE_NAME}', '--zone', '${ZONE}', '--tunnel-through-iap', '--ssh-flag', '-p 10022', '--command', 'gsutil -m cp -r gs://kty-test1/git gs://kty-test1/after.sh /hosting/pping/ && sh /hosting/pping/after.sh']
  id : 'deploy-${INSTANCE_NAME}'
  waitFor: ['init-ssh']
EOF
done < /deploy/list.csv