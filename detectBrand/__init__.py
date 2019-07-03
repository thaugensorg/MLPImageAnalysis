import logging
import os
import azure.functions as func

from azure.cognitiveservices.vision.computervision import ComputerVisionClient
from azure.cognitiveservices.vision.computervision.models import VisualFeatureTypes
from msrest.authentication import CognitiveServicesCredentials

import requests
# If you are using a Jupyter notebook, uncomment the following line.
# %matplotlib inline
#import matplotlib.pyplot as plt
import json
#from PIL import Image
from io import BytesIO

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

        # Replace <Subscription Key> with your valid subscription key.
        subscription_key = os.environ['subscriptionKey']
        assert subscription_key

        # Get endpoint and key from environment variables
        endpoint = 'https://westus.api.cognitive.microsoft.com/'
        vision_base_url = "https://westus.api.cognitive.microsoft.com/vision/v2.0/"

        analyze_url = vision_base_url + "analyze"

        # Set image_url to the URL of an image that you want to analyze.
        image_url = "https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/" + \
            "Broadway_and_Times_Square_by_night.jpg/450px-Broadway_and_Times_Square_by_night.jpg"

        headers = {'Ocp-Apim-Subscription-Key': subscription_key}
        params = {'visualFeatures': 'Categories,Description,Color'}
        data = {'url': image_url}
        response = requests.post(analyze_url, headers=headers,
                                params=params, json=data)
        response.raise_for_status()

        # The 'analysis' object contains various fields that describe the image. The most
        # relevant caption for the image is obtained from the 'description' property.
        analysis = response.json()
        print(json.dumps(response.json()))
        image_caption = analysis["description"]["captions"][0]["text"].capitalize()

        # Set credentials
        credentials = CognitiveServicesCredentials('subscriptionKey')

        # Create client
        client = ComputerVisionClient(endpoint, credentials)

        # type of prediction
        domain = "landmarks"

        # Public domain image of Eiffel tower
        url = "https://images.pexels.com/photos/338515/pexels-photo-338515.jpeg"

        # English language response
        language = "en"

        analysis = client.analyze_image_by_domain(domain, url, language)

        for landmark in analysis.result["landmarks"]:
            print(landmark["name"])
            print(landmark["confidence"])


        #url = "https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/Broadway_and_Times_Square_by_night.jpg/450px-Broadway_and_Times_Square_by_night.jpg"

        #image_analysis = client.analyze_image(url,visual_features=[VisualFeatureTypes.tags])

        #for tag in image_analysis.tags:
            #print(tag)
        
        # "https://semisupervisedstorage.blob.core.windows.net/pendingevaluation/labledQuaker.jpg"

        return func.HttpResponse(f"Hello {name}!")
    else:
        return func.HttpResponse(
             "Please pass a name on the query string or in the request body",
             status_code=400
        )
