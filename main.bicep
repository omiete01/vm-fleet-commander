
@description('The name of the environment. This must be dev, test, or prod.')
@allowed([
  'dev'
  'test'
  'prod'
])
param environmentName string = 'test'

@description('The location of the resource group')
@allowed([
  'westus2'
  'centralus'
  'eastus'
])
param location string = 'westus2'

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

@description('The user name of the VM.')
var adminUserName = 'vm-${environmentName}-admin'

@description('The name of the Virtual Network.')
var vnetName = 'vnet-${environmentName}'

var vnetAdressPrefix = '10.1.0.0/16'
var subnetPrefix = '10.1.1.0/24'
var nsgName = 'nsg-${vnetName}'
var nicName = 'VMNic-${environmentName}'

module vnet 'modules/vnet.bicep' = {
  name: vnetName
  params: {
    location: location
    subnetName: subnetName
    subnetPrefix: subnetPrefix
    vnetAdressPrefix: vnetAdressPrefix
    vnetName: vnetName
  }
}

module vm 'modules/vm.bicep' = {
  name: vmName
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

