
@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the API Management service instance')
param apimServiceName string = 'KRmyApimService212133212311212323132'

@description('The SKU of the API Management service.')
param skuName string = 'Developer'

@description('Endpoint of the Azure OpenAI Service')
param openAiEndpoint string = 'https://contoso.openai.azure.com'
//'https://<your-openai-service>.openai.azure.com'

@description('Endpoint of the Azure AI Search Service ')
param searchEndpoint string = 'https://contoso.search.windows.net'
//'https://<your-cognitive-search-service>.search.windows.net'

@description('Publisher email address.')
param apimPublisherEmail string = 'admin@contoso.com'

@description('Publisher name.')
param apimPublisherName string = 'Contoso'

@description('Websocket location for speech service')
param webSocketEndpoint string = 'wss://sddssdffds.cognitiveservices.azure.com'
//wss://cotoso.cognitiveservices.azure.com/

resource apim 'Microsoft.ApiManagement/service@2021-08-01' = {
  name: apimServiceName
  location: location
  sku: {
    name: skuName
    capacity: 1
  }
  properties: {
    publisherEmail: apimPublisherEmail
    publisherName: apimPublisherName
  }
}

resource speech_to_text_websocket 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  parent: apim
  name: 'speech_to_text_websocket'
  properties: {
    displayName: 'STT WebSocket'
    path: 'sttsocket'
    type: 'websocket'
    serviceUrl: webSocketEndpoint
    protocols: [
      'wss'
    ]
  }
}

resource text_to_speech_websocket 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  parent: apim
  name: 'text_to_speech_websocket'
  properties: {
    displayName: 'TTS WebSocket'
    path: 'ttssocket'
    type: 'websocket'
    serviceUrl: webSocketEndpoint
    protocols: [
      'wss'
    ]
  }
}

resource cognitiveSearchApi 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  parent: apim
  name: 'cognitiveSearchApi'
  properties: {
    displayName: 'Cognitive Search API'
    serviceUrl: searchEndpoint
    path: 'cognitive-search'
    protocols: [
      'https'
    ]
  }
}

resource openAiApi 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  parent: apim
  name: 'azureOpenAiApi'
  properties: {
    displayName: 'Azure OpenAI API'
    serviceUrl: openAiEndpoint
    path: 'aoai'
    protocols: [
      'https'
    ]
  }
}


output apimName string = apim.name

//az deployment group create --resource-group test --template-file APIMDeployment.bicep
