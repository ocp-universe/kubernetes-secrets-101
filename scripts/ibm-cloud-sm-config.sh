#!/bin/sh

# IBM Cloud Secrets Manager preparation and configuration
#
# Prepare usage of IBM Cloud Secrets Manager with Kubernetes-External-Secrets

# create Service ID and API Key
export SERVICE_ID=`ibmcloud iam service-id-create kubernetes-secrets-tutorial --description "A service ID for testing Secrets Manager and Kubernetes Service." --output json | jq -r ".id"`; echo $SERVICE_ID
ibmcloud iam service-policy-create $SERVICE_ID --roles "SecretsReader" --service-name secrets-manager
export IBM_CLOUD_API_KEY=`ibmcloud iam service-api-key-create kubernetes-secrets-tutorial $SERVICE_ID --description "An API key for testing Secrets Manager." --output json | jq -r ".apikey"`

# Prepare Secrets Manager with secret group and dummy secret
export SECRETS_MANAGER_URL=`ibmcloud resource service-instance my-secrets-manager --output json | jq -r '.[].dashboard_url | .[0:-3]'`; echo $SECRETS_MANAGER_URL

export SECRET_GROUP_ID=`ibmcloud secrets-manager secret-group-create --resources '[{"name":"sg-demo","description":"Demo App and Secrets."}]' --output json | jq -r ".resources[].id"`; echo $SECRET_GROUP_ID

export SECRET_ID=`ibmcloud secrets-manager secret-create --secret-type username_password  --resources '[{"name":"example_username_password","description":"Extended description for my secret.","secret_group_id":"'"$SECRET_GROUP_ID"'","username":"user123","password":"cloudy-rainy-coffee-book","labels":["env-demo","demo"]}]' --output json | jq -r ".resources[].id"`; echo $SECRET_ID

# Create Secret with API Key, URL and type
kubectl -n default create secret generic secret-api-key --from-literal=apikey=$IBM_CLOUD_API_KEY

kubectl -n default create secret generic ibmcloud-credentials --from-literal=apikey=$IBM_CLOUD_API_KEY \
--from-literal=endpoint=$SECRETS_MANAGER_URL \
--from-literal=authtype=iam


# Install Kubernetes-External-Secrets
helm3 repo add external-secrets https://external-secrets.github.io/kubernetes-external-secrets/
helm3 install kubernetes-external-secrets external-secrets/kubernetes-external-secrets -f kes-ibm-cloud-sm-values.yaml
