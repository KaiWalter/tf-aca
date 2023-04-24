#!/bin/bash

set -e

RESOURCE_GROUP_NAME=tfstate
CONTAINER_NAME=tf-aca

if [ -z "$1" ]
then
    LOCATION=eastus
else
    LOCATION=$1
fi

# Create resource group, if not present
if [ $(az group exists --name $RESOURCE_GROUP_NAME) = false ]; then
    az group create --name $RESOURCE_GROUP_NAME --location $LOCATION
fi

EXISTING_STORAGE_ACCOUNT_NAME=`az storage account list -g $RESOURCE_GROUP_NAME --query "[0].name" -o tsv`

if [ -z $EXISTING_STORAGE_ACCOUNT_NAME ]; 
then
    # Create storage account
    STORAGE_ACCOUNT_NAME=tfstate$RANDOM
    az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob
else
    # Re-use existing storage account
    STORAGE_ACCOUNT_NAME=$EXISTING_STORAGE_ACCOUNT_NAME
fi

if [ -z $(az storage container list --account-name $STORAGE_ACCOUNT_NAME --auth-mode login --query "[?name=='$CONTAINER_NAME'].name" -o tsv) ];
then
    # Create blob container
    az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME
fi

azd env set RS_STORAGE_ACCOUNT $STORAGE_ACCOUNT_NAME
azd env set RS_CONTAINER_NAME $CONTAINER_NAME
azd env set RS_RESOURCE_GROUP $RESOURCE_GROUP_NAME
