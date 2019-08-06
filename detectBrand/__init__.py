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

    name = req.params.get('name')
    if not name:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            name = req_body.get('name')

    if name:

        # https://docs.microsoft.com/en-us/azure/cognitive-services/computer-vision/quickstarts/python-analyze

        subscription_key = os.environ['subscriptionKey']
        assert subscription_key

        # Get endpoint and key from environment variables
        analyze_url = "https://westus.api.cognitive.microsoft.com/vision/v2.0/analyze"

        if name == "test" or name == "Test" or name == "TEST":
            pass
            # Set image_url to the URL of th etest image that will be analyzed.
            image_url = "https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/" + \
                "Broadway_and_Times_Square_by_night.jpg/450px-Broadway_and_Times_Square_by_night.jpg"

        else:
            pass
            # Set image_url to the URL of the image that will be analyzed
            image_url = name

        logging.info(image_url)
        headers = {'Ocp-Apim-Subscription-Key': subscription_key}
        params = {'visualFeatures': 'Categories,Description,Color,Brands'}
        data = {'url': image_url}
        response = requests.post(analyze_url, headers=headers,
                                params=params, json=data)
        response.raise_for_status()

        return func.HttpResponse(json.dumps(response.json()))
    else:
        return func.HttpResponse(
             "Please pass a blob name on the query string or in the request body",
             status_code=400
        )
