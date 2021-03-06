Param(
  [Parameter(Mandatory=$true)] [string] $subscription, 
  [Parameter(Mandatory=$true)] [string] $modelResourceGroupName,
  [Parameter(mandatory=$true)] [string] $modelLocation,
  [Parameter(mandatory=$true)] [string] $modelAppName,
  [Parameter(mandatory=$true)] [string] $modelStorageAccountName,
  [Parameter(mandatory=$true)] [string] $cognitiveServicesAccountName,
  [Parameter(mandatory=$true)] [string] $imageAnalysisEndpoint
  #[Parameter(mandatory=$true)] [string] $imageAnalysisVisualFeatures *****TODO***** figure out how to pass a string that includes commas
)

$imageAnalysisVisualFeatures = 'Categories,Description,Color,Brands'

while([string]::IsNullOrWhiteSpace($subscription))
  {$subscription= Read-Host -Prompt "Input the name of the subscription where this solution will be deployed"}

if ([string]::IsNullOrWhiteSpace($modelLocation)){
  $modelLocation = Read-Host -Prompt 'Input the Azure location, data center, where you want this solution deployed.  Note, if you will be using Python functions as part of your solution, As of 8/1/19, Python functions are only available in eastasia, eastus, northcentralus, northeurope, westeurope, and westus.  If you deploy your solution in a different data center network transit time may affect your solution performance.  (default=westus)'
  if ([string]::IsNullOrWhiteSpace($modelLocation)) {$modelLocation = "westus"}}

if ([string]::IsNullOrWhiteSpace($modelResourceGroupName)){
  $modelResourceGroupName = Read-Host -Prompt 'Input the name of the resource group that you want to create for this installation of the model.  The default value is MLProfessoarStaticModel'
  if ([string]::IsNullOrWhiteSpace($modelResourceGroupName)) {$modelResourceGroupName = "MLPImgAnalysis"}}

if ([string]::IsNullOrWhiteSpace($modelAppName)){
  while([string]::IsNullOrWhiteSpace($modelAppName))
    {$modelAppName= Read-Host -Prompt "Input the name for the azure function app you want to create for your analysis model. Note this must be a name that is unique across all of Azure"}}

while([string]::IsNullOrWhiteSpace($modelStorageAccountName))
  {$modelStorageAccountName= Read-Host -Prompt "Input the name of the azure storage account you want to create for this installation of the model. Note this must be a name that is no longer than 24 characters and only uses lowercase letters and numbers and is unique across all of Azure"
  if ($modelStorageAccountName.length -gt 24){$modelStorageAccountName=$null
  Write-Host "Storage account name cannot be longer than 24 charaters." -ForegroundColor "Red"}
  if ($modelStorageAccountName -cmatch '[A-Z]') {$modelStorageAccountName=$null
  Write-Host "Storage account name must not have upper case letters." -ForegroundColor "Red"}
  }

if ([string]::IsNullOrWhiteSpace($cognitiveServicesAccountName)){
  $cognitiveServicesAccountName = Read-Host -Prompt 'Input the name of the Azure Cognitive Services resource that you want to create for this installation of the model.  (default=ImgAnalysis  )'
    if ([string]::IsNullOrWhiteSpace($cognitiveServicesAccountName)) {$cognitiveServicesAccountName = "ImgAnalysis"}}

if ([string]::IsNullOrWhiteSpace($imageAnalysisEndpoint)){
  $imageAnalysisEndpoint = Read-Host -Prompt 'Input the http endpoint of the Azure Cognitive Services Image Analysis service.  (default=https://westus.api.cognitive.microsoft.com/vision/v2.0/analyze)'
    if ([string]::IsNullOrWhiteSpace($imageAnalysisEndpoint)) {$imageAnalysisEndpoint = "https://westus.api.cognitive.microsoft.com/vision/v2.0/analyze"}}

if ([string]::IsNullOrWhiteSpace($imageAnalysisVisualFeatures)){
  $imageAnalysisVisualFeatures = Read-Host -Prompt 'Input the http endpoint of the Azure Cognitive Services Image Analysis service.  (default=Categories,Description,Color,Brands)'
    if ([string]::IsNullOrWhiteSpace($imageAnalysisVisualFeatures)) {$imageAnalysisVisualFeatures = "Categories,Description,Color,Brands"}}

$modelStorageAccountKey = $null

if (az group exists --name $modelResourceGroupName) `
  {Write-Host "Deleting resource group." -ForegroundColor "Green" 
  az group delete `
	  --name $modelResourceGroupName `
	  --subscription $subscription `
	  --yes -y}

Write-Host "Creating Resource Group: " $modelResourceGroupName  -ForegroundColor "Green"

az group create `
  --name $modelResourceGroupName `
  --location $modelLocation 

Write-Host "Creating storage account: " $modelStorageAccountName  -ForegroundColor "Green"

az storage account create `
    --location $modelLocation `
    --name $modelStorageAccountName `
    --resource-group $modelResourceGroupName `
    --sku Standard_LRS

Write-Host "Getting storage account key." -ForegroundColor "Green"

$modelStorageAccountKey = `
	(get-azureRmStorageAccountKey `
		-resourceGroupName $modelResourceGroupName `
		-AccountName $modelStorageAccountName).Value[0]

Write-Host "Creating function app: " $modelAppName -ForegroundColor "Green"

az functionapp create `
  --name $modelAppName `
  --storage-account $modelStorageAccountName `
  --consumption-plan-location $modelLocation `
  --resource-group $modelResourceGroupName `
  --os-type "Linux" `
  --runtime "python"

Write-Host "Creating cognitive services account." $cognitiveServicesAccountName -ForegroundColor "Green"

az cognitiveservices account create `
    --name $cognitiveServicesAccountName `
    --resource-group $modelResourceGroupName `
    --kind ComputerVision `
    --sku S1 `
    --location $modelLocation `
    --yes


az functionapp config appsettings set `
    --name $modelAppName `
    --resource-group $modelResourceGroupName `
    --settings "imageAnalysisEndpoint=$imageAnalysisEndpoint" `
    "imageAnalysisVisualFeatures=$imageAnalysisVisualFeatures" `
    "subscriptionKey=Null"

#gitrepo=https://github.com/thaugensorg/semi-supervisedModelSolution.git
#token=<Replace with a GitHub access token>

# Enable authenticated git deployment in your subscription from a private repo.
#az functionapp deployment source update-token \
#  --git-token $token

# Create a function app with source files deployed from the specified GitHub repo.
#az functionapp create \
#  --name autoTestDeployment \
#  --storage-account semisupervisedstorage \
#  --consumption-plan-location centralUS\
#  --resource-group customVisionModelTest \
#  --deployment-source-url https://github.com/thaugensorg/semi-supervisedModelSolution.git \
#  --deployment-source-branch master