#!/bin/sh

# Add policies for the examples


oc exec -ti hashicorp-vault-0 -- /bin/sh <<EOF

echo 'path "secret/data/dev/system-a" {  
  capabilities = ["list", "read"]
}' > /tmp/system-a.hcl  

vault policy write system-a-dev /tmp/system-a.hcl

echo 'path "secret/data/dev/system-b" {  
  capabilities = ["list", "read"]
}' > /tmp/system-b.hcl

vault policy write system-b-dev /tmp/system-b.hcl

EOF