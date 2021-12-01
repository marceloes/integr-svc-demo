param workflows_scanimagelogicapp_name string = 'scanimagelogicapp'
param sites_nameplaterecognizerfunctionapp_externalid string = '/subscriptions/69758558-4e19-41c9-add5-4f6028ef4956/resourceGroups/apim-demo-rg/providers/Microsoft.Web/sites/nameplaterecognizerfunctionapp'
param connections_azureblob_externalid string = '/subscriptions/69758558-4e19-41c9-add5-4f6028ef4956/resourceGroups/apim-demo-rg/providers/Microsoft.Web/connections/azureblob'
param connections_servicebus_externalid string = '/subscriptions/69758558-4e19-41c9-add5-4f6028ef4956/resourceGroups/apim-demo-rg/providers/Microsoft.Web/connections/servicebus'

resource workflows_scanimagelogicapp_name_resource 'Microsoft.Logic/workflows@2017-07-01' = {
  name: workflows_scanimagelogicapp_name
  location: 'southcentralus'
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
        'When_a_message_is_received_in_a_queue_(auto-complete)': {
          recurrence: {
            frequency: 'Minute'
            interval: 1
          }
          evaluatedRecurrence: {
            frequency: 'Minute'
            interval: 1
          }
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'servicebus\'][\'connectionId\']'
              }
            }
            method: 'get'
            path: '/@{encodeURIComponent(encodeURIComponent(\'images\'))}/messages/head'
            queries: {
              queueType: 'Main'
            }
          }
        }
      }
      actions: {
        Call_NameplateRecognizer_Function: {
          runAfter: {
            'Create_SAS_URI_by_path_(V2)': [
              'Succeeded'
            ]
          }
          type: 'Function'
          inputs: {
            function: {
              id: '${sites_nameplaterecognizerfunctionapp_externalid}/functions/NameplateRecognizer'
            }
            queries: {
              imageURL: '@{body(\'Create_SAS_URI_by_path_(V2)\')?[\'WebUrl\']}'
            }
          }
        }
        'Create_SAS_URI_by_path_(V2)': {
          runAfter: {
            Initialize_Blobpath_variable: [
              'Succeeded'
            ]
          }
          type: 'ApiConnection'
          inputs: {
            body: {
              Permissions: 'Read'
            }
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'azureblob\'][\'connectionId\']'
              }
            }
            method: 'post'
            path: '/v2/datasets/@{encodeURIComponent(\'AccountNameFromSettings\')}/CreateSharedLinkByPath'
            queries: {
              path: '@{concat(\'/uploads/\',variables(\'File Name\'))}'
            }
          }
        }
        Create_blob_with_scanned_results: {
          runAfter: {
            Call_NameplateRecognizer_Function: [
              'Succeeded'
            ]
          }
          type: 'ApiConnection'
          inputs: {
            body: '@body(\'Call_NameplateRecognizer_Function\')'
            headers: {
              ReadFileMetadataFromServer: true
            }
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'azureblob\'][\'connectionId\']'
              }
            }
            method: 'post'
            path: '/v2/datasets/@{encodeURIComponent(encodeURIComponent(\'AccountNameFromSettings\'))}/files'
            queries: {
              folderPath: '/results'
              name: '@{variables(\'File Name\')}-results.json'
              queryParametersSingleEncoded: true
            }
          }
          runtimeConfiguration: {
            contentTransfer: {
              transferMode: 'Chunked'
            }
          }
        }
        'Delete_original_image_blob_(V2)': {
          runAfter: {
            Create_blob_with_scanned_results: [
              'Succeeded'
            ]
          }
          type: 'ApiConnection'
          inputs: {
            headers: {
              SkipDeleteIfFileNotFoundOnServer: false
            }
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'azureblob\'][\'connectionId\']'
              }
            }
            method: 'delete'
            path: '/v2/datasets/@{encodeURIComponent(encodeURIComponent(\'AccountNameFromSettings\'))}/files/@{encodeURIComponent(encodeURIComponent(variables(\'Blobpath\')))}'
          }
        }
        Initialize_Blobpath_variable: {
          runAfter: {
            Initialize_filename_variable_: [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'Blobpath'
                type: 'string'
                value: '@{concat(\'/uploads/\',variables(\'File Name\'))}'
              }
            ]
          }
        }
        Initialize_filename_variable_: {
          runAfter: {
            Parse_Message_Body__JSON: [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'File Name'
                type: 'string'
                value: '@body(\'Parse_Message_Body__JSON\')?[\'file_name\']'
              }
            ]
          }
        }
        Parse_Message_Body__JSON: {
          runAfter: {}
          type: 'ParseJson'
          inputs: {
            content: '@base64ToString(triggerBody()?[\'ContentData\'])'
            schema: {
              properties: {
                file_name: {
                  type: 'string'
                }
                thumb_name: {
                  type: 'string'
                }
              }
              type: 'object'
            }
          }
        }
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        value: {
          azureblob: {
            connectionId: connections_azureblob_externalid
            connectionName: 'azureblob'
            id: '/subscriptions/69758558-4e19-41c9-add5-4f6028ef4956/providers/Microsoft.Web/locations/southcentralus/managedApis/azureblob'
          }
          servicebus: {
            connectionId: connections_servicebus_externalid
            connectionName: 'servicebus'
            id: '/subscriptions/69758558-4e19-41c9-add5-4f6028ef4956/providers/Microsoft.Web/locations/southcentralus/managedApis/servicebus'
          }
        }
      }
    }
  }
}