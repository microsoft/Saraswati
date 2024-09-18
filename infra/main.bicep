targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
@allowed(['westus2', 'westeurope', 'southeastasia'])
param location string

// param appServicePlanName string = ''
// param backendServiceName string = ''
param resourceGroupName string = ''

//param searchServiceName string = ''
//param searchServiceResourceGroupName string = ''
//param searchServiceResourceGroupLocation string = location
//param searchServiceSkuName string = ''

param openAiResourceName string = ''
param openAiResourceGroupName string = ''
param openAiResourceGroupLocation string = 'westus'
//param formRecognizerServiceName string = ''
//param formRecognizerResourceGroupName string = ''
//param formRecognizerResourceGroupLocation string = location
//param formRecognizerSkuName string = 'S0'
param openAiSkuName string = 'S0'

@description('Name of the chat completion model deployment')
param chatDeploymentName string = 'chat'

@description('Name of the chat completion model')
param chatModelName string = 'gpt-4o'
param chatModelVersion string = '2024-05-13'


// @description('Name of the storage account')
// param storageAccountName string = ''

// @description('Name of the storage container. Default: content')
// param storageContainerName string = 'notes'

// @description('Location of the resource group for the storage account')
// param storageResourceGroupLocation string = location

// @description('Name of the resource group for the storage account')
// param storageResourceGroupName string = ''


// @description('Id of the user or app to assign application roles')
// param principalId string = ''


