param connections_servicebus_name string = 'servicebus2'

resource connections_servicebus_name_resource 'Microsoft.Web/connections@2016-06-01' = {
  name: connections_servicebus_name
  location: 'southcentralus'
  kind: 'V1'
  properties: {
    displayName: 'svcbus-conn2'
    statuses: [
      {
        status: 'Connected'
      }
    ]
    customParameterValues: {}
    nonSecretParameterValues: {}
    api: {
      name: connections_servicebus_name
      displayName: 'Service Bus'
      description: 'Connect to Azure Service Bus to send and receive messages. You can perform actions such as send to queue, send to topic, receive from queue, receive from subscription, etc.'
      iconUri: 'https://connectoricons-prod.azureedge.net/releases/v1.0.1518/1.0.1518.2564/${connections_servicebus_name}/icon.png'
      brandColor: '#c4d5ff'
      type: 'Microsoft.Web/locations/managedApis'
    }
    testLinks: []
  }
}
