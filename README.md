# Deploy Azure Container Apps with Terraform

## getting start

1. initialize Developer CLI with `azd init`
1. read values from **azd environment** `source <(azd env get-values)`
1. initialize Terraform state storage with `scripts/az-tfstate.sh $AZURE_LOCATION`;<br/>note that `infra/provider.conf.json` is configured to reference remote state environment variables `RS_STORAGE_ACCOUNT`, `RS_CONTAINER_NAME` and `RS_RESOURCE_GROUP` set in this shell script
1. set infra/main.tfvars.json

```json
{
    "location": "${AZURE_LOCATION}",
    "environment_name": "${AZURE_ENV_NAME}",
    "resource_prefix": "{your-resource-prefix}",
    "purge_protection_enabled": false,
    "secretstore_admins": [
        "{object-id-of-additional-keyvault-admin}"
    ]
}
```

- `{your-resource-prefix}` is the prefix all resources created get e.g. `tfaca`
- `{object-id-of-additional-keyvault-admin}` is the AAD object ID of additional users or service principals needing adminstration access to Key Vault created

5. bring up environment with `azd up`

----

## links

- <https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/use-terraform-for-azd>
- <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app>
- <https://github.com/Azure/azure-dev>
- <https://github.com/Azure/azure-dev/discussions>


----

## Helpers

### remove all Container Apps prior to `terraform destroy`

```shell
az containerapp delete --id $(az containerapp list -o tsv -g {resourceGroup} --query "[].id") -y
```
