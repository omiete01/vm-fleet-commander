
targetScope='subscription'

@description('The name of the environment. This must be dev, test, or prod.')
@allowed([
  'dev'
  'test'
  'prod'
])
param environmentName string = 'test'

// @description('The location of the resource group')
// @allowed([
//   'westus2'
//   'centralus'
//   'eastus'
// ])
param location string = 'westus2'

@description('The name of the resource group.')
param rgNameParam object = {
  name: '${environmentName}-RG'
  location: 'centralus'
}


@description('The tags assigned to the resource')
param tags object = {
  name: rgNameParam.name
  value: environmentName
}

@description('The name of the vm')
param vmName string = 'vm-${environmentName}'

@description('The size of the vm.')
@allowed([
  'Standard_B2s'
  'Standard_B2als_v2'
  'Standard_B2as_v2'
  'Standard_B4als_v2'
  'Standard_B4as_v2'
])
param vmSize string = 'Standard_B2s'

@description('The number of vm instances.')
@minValue(1)
@maxValue(5)
param vmInstanceCount int 

@description('The Password of the VM.')
@secure()
param adminPassword string

@description('The name of the the Subnet.')
param subnetName string = 'subnet-${vmName}'

@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
param dnsLabelPrefix string = toLower('${vmName}-${uniqueString(rgNameParam.name, vmName)}')

@description('Name for the Public IP used to access the Virtual Machine.')
param publicIpName string = 'PublicIP'

@description('Allocation method for the Public IP used to access the Virtual Machine.')
param publicIPAllocationMethod string = 'Static'

@description('SKU for the Public IP used to access the Virtual Machine.')
param publicIpSku string = 'Standard'

param OSVersion string = '2022-datacenter-azure-edition'

@description('The user name of the VM.')
var adminUserName = 'vm-${environmentName}-admin'

@description('The name of the Virtual Network.')
var vnetName = 'vnet-${environmentName}'

var vnetAdressPrefix = '10.1.0.0/16'
var subnetPrefix = '10.1.1.0/24'
var nsgName = 'nsg-${vnetName}'
var nicName = 'VMNic-${environmentName}'

module resourceGroupName 'modules/resource-group.bicep' = {
  name: rgNameParam.name
  params: {
    location: location
    tags: tags
    resourceGroupName: rgNameParam.name
  }
}

module vnet 'modules/vnet.bicep' = {
  name: vnetName
  scope: resourceGroup(rgNameParam.name)
  params: {
    location: location
    subnetName: subnetName
    subnetPrefix: subnetPrefix
    vnetAdressPrefix: vnetAdressPrefix
    vnetName: vnetName
  }
  dependsOn: [
    resourceGroupName
  ]
}

module vm 'modules/vm.bicep' = {
  name: vmName
  scope: resourceGroup(rgNameParam.name)
  params: {
    location: location
    OSVersion: OSVersion
    adminPassword: adminPassword
    adminUserName: adminUserName
    dnsLabelPrefix: dnsLabelPrefix
    environmentName: environmentName
    nicName: nicName
    nsgName: nsgName
    publicIPAllocationMethod: publicIPAllocationMethod
    publicIpName: publicIpName
    publicIpSku: publicIpSku
    subnetName: subnetName
    vmInstanceCount: vmInstanceCount
    vmName: vmName
    vmSize: vmSize
    vnetName: vnetName
  }
  dependsOn: [
    vnet
  ]
}

