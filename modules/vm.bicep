
param location string 

param environmentName string

@description('The name of the vm')
param vmName string

@description('The size of the vm.')
param vmSize string 

@description('The number of vm instances.')
@minValue(1)
@maxValue(5)
param vmInstanceCount int

@description('The Password of the VM.')
@secure()
param adminPassword string

@description('The name of the the Subnet.')
param subnetName string 

@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
param dnsLabelPrefix string 

@description('Name for the Public IP used to access the Virtual Machine.')
param publicIpName string 

@description('Allocation method for the Public IP used to access the Virtual Machine.')
param publicIPAllocationMethod string 

@description('SKU for the Public IP used to access the Virtual Machine.')
param publicIpSku string 

param OSVersion string 

@description('The user name of the VM.')
param adminUserName string

@description('The name of the Virtual Network.')
param vnetName string

param nsgName string
param nicName string


resource publicIp 'Microsoft.Network/publicIPAddresses@2022-05-01' = [for i in range(1, vmInstanceCount):{
  name: '${publicIpName}-${environmentName}-${i}'
  location: location
  sku: {
    name: publicIpSku
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
    dnsSettings: {
      domainNameLabel: '${dnsLabelPrefix}-${environmentName}-${i}'
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
    networkSecurityGroup: {
      id: nsg.id
    }
  }
  // dependsOn: [
  //   vnet
  // ]
}]
