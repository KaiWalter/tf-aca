@minLength(1)
@maxLength(64)
@description('Name of the environment (which is used to generate a short unqiue hash used in all resources).')
param envName string

@minLength(1)
@maxLength(64)
@description('Name of the container app.')
param appName string

@minLength(1)
@description('Primary location for all resources')
param location string

param acaName string
param acrName string

param imageName string
param acrPullId string

var resourceToken = toLower(uniqueString(subscription().id, envName, location))
var tags = {
  'azd-env-name': envName
}

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: acaName
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' existing = {
  name: acrName
}

resource capp 'Microsoft.App/containerApps@2022-03-01' = {
  name: appName
  location: location
  tags: union(tags, {
      'azd-service-name': appName
    })
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${acrPullId}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppsEnvironment.id
    configuration: {
      activeRevisionsMode: 'single'
      ingress: {
        external: true
        targetPort: 80
        transport: 'auto'
      }
      registries: [
        {
          server: containerRegistry.properties.loginServer
          identity: acrPullId
        }
      ]
      dapr: {
        enabled: true
        appId: appName
        appPort: 80
        appProtocol: 'http'
      }
    }
    template: {
      containers: [
        {
          image: imageName
          name: appName
          probes: [
            {
              type: 'Liveness'
              httpGet: {
                port: 80
                path: 'health'
              }
            }
            {
              type: 'Readiness'
              httpGet: {
                port: 80
                path: 'health'
              }
            }
          ]
          resources: {
            cpu: '0.25'
            memory: '0.5Gi'
          }
        }
      ]
    }
  }
}