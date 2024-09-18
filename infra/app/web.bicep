param appServiceName string
param location string = resourceGroup().location
param tags object = {}
param appServicePlanName string
param serviceName string = 'app'


module appServicePlan 'appserviceplan.bicep' = {
  name: 'appserviceplan-${serviceName}'
  params: {
    name: appServicePlanName
    location: location
    tags: tags
    sku: {
      name: 'B1'
      capacity: 1
    }
  }
}

module web 'appservice.bicep' = {
  name: 'web-${serviceName}'
  params: {
    name: appServiceName
    location: location
    tags: union(tags, { 'azd-service-name': serviceName })
    appServicePlanId: appServicePlan.outputs.id    
    runtimeName: 'node'
    runtimeVersion: '20-lts'
  }  
}

output uri string = web.outputs.uri
