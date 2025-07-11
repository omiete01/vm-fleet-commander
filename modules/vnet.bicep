
@description('The name of the Virtual Network.')
param vnetName string 

@description('The name of the the Subnet.')
param subnetName string 

@description('The address prefix of the Virtual Network')
param vnetAdressPrefix string

@description('The address prefix of the subnet.')
param subnetPrefix string

@description('The location of the virtual network.')
param location string

resource vnet 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAdressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
        }
      }
    ]
  }
}

output subnetid string = vnet.properties.subnets[0].id
