$subscription = 'Thaugen-semisupervised-vision-closed-loop-solution'
$location = 'westus'
$solutionNameRoot = 'MLPImgAnalysis' # must be less than 20 characters or the storage acount variable must be provided as a constant
$modelAppName = $solutionNameRoot + 'ModelApp'
$storageAccountName = $solutionNameRoot.ToLower() + 'strg'
$cognitiveServicesAccountName = $modelAppName
$cognitiveServicesImageAnalysisEndpoint = 'https://westus.api.cognitive.microsoft.com/vision/v2.0/analyze'
#$imageAnalysisVisualFeatures = 'Categories,Description,Color,Brands' *****TODO***** figure out hose to pass a string that includes a comma

# setup and configure Azure Cognitive Services Image Analysis for ML Professoar
# note double quote litterals do not seem to work when substituting parameter values from variables.  Builds the right string but it will not invoke
$command = '.\MLPImageAnalysisModelConfig.ps1 ' +`
    '-subscription ' + $subscription + ' '+`
    '-modelResourceGroupName ' + $solutionNameRoot + 'Model ' +`
    '-modelLocation ' + $location + ' '+`
    '-modelAppName ' + $modelAppName + ' '+`
    '-modelStorageAccountName ' + $storageAccountName + ' '+`
    '-cognitiveServicesAccountName ' + $cognitiveServicesAccountName + ' '+`
    '-imageAnalysisEndpoint ' + $cognitiveServicesImageAnalysisEndpoint
    # -imageAnalysisVisualFeatures Categories,Description,Color,Brands

$command

Invoke-Expression $command

# setupand configure ML Professoar engine for this instance of Image Analysis
$command = '.\MLProfessoarEngineConfig.ps1 ' +`
    '-subscription ' + $subscription + ' '+`
    '-frameworkResourceGroupName ' + $solutionNameRoot + 'Engine ' +`
    '-frameworkLocation ' + $location + ' '+`
    '-modelType Static ' +`
    '-evaluationDataParameterName dataBlobUrl ' +`
    '-labelsJsonPath labels.regions[0].tags ' +`
    '-confidenceJSONPath confidence ' +`
    '-dataEvaluationServiceEndpoint https://$modelAppName.azurewebsites.net/api/EvaluateData ' +`
    '-confidenceThreshold .95'
Invoke-Expression $command