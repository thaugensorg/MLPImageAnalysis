# instructions and documentation for this solution have been moved to the Read Me file in the solution

while([string]::IsNullOrWhiteSpace($subscription))
  {$subscription= Read-Host -Prompt "Input the name of the subscription where this solution will be deployed"}

$model_resource_group_name = Read-Host -Prompt 'Input the name of the resource group that you want to create for this installation of the model.  (default=SemisupervisedModel)'
  if ([string]::IsNullOrWhiteSpace($model_resource_group_name)) {$model_resource_group_name = "StaticMLProfSample"}
  
while([string]::IsNullOrWhiteSpace($model_app_name))
  {$model_app_name= Read-Host -Prompt "Input the name for the azure function app you want to create for your analysis model. Note this must be a name that is unique across all of Azure"}

while([string]::IsNullOrWhiteSpace($model_storage_account_name))
  {$model_storage_account_name = Read-Host -Prompt "Input the name of the azure storage account you want to create for this installation of the model. Note this must be a name that only uses lowercase letters and numbers and is unique across all of Azure"}
  
$cognitive_services_account_name = Read-Host -Prompt 'Input the name of the Azure Cognitive Services resource that you want to create for this installation of the model.  (default=ImageAnalysis)'
  if ([string]::IsNullOrWhiteSpace($cognitive_services_account_name)) {$cognitive_services_account_name = "ImageAnalysis"}

$model_location = Read-Host -Prompt 'Input the Azure location, data center, where you want this solution deployed.  Note, if you will be using Python functions as part of your solution, As of 8/1/19, Python functions are only available in eastasia, eastus, northcentralus, northeurope, westeurope, and westus.  If you deploy your solution in a different data center network transit time may affect your solution performance.  (default=westus)'
  if ([string]::IsNullOrWhiteSpace($model_location)) {$model_location = "westus"}

$model_storage_account_key = $null

if (az group exists --name $model_resource_group_name) `
	{az group delete `
	  --name $model_resource_group_name `
	  --subscription $subscription `
	  --yes -y}

az group create `
  --name $model_resource_group_name `
  --location $model_location 

az storage account create `
    --location $model_location `
    --name $model_storage_account_name `
    --resource-group $model_resource_group_name `
    --sku Standard_LRS

$model_storage_account_key = `
	(get-azureRmStorageAccountKey `
		-resourceGroupName $model_resource_group_name `
		-AccountName $model_storage_account_name).Value[0]

az functionapp create `
  --name $model_app_name `
  --storage-account $model_storage_account_name `
  --consumption-plan-location $model_location `
  --resource-group $model_resource_group_name `
  --os-type "Linux" `
  --runtime "python"

az cognitiveservices account create `
    --name $cognitive_services_account_name `
    --resource-group $model_resource_group_name `
    --kind ComputerVision `
    --sku S0 `
    --location westus `
    --yes

$cog_services_subscription_key = `
  (get-AzureRmCognitiveServicesAccountKey `
    -resourceGroupName $model_resource_group_name `
    -AccountName $cognitive_services_account_name).Key1
  
az functionapp config appsettings set `
    --name $model_app_name `
    --resource-group $model_resource_group_name `
    --settings "subscriptionKey=$cog_services_subscription_key"

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