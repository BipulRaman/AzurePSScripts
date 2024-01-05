<#
.SYNOPSIS
    Retrieves a list of blobs from a storage container and exports it to a CSV file.

.DESCRIPTION
    This script retrieves a list of blobs from a specified storage container using the Azure Storage module.
    It then exports the blob list to a CSV file with the specified output file path.

.PARAMETER StorageAccountName
    The name of the Azure Storage account.

.PARAMETER StorageAccountKey
    The access key for the Azure Storage account.

.PARAMETER ContainerName
    The name of the storage container containing the blobs.

.PARAMETER OutputFilePath
    The file path where the blob list will be exported as a CSV file.

.EXAMPLE
    Get-BlobList -StorageAccountName "someAccountName" -StorageAccountKey "someAccountKey" -ContainerName "someContainerName" -OutputFilePath "results.csv"
    Retrieves the blob list from the "someContainerName" container in the "someAccountName" storage account and exports it to "results.csv".
#>

$StorageAccountName = "someAccountName"
$StorageAccountKey = "someAccountKey"
$ContainerName = "someContainerName"
$OutputFilePath = "results.csv"

function Get-BlobList {
    param (
        [string]$StorageAccountName,
        [string]$StorageAccountKey,
        [string]$ContainerName,
        [string]$OutputFilePath
    )

    $MaxReturn = 10000
    $Total = 0
    $Token = $Null
    $Blobs = $Null

    Write-Host "Getting blob list from $ContainerName container ..." -ForegroundColor Green
    $Context = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey

    do {
        $Blobs = Get-AzureStorageBlob -Container $ContainerName -MaxCount $MaxReturn -ContinuationToken $Token -Context $Context
        $Total += $Blobs.Count
        if ($Blobs.Length -le 0) { Break; }
        $Token = $Blobs[$blobs.Count - 1].ContinuationToken;
    }
    While ($Null -ne $Token)

    Write-Host "Total blobs: $Total" -ForegroundColor Green

    return $Blobs | Select-Object Name, @{Name = "SizeInKB"; Expression = { [math]::Round($_.Length / 1KB, 2) } }, @{Name = "LastModified"; Expression = { $_.LastModified.ToLocalTime() } }
}

$BlobList = Get-BlobList -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey -ContainerName $ContainerName

Write-Host "Exporting blob list to $OutputFilePath ..." -ForegroundColor Green
$BlobList | Sort-Object -Property LastModified -Descending | Export-Csv -Path $OutputFilePath -NoTypeInformation
