<#
.Synopsis
   Creates a Container in a storage account to hold ARM Templates
.DESCRIPTION
   This script will create a storage container for hosting ARM Templates.
.EXAMPLE
#>

#Requires -Version 3.0
#Requires -Module AzureRM.Resources

Param(
  [Parameter(Mandatory = $true)]
  [string] $ResourceGroupName,

  [Parameter(Mandatory = $false)]
  [string] $ContainerName = "templates"
)

function Create-Container ($ResourceGroupName, $ContainerName) {

  # Get Storage Account
  $StorageAccount = Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName
  if (!$StorageAccount) {
    Write-Error -Message "Storage Account in $ResourceGroupName not found. Please fix and continue"
    return
  }

  $Keys = Get-AzureRmStorageAccountKey -Name $StorageAccount.StorageAccountName `
    -ResourceGroupName $ResourceGroupName

  $StorageContext = New-AzureStorageContext -StorageAccountName $StorageAccount.StorageAccountName `
    -StorageAccountKey $Keys[0].Value


  # Create Storage Container
  $GetContainer = Get-AzureStorageContainer -Name $ContainerName -Context $StorageContext -ErrorAction SilentlyContinue

  if (!$GetContainer) {

    Write-Output "Creating the $ContainerName Storage Container..."
    $Container = New-AzureStorageContainer -Name $ContainerName -Context $StorageContext -Permission Off

    if (!$Container) {
      Write-Error -Message "Storage Container $ContainerName creation failed. Please fix and continue"
      return
    }
  } 
  else {
    $Container = Get-AzureStorageContainer -Name $ContainerName -Context $StorageContext

    Write-Output "Container already exists..."
        
  }
}

Create-Container $ResourceGroupName $ContainerName