var abbrs = loadJsonContent('abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = { 'azd-env-name': environmentName }

// Organize resources in a resource group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

resource openAiResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = if (!empty(openAiResourceGroupName)) {
  name: !empty(openAiResourceGroupName) ? openAiResourceGroupName : resourceGroup.name
}

// resource searchServiceResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = if (!empty(searchServiceResourceGroupName)) {
//   name: !empty(searchServiceResourceGroupName) ? searchServiceResourceGroupName : resourceGroup.name
// }


module openAi 'ai/cognitiveservices.bicep' = {
  name: 'openai'
  scope: openAiResourceGroup
  params: {
    name: !empty(openAiResourceName) ? openAiResourceName : '${abbrs.cognitiveServicesAccounts}${resourceToken}'
    location: openAiResourceGroupLocation
    tags: tags
    sku: {
      name: !empty(openAiSkuName) ? openAiSkuName : 'S0'
    }
    deployments: [
      {
        name: chatDeploymentName
        model: {
          format: 'OpenAI'
          name: chatModelName
          version: chatModelVersion
        }
        capacity: 30
      }
    ]
  }
}

var appServiceName = '${abbrs.webSitesAppService}frontend-${resourceToken}'

module web 'app/web.bicep' = {
  name: 'web'
  scope: resourceGroup
  params: {
    location: location
    tags: tags
    appServicePlanName: '${abbrs.webServerFarms}frontend-${resourceToken}'
    appServiceName: appServiceName
  }
}


// module searchService 'search/search-services.bicep' = {
//   name: 'search-service'
//   scope: searchServiceResourceGroup
//   params: {
//     name: !empty(searchServiceName) ? searchServiceName : 'gptkb-${resourceToken}'
//     location: searchServiceResourceGroupLocation
//     tags: tags
//     authOptions: {
//       aadOrApiKey: {
//         aadAuthFailureMode: 'http401WithBearerChallenge'
//       }
//     }
//     sku: {
//       name: !empty(searchServiceSkuName) ? searchServiceSkuName : 'standard'
//     }
//     semanticSearch: 'free'
//   }
// }


// USER ROLES
// module openAiRoleUser 'core/security/role.bicep' = {
//   scope: openAiResourceGroup
//   name: 'openai-role-user'
//   params: {
//     principalId: principalId
//     roleDefinitionId: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
//     principalType: 'User'
//   }
// }

// module searchRoleUser 'core/security/role.bicep' = {
//   scope: searchServiceResourceGroup
//   name: 'search-role-user'
//   params: {
//     principalId: principalId
//     roleDefinitionId: '1407120a-92aa-4202-b7e9-c0e197c71c8f'
//     principalType: 'User'
//   }
// }

// module searchIndexDataContribRoleUser 'core/security/role.bicep' = {
//   scope: searchServiceResourceGroup
//   name: 'search-index-data-contrib-role-user'
//   params: {
//     principalId: principalId
//     roleDefinitionId: '8ebe5a00-799e-43f5-93ac-243d3dce84a7'
//     principalType: 'User'
//   }
// }

// module searchServiceContribRoleUser 'core/security/role.bicep' = {
//   scope: searchServiceResourceGroup
//   name: 'search-service-contrib-role-user'
//   params: {
//     principalId: principalId
//     roleDefinitionId: '7ca78c08-252a-4471-8644-bb5ff32d4ba0'
//     principalType: 'User'
//   }
// }

// module cognitiveServicesRoleUser 'core/security/role.bicep' = {
//   scope: formRecognizerResourceGroup
//   name: 'cognitiveservices-role-user'
//   params: {
//     principalId: principalId
//     roleDefinitionId: 'a97b65f3-24c7-4388-baec-2e87135dc908'
//     principalType: 'User'
//   }
// }

// module aiDeveloperRoleUser 'core/security/role.bicep' = {
//   scope: openAiResourceGroup
//   name: 'ai-developer-role-user'
//   params: {
//     principalId: principalId
//     roleDefinitionId: '64702f94-c441-49e6-a78b-ef80e0188fee'
//     principalType: 'User'
//   }
// }

// SYSTEM IDENTITIES
// module storageRoleBackend 'core/security/role.bicep' = {
//   scope: storageResourceGroup
//   name: 'storage-role-backend'
//   params: {
//     principalId: backend.outputs.identityPrincipalId
//     roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
//     principalType: 'ServicePrincipal'
//   }
// }

// module storageRoleFunctionApp 'core/security/role.bicep' = {
//   scope: storageResourceGroup
//   name: 'storage-role-functionapp'
//   params: {
//     principalId: function.outputs.SERVICE_FUNCTION_IDENTITY_PRINCIPAL_ID
//     roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
//     principalType: 'ServicePrincipal'
//   }
// }

// module openAiRoleBackend 'core/security/role.bicep' = {
//   scope: openAiResourceGroup
//   name: 'openai-role-backend'
//   params: {
//     principalId: backend.outputs.identityPrincipalId
//     roleDefinitionId: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
//     principalType: 'ServicePrincipal'
//   }
// }

// module openAiRoleFunctionApp 'core/security/role.bicep' = {
//   scope: openAiResourceGroup
//   name: 'openai-role-functionapp'
//   params: {
//     principalId: function.outputs.SERVICE_FUNCTION_IDENTITY_PRINCIPAL_ID
//     roleDefinitionId: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
//     principalType: 'ServicePrincipal'
//   }
// }

// module searchRoleBackend 'core/security/role.bicep' = {
//   scope: searchServiceResourceGroup
//   name: 'search-role-backend'
//   params: {
//     principalId: backend.outputs.identityPrincipalId
//     roleDefinitionId: '1407120a-92aa-4202-b7e9-c0e197c71c8f'
//     principalType: 'ServicePrincipal'
//   }
// }

// module searchRoleFunctionApp 'core/security/role.bicep' = {
//   scope: searchServiceResourceGroup
//   name: 'search-role-functionapp'
//   params: {
//     principalId: function.outputs.SERVICE_FUNCTION_IDENTITY_PRINCIPAL_ID
//     roleDefinitionId: '1407120a-92aa-4202-b7e9-c0e197c71c8f'
//     principalType: 'ServicePrincipal'
//   }
// }

// module searchServiceContribRoleFunction 'core/security/role.bicep' = {
//   scope: searchServiceResourceGroup
//   name: 'search-service-contrib-role-function'
//   params: {
//     principalId: function.outputs.SERVICE_FUNCTION_IDENTITY_PRINCIPAL_ID
//     roleDefinitionId: '7ca78c08-252a-4471-8644-bb5ff32d4ba0'
//     principalType: 'ServicePrincipal'
//   }
// }

// module searchIndexDataContribRoleFunction 'core/security/role.bicep' = {
//   scope: searchServiceResourceGroup
//   name: 'search-index-data-contrib-role-function'
//   params: {
//     principalId: function.outputs.SERVICE_FUNCTION_IDENTITY_PRINCIPAL_ID
//     roleDefinitionId: '8ebe5a00-799e-43f5-93ac-243d3dce84a7'
//     principalType: 'ServicePrincipal'
//   }
// }

// module cognitiveServicesRoleFunction 'core/security/role.bicep' = {
//   scope: formRecognizerResourceGroup
//   name: 'cognitiveservices-role-function'
//   params: {
//     principalId: function.outputs.SERVICE_FUNCTION_IDENTITY_PRINCIPAL_ID
//     roleDefinitionId: 'a97b65f3-24c7-4388-baec-2e87135dc908'
//     principalType: 'ServicePrincipal'
//   }
// }

// module aiDeveloperRoleBackend 'core/security/role.bicep' = {
//   scope: openAiResourceGroup
//   name: 'ai-developer-role-backend'
//   params: {
//     principalId: backend.outputs.identityPrincipalId
//     roleDefinitionId: '64702f94-c441-49e6-a78b-ef80e0188fee'
//     principalType: 'ServicePrincipal'
//   }
// }

// module aiDeveloperRoleFunction 'core/security/role.bicep' = {
//   scope: openAiResourceGroup
//   name: 'ai-developer-role-function'
//   params: {
//     principalId: function.outputs.SERVICE_FUNCTION_IDENTITY_PRINCIPAL_ID
//     roleDefinitionId: '64702f94-c441-49e6-a78b-ef80e0188fee'
//     principalType: 'ServicePrincipal'
//   }
// }

// module apimApi './app/apim-api.bicep' = if (useAPIM) {
//   name: 'apim-api-deployment'
//   scope: rg
//   params: {
//     name: useAPIM ? apim.outputs.apimServiceName : ''
//     apiName: 'todo-api'
//     apiDisplayName: 'Simple Todo API'
//     apiDescription: 'This is a simple Todo API'
//     apiPath: 'todo'
//     webFrontendUrl: web.outputs.SERVICE_WEB_URI
//     apiBackendUrl: api.outputs.SERVICE_API_URI
//     apiAppName: api.outputs.SERVICE_API_NAME
//   }
// }



output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output AZURE_RESOURCE_GROUP string = resourceGroup.name
output APP_URI string = web.outputs.uri

// search
// output AZURE_SEARCH_INDEX string = '${environmentName}-index'
// output AZURE_SEARCH_SERVICE string = searchService.outputs.name
// output AZURE_SEARCH_SERVICE_RESOURCE_GROUP string = searchServiceResourceGroup.name
// output AZURE_SEARCH_SKU_NAME string = searchService.outputs.skuName
// output AZURE_SEARCH_KEY string = searchService.outputs.adminKey
// output AZURE_SEARCH_SEMANTIC_SEARCH_CONFIG string = '${environmentName}-semantic-config'

// openai
output AZURE_OPENAI_RESOURCE string = openAi.outputs.name
output AZURE_OPENAI_RESOURCE_GROUP string = openAiResourceGroup.name
output AZURE_OPENAI_ENDPOINT string = openAi.outputs.endpoint
output AZURE_OPENAI_CHAT_NAME string = chatDeploymentName
output AZURE_OPENAI_CHAT_MODEL string = chatModelName
output AZURE_OPENAI_SKU_NAME string = openAi.outputs.skuName
output AZURE_OPENAI_KEY string = openAi.outputs.key


//output AUTH_ISSUER_URI string = authIssuerUri
