import logging
import os
import requests
import json
import azure.functions as func

from azure.cognitiveservices.vision.computervision import ComputerVisionClient
from azure.cognitiveservices.vision.computervision.models import VisualFeatureTypes
from msrest.authentication import CognitiveServicesCredentials

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    dataBlobURL = req.params.get('dataBlobUrl')
    if not dataBlobURL:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            dataBlobURL = req_body.get('dataBlobUrl')

    if dataBlobURL:

        # https://docs.microsoft.com/en-us/azure/cognitive-services/computer-vision/quickstarts/python-analyze

        subscription_key = os.environ['subscriptionKey']
        assert subscription_key, "subscriptionKey environment variable not set"
        # Get endpoint and key from environment variables
        staticModelAnalyzeEndpoint = os.environ['staticModelAnalyzeEndpoint']
        assert staticModelAnalyzeEndpoint, "staticModelAnalyzeEndpoint environment variable not set"
        imageAnalysisVisualFeatures = os.environ['imageAnalysisVisualFeatures']
        assert imageAnalysisVisualFeatures, "imageAnalysisVisualFeatures environment variable not set"

        if dataBlobURL == "test" or dataBlobURL == "Test" or dataBlobURL == "TEST":
            pass
            # Set image_url to the URL of th etest image that will be analyzed.
            image_url = "https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/" + \
                "Broadway_and_Times_Square_by_night.jpg/450px-Broadway_and_Times_Square_by_night.jpg"

        else:
            pass
            # Set image_url to the URL of the image that will be analyzed
            image_url = dataBlobURL

        logging.info(image_url)

        headers = {'Ocp-Apim-Subscription-Key': subscription_key}
        params = {'visualFeatures': imageAnalysisVisualFeatures}
        data = {'url': image_url}
        response = requests.post(staticModelAnalyzeEndpoint, headers=headers,
                                params=params, json=data)
        return func.HttpResponse(json.dumps(response.json()), status_code=400)
    else:
        return func.HttpResponse(
             "Please pass a blob name on the query string or in the request body",
             status_code=400
        )
