$subscription = 'Thaugen-semisupervised-vision-closed-loop-solution'
$location = 'westus'
$solutionNameRoot = 'MLPImageAnalysis' # must be less than 20 characters or the storage acount variable must be provided as a constant
$modelAppName = $solutionNameRoot + 'App'
$storageAccountName = $solutionNameRoot.ToLower() + 'strg'
$cognitiveServicesAccountName = $modelAppName
$cognitiveServicesImageAnalysisEndpoint = 'https://westus.api.cognitive.microsoft.com/vision/v2.0/analyze'
$imageAnalysisVisualFeatures = 'Categories,Description,Color,Brands'

# setup and configure Azure Cognitive Services Image Analysis for ML Professoar
$command = ".\MLPBrandDetectionModelEnvironmentConfiguration.ps1 `
    -subscription $subscription `
    -modelResourceGroupName $solutionNameRoot + Model `
    -modelLocation $location `
    -modelAppName $modelAppName `
    -modelStorageAccountName $storageAccountName `
    -cognitiveServicesAccountName $cognitiveServicesAccountName `
    -imageAnalysisEndpoint $cognitiveServicesImageAnalysisEndpoint `
    -imageAnalysisVisualFeatures $imageAnalysisVisualFeatures"
Invoke-Expression $command

# setupand configure ML Professoar engine for this instance of Image Analysis
$command = ".\MLProfessoarEnvironmentConfiguration.ps1 `
    -subscription $subscription `
    -frameworkResourceGroupName $solutionNameRoot + Engine `
    -frameworkLocation $location `
    -modelType Static `
    -evaluationDataParameterName dataBlobUrl `
    -labelsJsonPath labels.regions[0].tags `
    -confidenceJSONPath confidence `
    -dataEvaluationServiceEndpoint https://$modelAppName.azurewebsites.net/api/EvaluateData `
    -confidenceThreshold .95 "
Invoke-Expression $command