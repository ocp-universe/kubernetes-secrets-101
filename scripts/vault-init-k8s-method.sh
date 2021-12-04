#!/bin/sh

# Initialize HashiCorp Vault with Kubernetes Auth method


oc exec -ti hashicorp-vault-0 -- /bin/sh <<EOF

vault auth enable kubernetes


vault write auth/kubernetes/config \
  token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  kubernetes_host="https://\$KUBERNETES_PORT_443_TCP_ADDR:443" \
  kubernetes_ca_cert=\@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

vault write auth/kubernetes/role/role-system-a-dev \
    bound_service_account_names=sa-system-a-dev \
    bound_service_account_namespaces=vault-test1,test,vault-test3 \
    policies=system-a-dev \
    ttl=1h

vault write auth/kubernetes/role/role-system-b-dev \
    bound_service_account_names=sa-system-b-dev \
    bound_service_account_namespaces=vault-test2,test \
    policies=system-b-dev \
    ttl=1h
EOF