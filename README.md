# Overview

This repository demonstrates how to create and deploy Azure resources at the subscription level using Bicep, Microsoft's modern Infrastructure-as-Code (IaC) language.

You can view my article [here](https://omiete-projects.hashnode.dev/use-bicep-to-automate-and-deploy-azure-virtual-machines-and-associated-resources)

## Repository Structure

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

<img width="377" height="291" alt="vm_fleet_visualiser" src="https://github.com/user-attachments/assets/18663f69-e796-4b75-b7b3-78e796f286f1" />

## Getting Started

### Prerequisites

To use this repository, you need the following tools installed:

- [Azure Account](https://portal.azure.com )
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli?spm=a2ty_o01.29997173.0.0.166dc921uuP4WM)
- [Bicep CLI]( https://learn.microsoft.com/azure/azure-resource-manager/bicep/install?spm=a2ty_o01.29997173.0.0.166dc921uuP4WM)
- Visual Studio Code with the [Bicep extension]( https://marketplace.visualstudio.com/items?spm=a2ty_o01.29997173.0.0.166dc921uuP4WM&itemName=ms-azuretools.vscode-bicep)

### Clone the Repository

```bash
git clone https://github.com/omiete01/vm-fleet-commander.git
cd vm-fleet-commander
```

### Authenticate to Azure

Log in to Azure CLI and Set the Azure subscription
```bash
az login
az account set --subscription "<SubscriptionID>"
```

### How to Deploy

Modify the parameters file `main.dev.parameters.json` to suit your environment

### Validate the Bicep Template

Validate your Bicep template to ensure it is free of syntax errors. Replace $location with the region you want to deploy in. Example: `centralus`

`az deployment sub validate --name main --location $location --template-file main.bicep --parameters main.dev.parameters.json`

### Deploy the Bicep Template

Run the following command to deploy the resources at the subscription level. Replace $location with the region you want to deploy in. Example: `centralus`

`az deployment sub create --name main --resource-group $location --template-file main.bicep --parameters main.dev.parameters.json`

<img width="486" height="211" alt="vm-deploy" src="https://github.com/user-attachments/assets/d4167118-db7d-4e16-ba64-57cb25fd165c" />

### Resources

Here are some helpful resources to learn more about Bicep and Azure deployments:

[Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/?spm=a2ty_o01.29997173.0.0.166dc921h5YgkF)
[Azure CLI Documentation](https://docs.microsoft.com/cli/azure/?spm=a2ty_o01.29997173.0.0.166dc921h5YgkF)
[Subscription-Level Deployments in Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/deploy-to-subscription?spm=a2ty_o01.29997173.0.0.166dc921h5YgkF)
[Bicep Playground](https://bicepdemo.z22.web.core.windows.net/?spm=a2ty_o01.29997173.0.0.166dc921h5YgkF)
