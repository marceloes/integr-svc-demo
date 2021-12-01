param service_marcelos_apim1_name string = 'marcelos-apim1'

resource service_marcelos_apim1_name_resource 'Microsoft.ApiManagement/service@2021-04-01-preview' existing = {
  name: service_marcelos_apim1_name
}

resource service_marcelos_apim1_name_create_incident 'Microsoft.ApiManagement/service/apis@2021-04-01-preview' = {
  parent: service_marcelos_apim1_name_resource
  name: 'create-incident'
  properties: {
    displayName: 'Create Incident'
    apiRevision: '1'
    description: 'Azure Logic App.'
    subscriptionRequired: true
    serviceUrl: 'https://prod-18.northcentralus.logic.azure.com/workflows/655fefe26d9c4bd8b6dc44ddfd071585/triggers'
    path: 'create-incident'
    protocols: [
      'https'
    ]
    isCurrent: true
  }
}

resource service_marcelos_apim1_name_create_incident_manual_invoke 'Microsoft.ApiManagement/service/apis/operations@2021-04-01-preview' = {
  parent: service_marcelos_apim1_name_create_incident
  name: 'manual-invoke'
  properties: {
    displayName: 'manual-invoke'
    method: 'POST'
    urlTemplate: '/manual/paths/invoke'
    templateParameters: []
    description: 'Trigger a run of the logic app.'
    request: {
      description: 'The request body.'
      queryParameters: []
      headers: []
      representations: [
        {
          contentType: 'application/json'
          examples: {
            default: {
              value: {}
            }
          }
          schemaId: '6193efc2fb42681b84210fd9'
          typeName: 'request-manual'
        }
      ]
    }
    responses: [
      {
        statusCode: 201
        description: 'The Logic App Response.'
        representations: [
          {
            contentType: 'application/json'
            examples: {
              default: {
                value: {}
              }
            }
            schemaId: '6193efc2fb42681b84210fd9'
          }
        ]
        headers: []
      }
      {
        statusCode: 500
        description: 'The Logic App Response.'
        representations: [
          {
            contentType: 'application/json'
            examples: {
              default: {
                value: {}
              }
            }
            schemaId: '6193efc2fb42681b84210fd9'
          }
        ]
        headers: []
      }
    ]
  }
  dependsOn: [
    service_marcelos_apim1_name_resource
  ]
}

resource service_marcelos_apim1_name_create_incident_policy 'Microsoft.ApiManagement/service/apis/policies@2021-04-01-preview' = {
  parent: service_marcelos_apim1_name_create_incident
  name: 'policy'
  properties: {
    value: '<policies>\r\n  <inbound>\r\n    <base />\r\n    <set-backend-service id="apim-generated-policy" backend-id="LogicApp_logic-app-1_apim-demo-rg_697585584e1941c9add54f6028ef4956" />\r\n  </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n  <on-error>\r\n    <base />\r\n  </on-error>\r\n</policies>'
    format: 'xml'
  }
  dependsOn: [
    service_marcelos_apim1_name_resource
  ]
}

resource service_marcelos_apim1_name_create_incident_6193efc2fb42681b84210fd9 'Microsoft.ApiManagement/service/apis/schemas@2021-04-01-preview' = {
  parent: service_marcelos_apim1_name_create_incident
  name: '6193efc2fb42681b84210fd9'
  properties: {
    contentType: 'application/vnd.ms-azure-apim.swagger.definitions+json'
    document: {
      definitions: {}
    }
  }
  dependsOn: [
    service_marcelos_apim1_name_resource
  ]
}

resource service_marcelos_apim1_name_create_incident_manual_invoke_policy 'Microsoft.ApiManagement/service/apis/operations/policies@2021-04-01-preview' = {
  parent: service_marcelos_apim1_name_create_incident_manual_invoke
  name: 'policy'
  properties: {
    value: '<policies>\r\n  <inbound>\r\n    <base />\r\n    <set-method id="apim-generated-policy">POST</set-method>\r\n    <rewrite-uri id="apim-generated-policy" template="/manual/paths/invoke/?api-version=2016-06-01&amp;sp=/triggers/manual/run&amp;sv=1.0&amp;sig={{create-incident_manual-invoke_6193efd448518239bae752d1}}" />\r\n    <set-header id="apim-generated-policy" name="Ocp-Apim-Subscription-Key" exists-action="delete" />\r\n  </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n  <on-error>\r\n    <base />\r\n  </on-error>\r\n</policies>'
    format: 'xml'
  }
  dependsOn: [
    service_marcelos_apim1_name_create_incident
    service_marcelos_apim1_name_resource
  ]
}
