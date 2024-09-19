
@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the API Management service instance')
param apimServiceName string = 'KRmyApimService212133212311212323132'

@description('The SKU of the API Management service.')
param skuName string = 'Developer'

@description('Endpoint of the Azure OpenAI Service')
param openAiEndpoint string = 'https://contoso.openai.azure.com'
//'https://<your-openai-service>.openai.azure.com'

@description('Endpoint of the Azure AI Speach Service ')
param speechEndpoint string = 'https://contoso.tts.speech.microsoft.com'
//'https://<your-cognitive-search-service>.search.windows.net'

@description('Publisher email address.')
param apimPublisherEmail string = 'admin@contoso.com'

@description('Publisher name.')
param apimPublisherName string = 'Contoso'

@description('Websocket location for speech to text')
param sttSocketEndpoint string = 'wss://westus2.stt.speech.microsoft.com'
//wss://cotoso.cognitiveservices.azure.com/

@description('Websocket location for text to speech')
param ttsSocketEndpoint string = 'wss://westus2.voice.speech.microsoft.com'

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

resource speech_to_text_websocket 'Microsoft.ApiManagement/service/apis@2022-08-01' = {
  parent: apim
  name: 'stt_socket'
  properties: {
    displayName: 'stt_socket'
    subscriptionRequired: true
    path: 'stt_socket'
    type: 'websocket'
    serviceUrl: sttSocketEndpoint
    protocols: [
      'wss'
    ]
    subscriptionKeyParameterNames: {
      header: 'Ocp-Apim-Subscription-Key'
      query: 'Ocp-Apim-Subscription-Key'
    }
  }
}

resource text_to_speech_websocket 'Microsoft.ApiManagement/service/apis@2022-08-01' = {
  parent: apim
  name: 'tts_socket'
  properties: {
    displayName: 'tts_socket'
    subscriptionRequired: true
    path: 'tts_socket'
    type: 'websocket'
    serviceUrl: ttsSocketEndpoint
    protocols: [
      'wss'
    ]
    subscriptionKeyParameterNames: {
      header: 'Ocp-Apim-Subscription-Key'
      query: 'Ocp-Apim-Subscription-Key'
    }
  }
}

resource cognitiveSearchApi 'Microsoft.ApiManagement/service/apis@2022-08-01' = {
  parent: apim
  name: 'speech'
  properties: {
    displayName: 'speech'
    serviceUrl: speechEndpoint
    subscriptionRequired: true
    path: 'speech'
    protocols: [
      'https'
    ]
    subscriptionKeyParameterNames: {
      header: 'Ocp-Apim-Subscription-Key'
      query: 'Ocp-Apim-Subscription-Key'
    }
  }
}

resource openAiApi 'Microsoft.ApiManagement/service/apis@2022-08-01' = {
  parent: apim
  name: 'azureOpenAiApi'
  properties: {
    displayName: 'aoai'
    serviceUrl: openAiEndpoint
    subscriptionRequired: true
    path: 'aoai/openai'
    protocols: [
      'https'
    ]
    subscriptionKeyParameterNames: {
      header: 'api-key'
      query: 'api-key'
    }
  }
}


output apimName string = apim.name

//az deployment group create --resource-group test --template-file APIMDeployment.bicep
