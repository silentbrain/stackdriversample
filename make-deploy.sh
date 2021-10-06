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
      echo "================================"
      echo "Triggered by \${_TRIGGER_BUILD}"
      echo "Repository : \${_TRIGGER_REPO}"
      echo "Commit : \${_TRIGGER_COMMIT}"
      echo "================================"
      mkdir /builder/home/.ssh
      ssh-keygen -t rsa -f /builder/home/.ssh/google_compute_engine
  id: 'init-ssh'
EOF

while IFS=',' read INSTANCE_NAME ZONE STATUS; 
do
 cat <<EOF >> /deploy/deploy.yaml

- name: 'gcr.io/cloud-builders/gcloud'
  args: ['compute', 'ssh', 'pping@${INSTANCE_NAME}', '--zone', '${ZONE}', '--tunnel-through-iap', '--ssh-flag', '-p 10022', '--command', 'rm -rf \${_LOCAL_PATH}/* && gsutil -m cp -r \${_GIT_BUCKET}/* \${_SCRIPT_BUCKET}/\${_SCRIPT_FILE} \${_LOCAL_PATH}/ && sh \${_LOCAL_PATH}/\${_SCRIPT_FILE}']
  id : 'deploy-${INSTANCE_NAME}'
  waitFor: ['init-ssh']
EOF
done < /deploy/list.csv