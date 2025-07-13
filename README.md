# Overview

This repository demonstrates how to create and deploy Azure resources at the subscription level using Bicep , Microsoft's modern Infrastructure-as-Code (IaC) language.

### Repository Structure

The repository is organized as follows:

├── modules/
│   ├── resource-group.bicep
│   ├── vm.bicep
│   └── vnet.bicep
├── main.bicep
├── env/
│   ├── main.dev.parameters.json
│   ├── main.test.parameters.json
│   └── main.prod.parameters.json
└──README.md

## Getting Started

### Prerequisites

To use this repository, you need the following tools installed:
[/portal.azure.com](/Azure Account)
[/https://docs.microsoft.com/cli/azure/install-azure-cli?spm=a2ty_o01.29997173.0.0.166dc921uuP4WM](/Azure CLI)
[/https://learn.microsoft.com/azure/azure-resource-manager/bicep/install?spm=a2ty_o01.29997173.0.0.166dc921uuP4WM](/Bicep CLI)
Visual Studio Code with the [/https://marketplace.visualstudio.com/items?spm=a2ty_o01.29997173.0.0.166dc921uuP4WM&itemName=ms-azuretools.vscode-bicep](/Bicep extension)

### Clone the Repository

`https://github.com/omiete01/vm-fleet-commander.git`
`cd vm-fleet-commander`

### Authenticate to Azure

Log into Azure CLI and Set the Azure subscription

`az login`
`az account set --subscription "<SubscriptionID>"`

#### How to Deploy

Modify the parameters file `main.dev.parameters.json` to suit your environment

#### Validate the Bicep Template

Validate your Bicep template to ensure it is free of syntax errors. Replace $location with the region you want to deploy in. Example: `centralus`
`az deployment sub validate --name main --location $location --template-file main.bicep --parameters main.dev.parameters.json`

#### Deploy the Bicep Template

Run the following command to deploy the resources at the subsription level. Replace $location with the region you want to deploy in. Example: `centralus`
`az deployment sub create --name main --resource-group $location --template-file main.bicep --parameters main.dev.parameters.json`
