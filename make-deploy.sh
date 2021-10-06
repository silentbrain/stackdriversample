#!/bin/bash
echo "Generating deploy.yaml"
while IFS=',' read INSTANCE_NAME ZONE STATUS; 
do
 cat <<EOF > /deploy/deploy.yaml
step:
- name: 'gcr.io/cloud-builders/gcloud'
  args: ['compute', 'ssh', 'pping@${INSTANCE_NAME}', '--zone', '${ZONE}', '--tunnel-through-iap', '--ssh-flag', '-p 10022', '--command', 'hostname']
  waitFor: ['init-ssh']
  id : 'deploy-${INSTANCE_NAME}'
EOF
done < /deploy/list.csv