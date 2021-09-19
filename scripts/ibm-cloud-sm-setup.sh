#!/bin/sh

# IBM Cloud Secrets Manager preparation and configuration
#
# Prepare usage of IBM Cloud Secrets Manager with Kubernetes-External-Secrets
# - ServiceID, API and Secrets
# - Installs/Update kubernetes-external-secrets

# create Service ID and API Key
echo "ServiceID..."
export SERVICE_ID=`ibmcloud iam service-id kubernetes-secrets-demo --output json | jq -r ".[].id"`
if [ -z "${SERVICE_ID}" ]; then
    export SERVICE_ID=`ibmcloud iam service-id-create kubernetes-secrets-demo --description "A service ID for testing Secrets Manager and Kubernetes Service." --output json | jq -r ".id"`; echo "ServiceID: $SERVICE_ID"
    ibmcloud iam service-policy-create $SERVICE_ID --roles "SecretsReader" --service-name secrets-manager
else 
    echo "...found: ServiceID: $SERVICE_ID"
fi

echo "API Key..."
export IBM_CLOUD_API_KEY=`ibmcloud iam service-api-key-create kubernetes-secrets-demo $SERVICE_ID --description "An API key for testing Secrets Manager." --output json | jq -r ".apikey"`

# Prepare Secrets Manager with secret group and dummy secret
echo "SecretsManagerUrl..."
export SECRETS_MANAGER_URL=`ibmcloud resource service-instance secrets-manager --output json | jq -r '.[].dashboard_url | .[0:-3]'`; echo "SecretsManagerUrl: $SECRETS_MANAGER_URL"

echo "SecretGroup..."
export SECRET_GROUP_ID=`ibmcloud secrets-manager secret-groups --output json | jq '.resources[] | select(.name=="sg-demo") | .id'`
if [ -z "${SECRET_GROUP_ID}" ]; then
    export SECRET_GROUP_ID=`ibmcloud secrets-manager secret-group-create --resources '[{"name":"sg-demo","description":"Demo App and Secrets."}]' --output json | jq -r ".resources[].id"`; echo "SecretGroupId: $SECRET_GROUP_ID"
else 
    echo "...found: SecretGroupId: $SECRET_GROUP_ID"
fi

echo "Secret..."
export SECRET_ID=`ibmcloud secrets-manager secrets --secret-type username_password --output json | jq '.resources[] | select(.name=="demo-creds-01") | .id'`
if [ -z "${SECRET_ID}" ]; then
    export SECRET_ID=`ibmcloud secrets-manager secret-create --secret-type username_password  --resources '[{"name":"demo-creds-01","description":"Demo Credential - 01.","secret_group_id":"'"$SECRET_GROUP_ID"'","username":"aUser03","password":"mega-important-2009-sunny-day","labels":["env:nonprod","stage:demo"]}]' --output json | jq -r ".resources[].id"`; echo "SecretId: $SECRET_ID"
else 
    echo "...found: SecretId: $SECRET_ID"
fi

# Create Secret with API Key, URL and type
kubectl -n default delete secret secret-api-key
kubectl -n default create secret generic secret-api-key --from-literal=apikey=$IBM_CLOUD_API_KEY

kubectl -n default delete secret ibmcloud-credentials
kubectl -n default create secret generic ibmcloud-credentials --from-literal=apikey=$IBM_CLOUD_API_KEY \
--from-literal=endpoint=$SECRETS_MANAGER_URL \
--from-literal=authtype=iam


# Install Kubernetes-External-Secrets
helm3 repo add external-secrets https://external-secrets.github.io/kubernetes-external-secrets/
#helm3 install kubernetes-external-secrets external-secrets/kubernetes-external-secrets -f kes-ibm-cloud-sm-values.yaml -n default
helm3 upgrade --install kubernetes-external-secrets external-secrets/kubernetes-external-secrets -f kes-ibm-cloud-sm-values.yaml -n default
