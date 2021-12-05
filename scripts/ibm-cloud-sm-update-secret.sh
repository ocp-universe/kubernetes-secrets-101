#!/bin/sh

# IBM Cloud Secrets Manager - update an existing secret

SECRET_ID=$1

currentDate=`date '+%Y-%m-%d_%H:%M:%S'`

export SECRETS_MANAGER_URL=`ibmcloud resource service-instance secrets-manager --output json | jq -r '.[].dashboard_url | .[0:-3]'`; echo $SECRETS_MANAGER_URL

ibmcloud secrets-manager secret-update --secret-type username_password --action rotate --id $SECRET_ID --body '{"password": "mega-important-'${currentDate}'"}'


