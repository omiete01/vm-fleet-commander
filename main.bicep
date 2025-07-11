
// targetScope = 'resourceGroup'

// @description('The name of the Resource Group.')
// param resourceGroupName string = 'vmfleet-resourcegroup'

@description('The name of the environment. This must be dev, test, or prod.')
@allowed([
  'dev'
  'test'
  'prod'
])
param environmentName string = 'dev'

@description('The location of the resource group')
@allowed([
  'westus2'
  'centralus'
  'eastus'
])
param location string = 'westus2'

@description('The name of the vm')
param vmName string = 'vm'

@description('The size of the vm.')
param vmSize string = 'Standard_B2s'

@description('The number of vm instances.')
@minValue(1)
@maxValue(5)
param vmInstanceCount int = 2

@description('The Password of the VM.')
@secure()
param adminPassword string

@description('The name of the the Subnet.')
param subnetName string = 'subnet-${vmName}'

@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
param dnsLabelPrefix string = toLower('${vmName}-${uniqueString(resourceGroup().id, vmName)}')

@description('Name for the Public IP used to access the Virtual Machine.')
param publicIpName string = 'PublicIP'

@description('Allocation method for the Public IP used to access the Virtual Machine.')
param publicIPAllocationMethod string = 'Static'

@description('SKU for the Public IP used to access the Virtual Machine.')
param publicIpSku string = 'Standard'

param OSVersion string = '2022-datacenter-azure-edition'

// @description('The name and IP address range for each subnet in the virtual networks.')
// var subnets = [ 
//   {
//     name: 'web'
//     subnetPrefix: '10.1.2.0/24'
//   }
//   {
//     name: 'application'
//     subnetPrefix: '10.1.3.0/24'
//   }
//   {
//     name: 'database'
//     subnetPrefix: '10.1.4.0/24'
//   }
// ]

@description('The user name of the VM.')
var adminUserName = 'vm-${environmentName}-admin'

@description('The name of the Virtual Network.')
var vnetName = 'vnet-${environmentName}'

var vnetAdressPrefix = [
  for i in range(1, vmInstanceCount): '10.${i}.0.0/16'
]

var subnetPrefix = [
  for i in range(1, vmInstanceCount): '10.${i}.${i}.0/24'
]

var nsgName = 'nsg-${vnetName}'
var nicName = 'VMNic-${environmentName}'

resource publicIp 'Microsoft.Network/publicIPAddresses@2022-05-01' = [for i in range(1, vmInstanceCount):{
  name: '${publicIpName}-${environmentName}-${i}'
  location: location
  sku: {
    name: publicIpSku
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
    dnsSettings: {
      domainNameLabel: '${dnsLabelPrefix}-${i}'
    }
  }
}]

resource vm 'Microsoft.Compute/virtualMachines@2024-11-01' = [for i in range(1, vmInstanceCount): {
  name: '${vmName}-${environmentName}-${i}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic[i - 1].id
        }
      ]
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: OSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      dataDisks: [
        {
          diskSizeGB: 1023
          lun: 0
          createOption: 'Empty'
        }
      ]
    }
  }
}]

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-3389'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3389'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}


resource vnet 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        // Expand the vnetAdressPrefix array elements here
        for prefix in vnetAdressPrefix: prefix
      ]
    }
    subnets: [{
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix[0]
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2022-05-01' = [for i in range(1, vmInstanceCount): {
  name: '${nicName}-${i}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIp[i - 1].id
          }
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
          }
        }
      }
    ]
  }
  dependsOn: [
    vnet
  ]
}]

















// param subnetName string

// resource vmRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
//   name: resourceGroupName
//   location: resourceGroupLocation
// }

// module vm 'modules/vm.bicep' = {
//   name: vmName
//   params: {
//     location: location
//     adminPassword: adminPassword
//     adminUsername: adminUserName
//     osVersion: 'latest'
//     vmName: vmName
//     vmSize: vmSize
//   }  

// }

// module vNet 'modules/vnet.bicep' = {
//   params: {
//     location: location
//     subnetAdressPrefix: subnetAddressPrefix
//     subnetName: 'subnet-${vmName}'
//     vnetAdressPrefix: vnetAddressPrefix
//     vnetName: 'vnet-${vmName}'
//   }
// }

