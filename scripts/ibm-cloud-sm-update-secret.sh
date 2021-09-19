#!/bin/sh

# IBM Cloud Secrets Manager - update an existing secret

SECRET_ID=$1

currentDate=`date '+%Y-%m-%d_%H:%M:%S'`
ibmcloud secrets-manager secret-update --secret-type username_password --action rotate --id $SECRET_ID --body '{"password": "mega-important-${currentDate}"}'


