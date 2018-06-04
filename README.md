# logicapp-demo

__Infrastructure as Code - Logic App Solution__

![[0]][0]

## Getting Started


__Deploy the Infrastructure__

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdanielscholl%2Flogicapp-demo%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

1. Create a Resource Group

```powershell
az group create --location southcentralus --name logicapp-demo
```

1. Modify Infrastructure Template Parameters as desired

1. Deploy Infrastructure Template to Resource Group and create a container.

```powershell
# Set Variables
$ResourceGroup = "logicapp-demo"
$ContainerName = "customers"

# Deploy ARM Template
az group deployment create --template-file azuredeploy.json `
    --parameters azuredeploy.parameters.json `
    --resource-group $ResourceGroup

# Get Storage Context
$StorageAccount = Get-AzureRmStorageAccount `
    -ResourceGroupName $ResourceGroup
$Keys = Get-AzureRmStorageAccountKey `
    -Name $StorageAccount.StorageAccountName `
    -ResourceGroupName $ResourceGroup
$StorageContext = New-AzureStorageContext `
    -StorageAccountName $StorageAccount.StorageAccountName `
    -StorageAccountKey $Keys[0].Value

# Create Blob Container
New-AzureStorageContainer -Name $ContainerName  `
    -Context $StorageContext `
    -Permission Off
```

1. Prepare the Database

Login to the database and run the following TSQL Commands
>Ensure you replace your storage account name.
```sql
CREATE EXTERNAL DATA SOURCE BlobStorage
WITH (    TYPE = BLOB_STORAGE, 
        LOCATION = 'https://<STORAGE_ACCOUNT>.blob.core.windows.net/customers'
);
GO

--Create the Sample Stored Proc
CREATE PROCEDURE uspImportCustomer   
AS   
BEGIN
    BULK INSERT Customer
    FROM 'import.csv'
    WITH 
    (    
        DATA_SOURCE = 'BlobStorage',
        FORMAT='CSV', 
        CODEPAGE = 65001, --UTF-8 encoding
        FIRSTROW=2,
        ROWTERMINATOR = '0x0a',
        TABLOCK
    )
END
GO
```

__Deploy the Logic App__

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdanielscholl%2Flogicapp-demo%2Fmaster%2Flogicapp.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>




[0]: ./dashboard/architecture.png "Architecture Diagram"