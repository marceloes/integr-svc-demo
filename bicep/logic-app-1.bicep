param workflows_logic_app_1_name string = 'logic-app-1'
param connections_service_now_externalid string = '/subscriptions/69758558-4e19-41c9-add5-4f6028ef4956/resourceGroups/apim-demo-rg/providers/Microsoft.Web/connections/service-now'

resource workflows_logic_app_1_name_resource 'Microsoft.Logic/workflows@2017-07-01' = {
  name: workflows_logic_app_1_name
  location: 'northcentralus'
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {}
          type: 'Object'
        }
      }
      triggers: {
        manual: {
          type: 'Request'
          kind: 'Http'
          inputs: {
            method: 'POST'
            schema: {
              properties: {
                comments: {
                  type: 'string'
                }
                'short description': {
                  type: 'string'
                }
                urgency: {
                  type: 'string'
                }
              }
              type: 'object'
            }
          }
        }
      }
      actions: {
        Create_Record: {
          runAfter: {}
          type: 'ApiConnection'
          inputs: {
            body: {
              comments: '@{triggerBody()?[\'comments\']} - Sent from APIM'
              short_description: '@triggerBody()?[\'short description\']'
              urgency: '@triggerBody()?[\'urgency\']'
            }
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'service-now\'][\'connectionId\']'
              }
            }
            method: 'post'
            path: '/api/now/v2/table/@{encodeURIComponent(\'incident\')}'
            queries: {
              sysparm_display_value: false
              sysparm_exclude_reference_link: true
            }
          }
        }
        Response: {
          runAfter: {
            Create_Record: [
              'Succeeded'
            ]
          }
          type: 'Response'
          kind: 'Http'
          inputs: {
            body: {
              'incident number': '@body(\'Create_Record\')?[\'result\']?[\'number\']'
              'update date': '@body(\'Create_Record\')?[\'result\']?[\'sys_updated_on\']'
            }
            statusCode: 201
          }
        }
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        value: {
          'service-now': {
            connectionId: connections_service_now_externalid
            connectionName: 'service-now'
            id: '/subscriptions/69758558-4e19-41c9-add5-4f6028ef4956/providers/Microsoft.Web/locations/northcentralus/managedApis/service-now'
          }
        }
      }
    }
  }
}